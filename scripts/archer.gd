extends CharacterBody3D

signal shot_requested
signal branch_requested

const BowAudio := preload("res://scripts/bow_audio.gd")
const BRANCH_ARROW = preload("res://assets/flecha.tres")
const RECURVE_ARROW = preload("res://assets/flecha_pluma_ancha.tres")
const LONGBOW_ARROW = preload("res://assets/flecha_larga.tres")
const WALK_SPEED := 4.6
const LOOK_SENSITIVITY := 0.00215
const EYE_HEIGHT := 1.65
const JUMP_SPEED := 4.6
const GRAVITY := 18.0
const TOP_TIP := Vector3(0.06, 0.51, 0.15)
const BOTTOM_TIP := Vector3(0.05, -0.49, 0.15)
const RECURVE_TOP := Vector3(0.035, 0.54, 0.09)
const RECURVE_BOTTOM := Vector3(0.028, -0.52, 0.09)
const LONG_TOP := Vector3(0.027, 0.68, 0.21)
const LONG_BOTTOM := Vector3(0.022, -0.66, 0.21)

var camera := Camera3D.new()
var _view := Node3D.new()
var _bow := Node3D.new()
var _branch_limbs := Node3D.new()
var _recurve_limbs := Node3D.new()
var _long_limbs := Node3D.new()
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
var _jump_pending := false
var _supply_candidate: Variant = null
var _supply_landing: Variant = null
var _leap_speed := 0.0
var _pitch := 0.0
var _aim := 0.0
var _sway := Vector2.ZERO
var _step := 0.0
var _pace := 0.0
var _since_shot := 2.0
var _since_branch := 2.0
var _equipped := "branch"
var _repeat_on := false
var _toggle_fire := false
var _motion_amount := 1.0
var _zoom_amount := 1.0
var _sensitivity := 1.0
var _base_fov := 70.0
var _speed_multiplier := 1.0


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
	_jump_pending = false
	_repeat_on = false
	_await_release = enabled and Input.is_action_pressed("shoot")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if enabled else Input.MOUSE_MODE_VISIBLE
	if not enabled:
		velocity.x = 0.0
		velocity.z = 0.0

func apply_settings(options: Dictionary) -> void:
	_sensitivity = clampf(options.get("sensitivity", 1.0), 0.05, 5.0)
	_base_fov = clampf(options.get("fov", 70.0), 45.0, 115.0)
	_zoom_amount = clampf(options.get("zoom", 1.0), 0.0, 1.0)
	_motion_amount = clampf(options.get("shake", 1.0), 0.0, 1.0)
	_toggle_fire = options.get("toggle_fire", false)
	_sound.apply_settings(options)
	camera.fov = _base_fov - _aim * 12.0 * _zoom_amount

func set_speed_multiplier(value: float) -> void:
	_speed_multiplier = value

func set_supply_jump_destination(point: Variant) -> void:
	_supply_candidate = point

func set_bow(id: String) -> void:
	if id == _equipped or id not in ["branch", "recurve", "longbow"]:
		return
	_equipped = id
	_branch_limbs.visible = id == "branch"
	_recurve_limbs.visible = id == "recurve"
	_long_limbs.visible = id == "longbow"
	(_nocked.get_child(0) as MeshInstance3D).mesh = _arrow_mesh()
	_pose(0.0)

func save_pose() -> Dictionary:
	return {"x": position.x, "y": position.y, "z": position.z, "yaw": rotation.y, "pitch": _pitch,
		"vertical_speed": velocity.y, "supply_landing": _supply_landing, "leap_speed": _leap_speed}

func restore_pose(pose: Dictionary) -> void:
	position = Vector3(pose.get("x", 0.0), pose.get("y", 0.0), pose.get("z", 5.0))
	rotation.y = pose.get("yaw", 0.0)
	_pitch = clampf(pose.get("pitch", 0.0), deg_to_rad(-82), deg_to_rad(82))
	camera.rotation.x = _pitch
	velocity = Vector3(0, pose.get("vertical_speed", 0.0), 0)
	_supply_landing = pose.get("supply_landing")
	_leap_speed = pose.get("leap_speed", 0.0)


func set_has_arrows(has_arrows: bool) -> void:
	_has_arrows = has_arrows
	_nocked.visible = has_arrows and _since_shot > 0.19


func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion: Vector2 = event.screen_relative
		var sensitivity := LOOK_SENSITIVITY * _sensitivity * lerpf(1.0, 0.65, _aim * _zoom_amount)
		rotate_y(-motion.x * sensitivity)
		_pitch = clampf(_pitch - motion.y * sensitivity, deg_to_rad(-82.0), deg_to_rad(82.0))
		camera.rotation.x = _pitch
		_sway = (_sway + motion * 0.00075).limit_length(0.035)
	elif event.is_action_pressed("shoot") and not _await_release:
		if _toggle_fire:
			_repeat_on = not _repeat_on
		_press_pending = (not _toggle_fire or _repeat_on)
	elif event.is_action_released("shoot"):
		_await_release = false
	elif event.is_action_pressed("strike"):
		_branch_pending = true
	elif event.is_action_pressed("jump"):
		_jump_pending = true


func _physics_process(delta: float) -> void:
	if not _active:
		return
	var move_input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := basis * Vector3(move_input.x, 0.0, move_input.y)
	var speed := WALK_SPEED * _speed_multiplier * lerpf(1.0, 0.70, _aim)
	velocity.x = move_toward(velocity.x, direction.x * speed, 27.0 * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, 27.0 * delta)
	if _jump_pending and is_on_floor():
		velocity.y = JUMP_SPEED
		if _supply_candidate is Vector3:
			_supply_landing = _supply_candidate
			var distance := Vector2(position.x, position.z).distance_to(Vector2(_supply_landing.x, _supply_landing.z))
			_leap_speed = distance * GRAVITY / (2.0 * JUMP_SPEED)
	elif not is_on_floor() or velocity.y > 0.0:
		velocity.y = maxf(velocity.y - GRAVITY * delta, -25.0)
	else:
		velocity.y = -0.5
	_jump_pending = false
	if _supply_landing is Vector3:
		var remaining := Vector2(_supply_landing.x - position.x, _supply_landing.z - position.z)
		var drift := remaining.limit_length(_leap_speed * delta) / delta
		velocity.x = drift.x
		velocity.z = drift.y
	move_and_slide()
	if _supply_landing is Vector3 and (is_on_floor() or is_on_wall()):
		_supply_landing = null
		_leap_speed = 0.0
		velocity.x = 0.0
		velocity.z = 0.0
	position.x = clampf(position.x, -13.0, 13.0)
	position.z = clampf(position.z, -13.0, 13.0)
	_pace = minf(Vector2(velocity.x, velocity.z).length() / WALK_SPEED, 1.0)

	var held := Input.is_action_pressed("shoot")
	if _press_pending or _repeat_on or (held and not _toggle_fire and not _await_release):
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


func shot_direction(yaw_offset := 0.0) -> Vector3:
	return (-camera.global_basis.z).rotated(camera.global_basis.y, yaw_offset)

func aim_hit(max_distance: float = 50.0, yaw_offset := 0.0) -> Dictionary:
	var origin := camera.global_position
	var endpoint := origin + shot_direction(yaw_offset) * max_distance
	var query := PhysicsRayQueryParameters3D.create(origin, endpoint)
	query.exclude = [get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query)


func arrow_origin() -> Vector3:
	return _nocked.to_global(Vector3(0, 0, -0.57))

func flight_duration(endpoint: Vector3) -> float:
	return clampf(arrow_origin().distance_to(endpoint) / 59.0, 0.045, 0.55)

func play_shot(end_point: Vector3, on_landing := Callable()) -> void:
	_since_shot = 0.0
	_sound.play("shot")
	_flight(arrow_origin(), end_point, flight_duration(end_point), on_landing)

func play_extra_arrow(end_point: Vector3) -> void:
	_flight(arrow_origin(), end_point, flight_duration(end_point), Callable())

func restore_flight(start: Vector3, end: Vector3, total: float, remaining: float) -> void:
	var progress := clampf(1.0 - remaining / maxf(total, 0.001), 0, 1)
	_flight(start.lerp(end, progress), end, remaining, Callable())

func _flight(start: Vector3, end_point: Vector3, duration: float, on_landing: Callable) -> void:
	# The independent projectile survives drawing the last arrow from the quiver.
	var projectile := Node3D.new()
	add_child(projectile)
	projectile.top_level = true
	projectile.global_position = start
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
	flight.tween_property(projectile, "global_position", end_point, duration)
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
	_bow.add_child(_branch_limbs)
	_bow.add_child(_recurve_limbs)
	_bow.add_child(_long_limbs)
	_recurve_limbs.hide()
	_long_limbs.hide()
	# Angular yew limbs, pale end nocks, linen serving and hand-cut leather grip.
	for side in [-1.0, 1.0]:
		var sign_y := float(side)
		var tip := TOP_TIP if sign_y > 0.0 else BOTTOM_TIP
		var inner := Vector3(0, 0.09 * sign_y, 0.0)
		var elbow := Vector3(-0.027, 0.24 * sign_y, -0.012)
		var corner := Vector3(0.008, 0.41 * sign_y, 0.073)
		_rod(_branch_limbs, inner, elbow, 0.050, 0.041, "714729")
		_rod(_branch_limbs, elbow, corner, 0.041, 0.035, "a37142")
		_rod(_branch_limbs, corner, tip, 0.030, 0.028, "bc9360")
		_rod(_branch_limbs, tip.lerp(corner, 0.22), tip, 0.033, 0.033, "e4d8a6")
		_rod(_branch_limbs, elbow + Vector3(-0.011,0,0.021), corner + Vector3(-0.010,0,0.018), 0.008,0.008,"bc8f55")
		var recurve_tip := RECURVE_TOP if sign_y > 0.0 else RECURVE_BOTTOM
		var shoulder := Vector3(-0.035, 0.24 * sign_y, -0.025)
		var camber := Vector3(0.076, 0.43 * sign_y, 0.168)
		_rod(_recurve_limbs, inner, shoulder, 0.074, 0.050, "664631")
		_rod(_recurve_limbs, shoulder, camber, 0.064, 0.038, "bb8f5d")
		_rod(_recurve_limbs, shoulder + Vector3(-0.014,0,0.019), camber + Vector3(-0.014,0,0.019), 0.012,0.009,"e1c18c")
		_rod(_recurve_limbs, camber, recurve_tip, 0.046, 0.034, "d6be85")
		_rod(_recurve_limbs, camber.lerp(shoulder, 0.18), camber, 0.067, 0.042, "456859")
		_rod(_recurve_limbs, recurve_tip.lerp(camber, 0.30), recurve_tip, 0.05, 0.039, "e7e0bf")
		# A tall laminated stave with a dark back, ash belly and brass collars.
		var long_tip := LONG_TOP if sign_y > 0.0 else LONG_BOTTOM
		var heel := Vector3(-0.046, sign_y * 0.27, -0.047)
		var limb := Vector3(-0.026, sign_y * 0.50, 0.027)
		var taper := Vector3(0.018, sign_y * 0.62, 0.135)
		_rod(_long_limbs, inner, heel, 0.087, 0.072, "403e36")
		_rod(_long_limbs, heel, limb, 0.075, 0.059, "825437")
		_rod(_long_limbs, limb, taper, 0.056, 0.044, "a47748")
		_rod(_long_limbs, taper, long_tip, 0.037, 0.033, "cda578")
		var inlay := Vector3(-0.015, 0, 0.036)
		_rod(_long_limbs, inner + inlay, heel + inlay, 0.019, 0.010, "c69f59")
		_rod(_long_limbs, heel + inlay, limb + inlay, 0.013, 0.010, "d8b982")
		_rod(_long_limbs, heel.lerp(limb, 0.10), heel.lerp(limb, 0.24), 0.083, 0.069, "748367")
		_rod(_long_limbs, taper.lerp(long_tip, 0.57), long_tip, 0.042, 0.039, "d7b46e")
	_block(_bow, Vector3.ZERO, Vector3(0.072, 0.20, 0.08), "503929")
	for wrap in range(5):
		var strap := _block(_bow, Vector3(0, -0.078 + 0.038 * wrap, 0), Vector3(0.077, 0.023, 0.084), "885f3a")
		strap.rotation.z = -0.07
	_string_top = _block(_bow, Vector3.ZERO, Vector3(0.0045, 1, 0.0045), "bcae8a")
	_string_bottom = _block(_bow, Vector3.ZERO, Vector3(0.0045, 1, 0.0045), "bcae8a")

	# Grip hand, fingerless glove and the contrasting cuff of the forest archer.
	_rod(_bow, Vector3(0.018, -0.075, 0.028), Vector3(0.17, -0.33, 0.16), 0.107, 0.106, "385747")
	_rod(_bow, Vector3(0.025, -0.097, 0.04), Vector3(0.072, -0.174, 0.082), 0.11, 0.117, "805639")
	_block(_bow, Vector3(0.03, -0.055, 0.034), Vector3(0.093, 0.106, 0.084), "ae7652")
	for finger in range(3):
		_block(_bow, Vector3(-0.002, -0.079 + 0.026 * finger, 0.048), Vector3(0.078, 0.020, 0.034), "dbab7a")

	_bow.add_child(_drawing_hand)
	_rod(_drawing_hand, Vector3(0.033, -0.009, 0.012), Vector3(0.082, -0.049, 0.056), 0.061, 0.063, "774d37")
	_rod(_drawing_hand, Vector3(0.085, -0.047, 0.056), Vector3(0.18, -0.18, 0.15), 0.066, 0.072, "395b4d")
	_rod(_drawing_hand, Vector3(0.077,-0.044,0.048),Vector3(0.098,-0.072,0.072),0.074,0.078,"9b764b")
	for finger in range(2):
		_block(_drawing_hand, Vector3(0.018, 0.003 - 0.025 * finger, -0.005), Vector3(0.066, 0.018, 0.036), "daac7e")
	_bow.add_child(_nocked)
	_arrow_geometry(_nocked, 0.57, false)


func _arrow_geometry(holder: Node3D, length: float, in_flight: bool) -> void:
	# In flight the origin is the tip. On the string the origin is the nock.
	var offset := length if in_flight else 0.0
	var model := MeshInstance3D.new()
	model.mesh = _arrow_mesh()
	model.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	model.scale = Vector3.ONE * length
	model.position.z = offset
	holder.add_child(model)
	if in_flight:
		_block(holder, Vector3(0, 0, offset + 0.067), Vector3(0.008, 0.008, 0.13), "ffe9a2")

func _arrow_mesh() -> ArrayMesh:
	match _equipped:
		"longbow": return LONGBOW_ARROW.mesh()
		"recurve": return RECURVE_ARROW.mesh()
		_: return BRANCH_ARROW.mesh()


func _pose(delta: float) -> void:
	_since_shot = minf(3.0, _since_shot + delta)
	_since_branch = minf(3.0, _since_branch + delta)
	_aim = move_toward(_aim, float(_active and Input.is_action_pressed("aim")), delta * 6.5)
	_sway = _sway.lerp(Vector2.ZERO, 1.0 - exp(-delta * 12.0))
	_step += delta * _pace * 8.5
	var step_sway := Vector2(sin(_step) * 0.012, cos(2.0 * _step) * 0.009) * _pace
	var recoil := sin(_since_shot * 34.0) * exp(-_since_shot * 13.0)
	var swing := sin(minf(_since_branch / 0.28, 1.0) * PI)
	_bow.position = Vector3(0.34 - _aim * 0.13, -0.235 + _aim * 0.06, -0.88)
	if _equipped == "longbow":
		_bow.position.z -= 0.17
	_bow.position += Vector3(step_sway.x - _sway.x, step_sway.y + _sway.y, recoil * 0.05) * _motion_amount
	_bow.position.z -= swing * 0.15
	_bow.rotation = Vector3(0.11 + recoil * 0.085 * _motion_amount, 0.24 - swing * 0.37, 0.17 - _aim * 0.06 + swing * 0.65)
	camera.fov = _base_fov - 12.0 * _zoom_amount * _aim
	var draw := smoothstep(0.09, 0.62 if _equipped == "branch" else 0.35, _since_shot)
	var nock := Vector3(0.026, 0.04, lerpf(0.15, 0.355, draw) + recoil * 0.018)
	var top := TOP_TIP
	var bottom := BOTTOM_TIP
	if _equipped == "recurve":
		top = RECURVE_TOP
		bottom = RECURVE_BOTTOM
	elif _equipped == "longbow":
		top = LONG_TOP
		bottom = LONG_BOTTOM
	_set_rod(_string_top, top, nock)
	_set_rod(_string_bottom, bottom, nock)
	_drawing_hand.position = nock + Vector3(0.042 * (1.0 - draw), -0.045 * (1.0 - draw), recoil * 0.08)
	_nocked.position = nock
	_nocked.visible = _has_arrows and _since_shot > 0.19 and swing < 0.3
