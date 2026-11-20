extends CharacterBody3D

signal shot_requested
signal branch_requested

const BowAudio := preload("res://scripts/bow_audio.gd")
const WALK_SPEED := 4.6
const LOOK_SENSITIVITY := 0.00215
const EYE_HEIGHT := 1.65
const TOP_TIP := Vector3(-0.022, 0.51, 0.15)
const BOTTOM_TIP := Vector3(-0.016, -0.49, 0.15)

var camera := Camera3D.new()
var _view := Node3D.new()
var _bow := Node3D.new()
var _nocked := Node3D.new()
var _drawing_hand := Node3D.new()
var _string_top: MeshInstance3D
var _string_bottom: MeshInstance3D
var _sound := BowAudio.new()
var _materials: Dictionary = {}
var _active := false
var _has_arrows := true
var _await_release := false
var _press_pending := false
var _branch_pending := false
var _pitch := 0.0
var _aim := 0.0
var _sway := Vector2.ZERO
var _step := 0.0
var _pace := 0.0
var _since_shot := 2.0
var _since_branch := 2.0


func _ready() -> void:
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.31
	capsule.height = 1.75
	var collision := CollisionShape3D.new()
	collision.shape = capsule
	collision.position.y = capsule.height * 0.5
	add_child(collision)
	floor_snap_length = 0.18

	camera.name = "Eyes"
	camera.position.y = EYE_HEIGHT
	camera.current = true
	camera.fov = 70.0
	camera.near = 0.025
	add_child(camera)
	camera.add_child(_view)
	# Put the weapon inside the capsule while preserving its projected silhouette.
	_view.scale = Vector3.ONE * 0.25
	_view.add_child(_bow)
	add_child(_sound)
	_build_bow()
	_pose(0.0)


func set_active(enabled: bool) -> void:
	_active = enabled
	_press_pending = false
	_branch_pending = false
	_await_release = enabled and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if enabled else Input.MOUSE_MODE_VISIBLE
	if not enabled:
		velocity = Vector3.ZERO


func set_has_arrows(has_arrows: bool) -> void:
	_has_arrows = has_arrows
	_nocked.visible = has_arrows and _since_shot > 0.19


func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion: Vector2 = event.screen_relative
		var sensitivity := LOOK_SENSITIVITY * lerpf(1.0, 0.65, _aim)
		rotate_y(-motion.x * sensitivity)
		_pitch = clampf(_pitch - motion.y * sensitivity, deg_to_rad(-82.0), deg_to_rad(82.0))
		camera.rotation.x = _pitch
		_sway = (_sway + motion * 0.00075).limit_length(0.035)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_press_pending = not _await_release
		else:
			_await_release = false
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_F or event.keycode == KEY_F:
			_branch_pending = true


func _physics_process(delta: float) -> void:
	if not _active:
		return
	var move_input := Vector2(
		float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
		float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
	).normalized()
	var direction := basis * Vector3(move_input.x, 0.0, move_input.y)
	var speed := WALK_SPEED * lerpf(1.0, 0.70, _aim)
	velocity.x = move_toward(velocity.x, direction.x * speed, 27.0 * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, 27.0 * delta)
	if not is_on_floor():
		velocity.y = maxf(velocity.y - 18.0 * delta, -25.0)
	else:
		velocity.y = -0.5
	move_and_slide()
	position.x = clampf(position.x, -13.0, 13.0)
	position.z = clampf(position.z, -13.0, 13.0)
	_pace = minf(Vector2(velocity.x, velocity.z).length() / WALK_SPEED, 1.0)

	var held := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if _press_pending or (held and not _await_release):
		shot_requested.emit()
	_press_pending = false
	if not held:
		_await_release = false
	if _branch_pending:
		_branch_pending = false
		branch_requested.emit()


func _process(delta: float) -> void:
	if _active:
		_pose(delta)


func aim_hit(max_distance: float = 50.0) -> Dictionary:
	var origin := camera.global_position
	var endpoint := origin - camera.global_basis.z * max_distance
	var query := PhysicsRayQueryParameters3D.create(origin, endpoint)
	query.exclude = [get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query)


func play_shot(end_point: Vector3, on_landing := Callable()) -> void:
	_since_shot = 0.0
	_sound.play("shot")
	# The independent projectile survives drawing the last arrow from the quiver.
	var projectile := Node3D.new()
	add_child(projectile)
	projectile.top_level = true
	projectile.global_position = _bow.to_global(Vector3(0.025, 0.04, -0.20))
	var distance := projectile.global_position.distance_to(end_point)
	if distance < 0.025:
		if on_landing.is_valid():
			on_landing.call()
		projectile.queue_free()
		return
	var travel_axis := projectile.global_position.direction_to(end_point)
	var up := Vector3.RIGHT if absf(travel_axis.dot(Vector3.UP)) > 0.98 else Vector3.UP
	projectile.look_at(end_point, up)
	_arrow_geometry(projectile, 0.48, true)
	var flight := projectile.create_tween()
	flight.tween_property(projectile, "global_position", end_point, clampf(distance / 59.0, 0.045, 0.55))
	if on_landing.is_valid():
		flight.tween_callback(on_landing)
	flight.tween_interval(0.32)
	flight.tween_callback(projectile.queue_free)


func play_branch() -> void:
	_since_branch = 0.0
	_sound.play("branch")


func play_cue(cue: String) -> void:
	_sound.play(cue)


func _material(tint: String) -> StandardMaterial3D:
	if not _materials.has(tint):
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(tint)
		material.roughness = 0.92
		_materials[tint] = material
	return _materials[tint]


func _block(parent: Node3D, center: Vector3, size: Vector3, tint: String) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var piece := MeshInstance3D.new()
	piece.mesh = mesh
	piece.material_override = _material(tint)
	piece.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(piece)
	piece.position = center
	return piece


func _rod(parent: Node3D, start: Vector3, finish: Vector3, width: float, depth: float, tint: String) -> MeshInstance3D:
	var beam := _block(parent, Vector3.ZERO, Vector3(width, 1.0, depth), tint)
	_set_rod(beam, start, finish)
	return beam


func _set_rod(beam: MeshInstance3D, start: Vector3, finish: Vector3) -> void:
	var offset := finish - start
	beam.position = (start + finish) * 0.5
	beam.quaternion = Quaternion(Vector3.UP, offset.normalized())
	beam.scale = Vector3(1.0, offset.length(), 1.0)


func _build_bow() -> void:
	# Angular yew limbs, pale end nocks, linen serving and hand-cut leather grip.
	for side in [-1.0, 1.0]:
		var sign_y := float(side)
		var tip := TOP_TIP if sign_y > 0.0 else BOTTOM_TIP
		var inner := Vector3(0, 0.09 * sign_y, 0.0)
		var elbow := Vector3(-0.009, 0.24 * sign_y, -0.012)
		var corner := Vector3(-0.02, 0.41 * sign_y, 0.073)
		_rod(_bow, inner, elbow, 0.057, 0.054, "694027")
		_rod(_bow, elbow, corner, 0.047, 0.044, "ad7544")
		_rod(_bow, corner, tip, 0.035, 0.032, "cc9457")
		_rod(_bow, inner + Vector3(0.027, 0, -0.011), elbow + Vector3(0.025, 0, -0.011), 0.010, 0.018, "deab63")
		_rod(_bow, elbow + Vector3(0.023, 0, -0.01), corner + Vector3(0.021, 0, -0.01), 0.008, 0.014, "e9bf71")
		_rod(_bow, tip.lerp(corner, 0.26), tip, 0.038, 0.038, "e4d8a6")
		_rod(_bow, elbow.lerp(inner, 0.19), elbow.lerp(inner, 0.05), 0.061, 0.061, "bd9156")
	_block(_bow, Vector3.ZERO, Vector3(0.072, 0.20, 0.08), "503929")
	for wrap in range(5):
		var strap := _block(_bow, Vector3(0, -0.078 + 0.038 * wrap, 0), Vector3(0.077, 0.023, 0.084), "885f3a")
		strap.rotation.z = -0.07
	_string_top = _block(_bow, Vector3.ZERO, Vector3(0.006, 1, 0.006), "f4dfae")
	_string_bottom = _block(_bow, Vector3.ZERO, Vector3(0.006, 1, 0.006), "f4dfae")

	# Grip hand, fingerless glove and the contrasting cuff of the forest archer.
	_rod(_bow, Vector3(0.018, -0.075, 0.028), Vector3(0.17, -0.33, 0.16), 0.107, 0.106, "385747")
	_rod(_bow, Vector3(0.025, -0.097, 0.04), Vector3(0.072, -0.174, 0.082), 0.11, 0.117, "805639")
	_block(_bow, Vector3(0.03, -0.055, 0.034), Vector3(0.093, 0.106, 0.084), "ae7652")
	for finger in range(3):
		_block(_bow, Vector3(-0.002, -0.079 + 0.026 * finger, 0.048), Vector3(0.078, 0.020, 0.034), "dbab7a")

	_bow.add_child(_drawing_hand)
	_block(_drawing_hand, Vector3(0.062, -0.032, 0.029), Vector3(0.093, 0.093, 0.078), "854f37")
	_rod(_drawing_hand, Vector3(0.074, -0.048, 0.05), Vector3(0.20, -0.21, 0.19), 0.096, 0.104, "395b4d")
	for finger in range(2):
		_block(_drawing_hand, Vector3(0.018, 0.003 - 0.025 * finger, -0.005), Vector3(0.066, 0.018, 0.036), "daac7e")
	_bow.add_child(_nocked)
	_arrow_geometry(_nocked, 0.57, false)


func _arrow_geometry(holder: Node3D, length: float, in_flight: bool) -> void:
	# In flight the origin is the tip. On the string the origin is the nock.
	var offset := length if in_flight else 0.0
	var width := 0.018 if in_flight else 0.013
	_block(holder, Vector3(0, 0, offset - length * 0.5), Vector3(width, width, length), "e3be7e")
	_block(holder, Vector3(0, 0, offset - length), Vector3(width * 1.65, width * 1.65, 0.05), "676f65")
	_block(holder, Vector3(0, 0.011, offset - 0.051), Vector3(0.011, 0.045, 0.084), "eae5c5")
	var fletch := _block(holder, Vector3(0, -0.006, offset - 0.051), Vector3(0.045, 0.011, 0.084), "b56e40")
	fletch.rotation.z = -0.22
	if in_flight:
		_block(holder, Vector3(0, 0, offset + 0.067), Vector3(0.008, 0.008, 0.13), "ffe9a2")


func _pose(delta: float) -> void:
	_since_shot = minf(3.0, _since_shot + delta)
	_since_branch = minf(3.0, _since_branch + delta)
	_aim = move_toward(_aim, float(_active and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)), delta * 6.5)
	_sway = _sway.lerp(Vector2.ZERO, 1.0 - exp(-delta * 12.0))
	_step += delta * _pace * 8.5
	var step_sway := Vector2(sin(_step) * 0.012, cos(2.0 * _step) * 0.009) * _pace
	var recoil := sin(_since_shot * 34.0) * exp(-_since_shot * 13.0)
	var swing := sin(minf(_since_branch / 0.28, 1.0) * PI)
	_bow.position = Vector3(0.36 - _aim * 0.10, -0.245 + _aim * 0.055, -0.83)
	_bow.position += Vector3(step_sway.x - _sway.x, step_sway.y + _sway.y, recoil * 0.055 - swing * 0.15)
	_bow.rotation = Vector3(-0.04 + recoil * 0.11, -0.19 - swing * 0.37, 0.22 - _aim * 0.08 + swing * 0.65)
	camera.fov = lerpf(70.0, 58.0, _aim)
	var draw := smoothstep(0.16, 0.68, _since_shot)
	var nock := Vector3(0.032, 0.046, lerpf(0.15, 0.34, draw) + recoil * 0.018)
	_set_rod(_string_top, TOP_TIP, nock)
	_set_rod(_string_bottom, BOTTOM_TIP, nock)
	_drawing_hand.position = nock + Vector3(0.042 * (1.0 - draw), -0.045 * (1.0 - draw), recoil * 0.08)
	_nocked.position = nock
	_nocked.visible = _has_arrows and _since_shot > 0.19 and swing < 0.3
