@tool
extends Node3D
## Seated shepherd. Local +Z is the muzzle; head and tail have independent pivots.

const Blocks = preload("res://scripts/voxel_blocks.gd")
const COAT := Color("#a26538")
const RUST := Color("#bd7942")
const FAWN := Color("#d59a5d")
const CREAM := Color("#e7bd84")
const SADDLE := Color("#5d4233")
const MASK := Color("#473833")
const NOSE := Color("#302e2c")
const SCARF := Color("#507d70")

var _head := Node3D.new()
var _tail := Node3D.new()
var _time := 0.0
var _happy := 0.0
var _delight := 0.0
var _wag_phase := 0.0

func _ready() -> void:
	var cube := BoxMesh.new()
	var coat := StandardMaterial3D.new()
	coat.vertex_color_use_as_albedo = true
	coat.vertex_color_is_srgb = true
	coat.roughness = 1.0
	cube.material = coat
	var body := Blocks.new()
	# A sloping saddle above the seated haunches, with the chest proud of the forelegs.
	body.beam(Vector3(0, 0.28, -0.20), Vector3(0, 0.67, 0.12), 0.32, 0.37, COAT)
	body.beam(Vector3(0, 0.39, -0.26), Vector3(0, 0.72, 0.055), 0.30, 0.20, SADDLE)
	body.box(Vector3(0, 0.52, 0.15), Vector3(0.33, 0.32, 0.27), RUST)
	body.box(Vector3(0, 0.56, 0.265), Vector3(0.245, 0.24, 0.10), FAWN)
	body.box(Vector3(0, 0.405, 0.255), Vector3(0.14, 0.11, 0.09), CREAM)
	for side: float in [-1, 1]:
		var hip := Vector3(side * 0.17, 0.235, -0.165)
		body.box(hip, Vector3(0.19, 0.31, 0.33), COAT, Vector3(0.18, 0, -0.08 * side))
		body.beam(hip + Vector3(0, 0.012, 0.05), Vector3(side * 0.22, 0.105, -0.30), 0.138, 0.17, RUST)
		body.box(Vector3(side * 0.223, 0.066, -0.15), Vector3(0.13, 0.115, 0.26), FAWN)
		body.beam(Vector3(side * 0.128, 0.47, 0.175), Vector3(side * 0.148, 0.115, 0.225), 0.095, 0.103, FAWN)
		body.box(Vector3(side * 0.15, 0.060, 0.258), Vector3(0.119, 0.105, 0.18), CREAM)
		body.box(Vector3(side * 0.15, 0.045, 0.348), Vector3(0.017, 0.048, 0.006), COAT)
	# A forest-green neckerchief, with a folded corner and a brass tag.
	body.box(Vector3(0, 0.676, 0.125), Vector3(0.345, 0.072, 0.322), SCARF, Vector3(-0.12, 0, 0))
	body.box(Vector3(-0.035, 0.628, 0.286), Vector3(0.115, 0.108, 0.034), SCARF, Vector3(-0.18, 0, 0.59))
	body.box(Vector3(0.079, 0.649, 0.300), Vector3(0.048, 0.053, 0.019), Color("#e5b765"))
	body.bake(self, cube, "Pelaje y pañuelo")

	_head.name = "Cabeza"
	_head.position = Vector3(0, 0.705, 0.134)
	add_child(_head)
	var face := Blocks.new()
	face.box(Vector3(0, 0.115, 0.015), Vector3(0.30, 0.235, 0.255), RUST)
	face.box(Vector3(0, 0.212, -0.002), Vector3(0.242, 0.091, 0.223), COAT)
	for side: float in [-1, 1]:
		face.box(Vector3(side * 0.12, 0.063, 0.112), Vector3(0.102, 0.108, 0.132), FAWN)
		face.box(Vector3(side * 0.113, 0.114, 0.13), Vector3(0.082, 0.065, 0.092), MASK)
		face.box(Vector3(side * 0.108, 0.133, 0.18), Vector3(0.039, 0.040, 0.017), NOSE)
		face.box(Vector3(side * 0.101, 0.142, 0.19), Vector3(0.013, 0.013, 0.004), Color("#fff0d2"))
		face.box(Vector3(side * 0.10, 0.183, 0.143), Vector3(0.069, 0.027, 0.035), FAWN)
		# Stepped taper, visible ear lining and darker tips convey upright shepherd ears.
		face.box(Vector3(side * 0.115, 0.247, -0.038), Vector3(0.108, 0.115, 0.095), COAT)
		face.box(Vector3(side * 0.130, 0.322, -0.047), Vector3(0.081, 0.088, 0.073), COAT)
		face.box(Vector3(side * 0.141, 0.378, -0.057), Vector3(0.052, 0.058, 0.050), SADDLE)
		face.box(Vector3(side * 0.148, 0.414, -0.064), Vector3(0.029, 0.030, 0.033), MASK)
		face.box(Vector3(side * 0.118, 0.266, 0.013), Vector3(0.066, 0.061, 0.014), Color("#b78064"))
		face.box(Vector3(side * 0.133, 0.316, -0.007), Vector3(0.042, 0.053, 0.015), Color("#ab735b"))
	face.box(Vector3(0, 0.109, 0.134), Vector3(0.107, 0.089, 0.108), SADDLE)
	face.box(Vector3(0, 0.065, 0.218), Vector3(0.153, 0.086, 0.149), MASK)
	face.box(Vector3(0, 0.080, 0.281), Vector3(0.126, 0.063, 0.057), NOSE)
	face.box(Vector3(0, 0.010, 0.206), Vector3(0.119, 0.045, 0.125), FAWN)
	face.bake(_head, cube, "Orejas y hocico")

	_tail.name = "Cola"
	_tail.position = Vector3(0.11, 0.26, -0.285)
	add_child(_tail)
	var plume := Blocks.new()
	plume.beam(Vector3.ZERO, Vector3(0.10, -0.11, -0.17), 0.11, 0.13, SADDLE)
	plume.beam(Vector3(0.10, -0.11, -0.17), Vector3(0.23, -0.16, -0.29), 0.14, 0.14, COAT)
	plume.beam(Vector3(0.23, -0.16, -0.29), Vector3(0.36, -0.17, -0.24), 0.095, 0.105, RUST)
	plume.bake(_tail, cube, "Cola tupida")

func pet() -> void:
	_happy = 2.2

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_time = fmod(_time + delta, TAU * 40.0)
	_happy = maxf(0, _happy - delta)
	_delight = move_toward(_delight, smoothstep(0, 1.2, _happy), 4.5 * delta)
	_wag_phase = fmod(_wag_phase + delta * lerpf(2.0, 13.0, _delight), TAU)
	_tail.rotation.y = sin(_wag_phase) * lerpf(0.11, 0.69, _delight)
	_tail.rotation.x = -0.36 * _delight
	_head.rotation.x = 0.035 * sin(_time * 1.5) - _delight * 0.13
	_head.rotation.z = 0.022 * sin(_time * 0.75) + _delight * 0.18
