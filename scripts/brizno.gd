@tool
extends Node3D
## Little winged forest courier. The face points toward local +Z.

const Blocks := preload("res://scripts/voxel_blocks.gd")
const DOWN := Color("#eee3c9")
const PAW := Color("#c7ae87")
const INK := Color("#393a34")
const PINK := Color("#cf866e")
const LEAF := Color("#477868")
const VEIN := Color("#95ad77")
const SATCHEL := Color("#9d5a38")
const AMBER := Color("#e7a248")

var _body := Node3D.new()
var _wings: Array[Node3D] = []
var _elapsed := 0.0

func _ready() -> void:
	var cube := BoxMesh.new()
	var paint := StandardMaterial3D.new()
	paint.vertex_color_use_as_albedo = true
	paint.vertex_color_is_srgb = true
	paint.roughness = 1.0
	cube.material = paint
	add_child(_body)
	var fur := Blocks.new()
	fur.box(Vector3(0, 0.48, 0), Vector3(0.47, 0.42, 0.40), DOWN)
	fur.box(Vector3(0, 0.38, 0.025), Vector3(0.39, 0.28, 0.41), DOWN.darkened(0.06))
	for side: float in [-1, 1]:
		fur.box(Vector3(side * 0.154, 0.20, 0.08), Vector3(0.146, 0.12, 0.22), PAW)
		fur.box(Vector3(side * 0.26, 0.48, 0.05), Vector3(0.12, 0.23, 0.15), DOWN, Vector3(0, 0, side * 0.20))
	# A scarf, a diagonal leather strap, and letters folded into its open bag.
	fur.box(Vector3(0, 0.666, 0), Vector3(0.482, 0.09, 0.425), LEAF)
	fur.box(Vector3(-0.14, 0.596, 0.215), Vector3(0.087, 0.13, 0.036), LEAF, Vector3(-0.12, 0, -0.26))
	fur.beam(Vector3(-0.15, 0.646, 0.215), Vector3(0.21, 0.37, 0.23), 0.05, 0.03, SATCHEL)
	fur.box(Vector3(0.21, 0.36, 0.18), Vector3(0.23, 0.19, 0.12), SATCHEL)
	fur.box(Vector3(0.20, 0.45, 0.17), Vector3(0.17, 0.06, 0.047), Color("#f3ddab"), Vector3(0.12, 0, 0.08))
	fur.box(Vector3(0.21, 0.37, 0.249), Vector3(0.036, 0.035, 0.016), AMBER)
	fur.box(Vector3(0, 0.92, 0.04), Vector3(0.56, 0.32, 0.43), DOWN)
	fur.box(Vector3(0, 0.756, 0.038), Vector3(0.46, 0.075, 0.382), DOWN)
	fur.box(Vector3(0, 1.09, 0.026), Vector3(0.45, 0.08, 0.36), DOWN)
	for side: float in [-1, 1]:
		# High, tufted ears; the inner step stays visible in silhouette.
		fur.box(Vector3(side * 0.21, 1.13, 0), Vector3(0.14, 0.18, 0.138), DOWN, Vector3(0, 0, -side * 0.34))
		fur.box(Vector3(side * 0.25, 1.216, -0.004), Vector3(0.085, 0.125, 0.11), PAW, Vector3(0, 0, -side * 0.34))
		fur.box(Vector3(side * 0.224, 1.146, 0.07), Vector3(0.068, 0.136, 0.015), PINK, Vector3(0, 0, -side * 0.34))
		fur.box(Vector3(side * 0.16, 0.929, 0.258), Vector3(0.06, 0.081, 0.018), INK)
		fur.box(Vector3(side * 0.152, 0.946, 0.269), Vector3(0.016, 0.022, 0.008), Color.WHITE)
		fur.box(Vector3(side * 0.202, 0.854, 0.26), Vector3(0.092, 0.032, 0.012), PINK)
	fur.box(Vector3(0, 0.837, 0.254), Vector3(0.20, 0.09, 0.10), Color("#f5e8ce"))
	fur.box(Vector3(0, 0.88, 0.293), Vector3(0.075, 0.047, 0.047), Color("#705647"))
	fur.box(Vector3(0.011, 0.818, 0.307), Vector3(0.046, 0.011, 0.010), PAW, Vector3(0, 0, 0.07))
	# A sprung twig with an amber seed and two seed scales.
	fur.beam(Vector3(0.02, 1.12, -0.03), Vector3(0.00, 1.31, -0.03), 0.028, 0.028, SATCHEL)
	fur.beam(Vector3(0.00, 1.31, -0.03), Vector3(-0.105, 1.365, -0.01), 0.026, 0.026, SATCHEL)
	fur.box(Vector3(-0.15, 1.37, 0.0), Vector3(0.15, 0.14, 0.15), AMBER, Vector3(0, 0.25, -0.28))
	fur.box(Vector3(-0.16, 1.39, 0.065), Vector3(0.077, 0.06, 0.025), Color("#f5c36c"))
	fur.box(Vector3(-0.115, 1.445, -0.02), Vector3(0.093, 0.042, 0.084), LEAF, Vector3(0, 0, 0.46))
	fur.bake(_body, cube, "Pelaje y bolsa de cartas")
	for side: float in [-1, 1]:
		var pivot := Node3D.new()
		pivot.position = Vector3(side * 0.175, 0.60, -0.155)
		_body.add_child(pivot)
		var wing := Blocks.new()
		wing.box(Vector3(side * 0.15, 0.05, -0.073), Vector3(0.31, 0.18, 0.062), LEAF.darkened(0.08), Vector3(0, side * 0.37, side * 0.53))
		for feather in 3:
			var root := Vector3(0.015 * side, -0.077 * feather, 0)
			var tip := Vector3(side * (0.39 - 0.071 * feather), 0.28 - 0.144 * feather, -0.145)
			wing.beam(root, tip, 0.11, 0.055, LEAF.lightened(0.065 * feather))
		wing.beam(Vector3(0, 0, 0.028), Vector3(side * 0.34, 0.236, -0.109), 0.030, 0.026, VEIN)
		wing.bake(pivot, cube, "Ala de hoja")
		_wings.append(pivot)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_elapsed = fmod(_elapsed + delta, TAU * 30)
	_body.position.y = 0.025 * sin(_elapsed * 2.0)
	for i in _wings.size():
		_wings[i].rotation.y = sin(_elapsed * 4.0) * (0.16 if i == 0 else -0.16)
