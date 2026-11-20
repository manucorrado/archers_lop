extends Node3D
## Two sawn plates with exposed end grain. Damage separates the faces along the cut.

const HEIGHTS := [-0.91, -0.78, -0.55, -0.29, -0.08, 0.11, 0.36, 0.57, 0.78, 0.92]
const WIDTHS := [0.36, 0.69, 0.87, 1.0, 0.99, 0.99, 0.91, 0.84, 0.69, 0.33]
const SPLIT_X := [-0.16, -0.15, -0.105, -0.17, -0.025, 0.027, -0.034, 0.068, 0.114, 0.18]
const WOOD := Color("#c18b53")
const END_GRAIN := Color("#9f6f49")
const BARK := Color("#67503c")
const DEPTH := Color("#624530")
const SEAM := Color("#483728")
var plates: Array[MeshInstance3D] = []


func _ready() -> void:
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.vertex_color_is_srgb = true
	material.roughness = 1.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	for side in [-1.0, 1.0]:
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		for i in HEIGHTS.size() - 1:
			var lower := _row(i, side)
			var upper := _row(i + 1, side)
			_quad(surface, lower[0], lower[1], upper[1], upper[0], WOOD)
			_quad(surface, lower[1], lower[2], upper[2], upper[1], BARK)
			_quad(surface, lower[0], upper[0], upper[0] - Vector3.BACK * 0.13, lower[0] - Vector3.BACK * 0.13, DEPTH)
		for radius in [0.30, 0.49, 0.72]:
			_grain_ring(surface, radius, side)
		if side < 0:
			_taper(surface, [Vector2(-0.025,-0.08),Vector2(-0.22,0.08),Vector2(-0.31,0.33),Vector2(-0.46,0.46)],0.05)
			_taper(surface, [Vector2(-0.22,0.08),Vector2(-0.36,0.16),Vector2(-0.51,0.15)],0.023)
		else:
			_taper(surface, [Vector2(-0.13,-0.33),Vector2(0.09,-0.26),Vector2(0.23,-0.16),Vector2(0.43,-0.17)],0.042)
			_taper(surface, [Vector2(0.08,0.57),Vector2(0.20,0.67),Vector2(0.28,0.78)],0.027)
		surface.set_material(material)
		var plate := MeshInstance3D.new()
		plate.mesh = surface.commit()
		plates.append(plate)
		add_child(plate)


func set_damage(fraction_lost: float) -> void:
	if plates.size() != 2:
		return
	var spread := 0.007 + 0.043 * fraction_lost
	plates[0].position.x = -spread
	plates[1].position.x = spread
	plates[0].rotation.z = fraction_lost * 0.022
	plates[1].rotation.z = -fraction_lost * 0.017


func _row(i: int, side: float) -> Array[Vector3]:
	var y: float = HEIGHTS[i]
	var half_gap := 0.010 + 0.023 * (y + 1.0)
	return [
		Vector3(SPLIT_X[i] + side * half_gap, y, 0.031),
		Vector3(WIDTHS[i] * side, y, 0.031),
		Vector3((WIDTHS[i] + 0.078) * side, y * 1.045, -0.042)
	]


func _grain_ring(surface: SurfaceTool, radius: float, side: float) -> void:
	# Follow the annual rings on each plate, ending at the torn edges of the split.
	var outline: Array[Vector2] = []
	for i in 11:
		var angle := lerpf(-1.24, 1.31, float(i) / 10.0)
		var irregular := radius * (1.0 + 0.038 * sin(4.0 * angle + 0.7))
		outline.append(Vector2(side * cos(angle) * irregular, sin(angle) * irregular * 0.94 - 0.04))
	for i in outline.size() - 1:
		var a := outline[i]
		var b := outline[i + 1]
		var width := (b - a).normalized().orthogonal() * 0.009
		_quad(surface, Vector3(a.x, a.y, 0.034), Vector3(b.x, b.y, 0.034),
			Vector3(b.x + width.x, b.y + width.y, 0.034), Vector3(a.x + width.x, a.y + width.y, 0.034), END_GRAIN)


func _taper(surface: SurfaceTool, path: Array, width: float) -> void:
	for i in path.size() - 1:
		var a: Vector2 = path[i]
		var b: Vector2 = path[i + 1]
		var outer_a := width * (1.0 - float(i) / (path.size() - 1))
		var outer_b := width * (1.0 - float(i + 1) / (path.size() - 1))
		_quad(surface, Vector3(a.x, a.y, 0.040), Vector3(b.x, b.y, 0.040),
			Vector3(b.x, b.y + outer_b, 0.040), Vector3(a.x, a.y + outer_a, 0.040), SEAM)


func _quad(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, tint: Color) -> void:
	var front: Array[Vector3] = [a, b, c, a, c, d]
	if (b - a).cross(c - a).z > 0:
		front.reverse()
	for vertex in front:
		surface.set_color(tint)
		surface.set_normal(Vector3.BACK)
		surface.add_vertex(vertex)
