extends StaticBody3D
## Mounted crossbow and its physical magazine. Combat and inventory live in Run.

const SITE := Vector3(4.1, 0, 3.5)
const REACH := 2.1
const Blocks = preload("res://scripts/voxel_blocks.gd")
const CueAudio = preload("res://scripts/bow_audio.gd")
const ARROW := preload("res://assets/flecha.tres")
const WOOD := Color("#976442")
const BARK := Color("#533e32")
const END_GRAIN := Color("#dbac70")
const IRON := Color("#586b69")
const BRASS := Color("#d5a953")

var _carriage := Node3D.new()
var _arm := Node3D.new()
var _flag := Node3D.new()
var _bolts: Array[MeshInstance3D] = []
var _nocked := MeshInstance3D.new()
var _sounds := {}
var _recoil: Tween
var _load_tween: Tween
var _volume := 1.0

func build(cube: BoxMesh, capacity: int) -> void:
	name = "BallestaDelClaro"
	position = SITE
	var footing := Blocks.new()
	for side in [-1.0, 1.0]:
		for end in [-1.0, 1.0]:
			var foot := Vector3(side * 0.40, 0.12, end * 0.34)
			footing.box(foot, Vector3(0.30, 0.20, 0.32), IRON)
			footing.beam(foot, Vector3(side * 0.21, 0.90, end * 0.20), 0.20, 0.18, WOOD)
	footing.box(Vector3(0, 0.87, 0), Vector3(0.78, 0.20, 0.67), BARK)
	footing.box(Vector3(0, 1.01, 0), Vector3(0.48, 0.13, 0.48), BRASS)
	footing.box(Vector3(0.69, 0.58, 0.03), Vector3(0.62, 0.20, 0.61), WOOD)
	for side in [-1.0, 1.0]:
		footing.box(Vector3(0.69 + side * 0.32, 0.78, 0.03), Vector3(0.07, 0.44, 0.68), BARK)
		footing.box(Vector3(0.69, 0.74, 0.03 + side * 0.31), Vector3(0.62, 0.22, 0.05), END_GRAIN)
	footing.bake(self, cube, "Banco y depósito")
	_carriage.position.y = 1.15
	add_child(_carriage)
	_carriage.add_child(_arm)
	var stock := Blocks.new()
	stock.box(Vector3(0, 0, 0), Vector3(0.22, 0.24, 1.42), WOOD)
	stock.box(Vector3(0, 0.13, -0.16), Vector3(0.12, 0.05, 1.05), IRON)
	stock.box(Vector3(0, 0.05, 0.56), Vector3(0.30, 0.27, 0.24), END_GRAIN)
	for side in [-1.0, 1.0]:
		var elbow := Vector3(side * 0.65, 0.09, -0.41)
		var tip := Vector3(side * 1.03, 0.14, -0.14)
		stock.beam(Vector3(0, 0.06, -0.61), elbow, 0.15, 0.17, WOOD)
		stock.beam(elbow, tip, 0.09, 0.12, END_GRAIN)
		stock.beam(tip, Vector3(0, 0.16, 0.34), 0.025, 0.025, IRON)
		stock.box(elbow, Vector3(0.11, 0.18, 0.19), BRASS)
	stock.bake(_arm, cube, "Arco montado")
	_nocked.mesh = ARROW.mesh()
	_nocked.position = Vector3(0, 0.20, 0.42)
	_nocked.scale = Vector3.ONE * 0.88
	_arm.add_child(_nocked)
	for slot in capacity:
		var bolt := MeshInstance3D.new()
		bolt.mesh = _nocked.mesh
		bolt.position = Vector3(0.46 + (slot % 4) * 0.15, 1.28, -0.17 + floori(slot / 4.0) * 0.16)
		bolt.rotation.x = -1.43
		bolt.scale = Vector3.ONE * 0.68
		add_child(bolt)
		_bolts.append(bolt)
	_flag.position = Vector3(1.03, 0.81, 0.28)
	add_child(_flag)
	var signal_flag := Blocks.new()
	signal_flag.box(Vector3(0, 0.23, 0), Vector3(0.06, 0.52, 0.06), BRASS)
	signal_flag.box(Vector3(0.12, 0.38, 0), Vector3(0.23, 0.19, 0.042), END_GRAIN)
	signal_flag.box(Vector3(0.10, 0.38, 0.024), Vector3(0.048, 0.10, 0.012), BARK)
	signal_flag.bake(_flag, cube, "Señal de carga")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.50, 1.28, 0.93)
	shape.position = Vector3(0.20, 0.64, 0)
	shape.shape = box
	add_child(shape)
	var synth := CueAudio.new()
	for cue: String in ["shot", "load", "empty"]:
		var speaker := AudioStreamPlayer3D.new()
		if cue == "load":
			speaker.stream = preload("res://assets/audio/freesound/atado_toque.wav")
		else:
			speaker.stream = synth._make_clip(cue, CueAudio.LENGTHS[cue])
		speaker.position.y = 1.0
		speaker.unit_size = 7.0
		speaker.pitch_scale = 0.72 if cue == "shot" else 0.83
		add_child(speaker)
		_sounds[cue] = speaker
	synth.free()
	set_volume(_volume)
	sync_state(false, 0, false, Vector3.ZERO)

func sync_state(owned: bool, ammo: int, has_target: bool, target: Vector3) -> void:
	visible = owned
	collision_layer = 1 if owned else 0
	if not owned:
		return
	if has_target:
		_carriage.look_at(target)
	for i in _bolts.size():
		_bolts[i].visible = i < ammo
	_nocked.visible = ammo > 0
	_flag.rotation.z = -1.50 if ammo == 0 else (-0.75 if not has_target else 0.0)

func is_within_reach(point: Vector3) -> bool:
	return visible and Vector2(point.x - position.x, point.z - position.z).length() <= REACH

func release(target: Vector3, last: bool) -> Vector3:
	_carriage.look_at(target)
	var origin := _arm.to_global(Vector3(0, 0.20, -0.75))
	if _recoil:
		_recoil.kill()
	_arm.position.z = 0.13
	_recoil = create_tween()
	_recoil.tween_property(_arm, "position:z", 0.0, 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_sound("shot")
	if last:
		_recoil.tween_callback(_sound.bind("empty"))
	return origin

func receive() -> void:
	if _load_tween:
		_load_tween.kill()
	_flag.position.y = 0.72
	_load_tween = create_tween()
	_load_tween.tween_property(_flag, "position:y", 0.81, 0.26)
	_sound("load")

func set_volume(value: float) -> void:
	_volume = value
	for speaker: AudioStreamPlayer3D in _sounds.values():
		speaker.volume_db = -9.0 + linear_to_db(maxf(_volume, 0.00001))

func _sound(cue: String) -> void:
	if _volume > 0.0:
		_sounds[cue].play()
