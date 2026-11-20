@tool
extends Node3D
## Visual recipe. Edit the root of pino.tscn in the Inspector to preview a variant.

@export_group("Silueta")
@export_range(0, 9999) var semilla := 31:
	set(value):
		semilla = value
		_request_rebuild()
@export_range(2.0, 8.0, 0.1, "suffix:m") var altura := 4.5:
	set(value):
		altura = value
		_request_rebuild()
@export_range(0.5, 1.6, 0.05) var anchura := 1.0:
	set(value):
		anchura = value
		_request_rebuild()
@export_group("Paleta")
@export var corteza := Color("#604737"):
	set(value):
		corteza = value
		_request_rebuild()
@export var follaje := Color("#42664b"):
	set(value):
		follaje = value
		_request_rebuild()
@export var brotes := Color("#719362"):
	set(value):
		brotes = value
		_request_rebuild()

var pending := false


func _ready() -> void:
	_rebuild()


func _request_rebuild() -> void:
	if is_inside_tree() and not pending:
		pending = true
		_rebuild.call_deferred()


func _rebuild() -> void:
	pending = false
	var rng := RandomNumberGenerator.new()
	rng.seed = semilla
	var mesh_view := get_node_or_null("Copa") as MeshInstance3D
	if not mesh_view:
		mesh_view = MeshInstance3D.new()
		mesh_view.name = "Copa"
		add_child(mesh_view)
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var cube := BoxMesh.new()
	var box := cube.surface_get_arrays(0)
	var unit := altura / 32.0
	_box(surface, box, Vector3(0, 12, 0) * unit, Vector3(3, 24, 3) * unit, corteza)
	for tier in 4:
		var width := (17.0 - 4.0 * tier) * anchura
		var center := Vector3(rng.randi_range(-1, 1), 10 + 5 * tier, rng.randi_range(-1, 1))
		var shade := follaje.lerp(brotes, tier * 0.12)
		_box(surface, box, center * unit, Vector3(width, 5, width * 0.73) * unit, shade)
		_box(surface, box, center * unit, Vector3(width * 0.70, 5, width) * unit, shade)
		_box(surface, box, (center + Vector3.UP * 3.0) * unit,
			Vector3(width * 0.60, 2, width * 0.68) * unit, shade.lerp(brotes, 0.28))
	_box(surface, box, Vector3(0, 29.5, 0) * unit, Vector3(2, 5, 2) * unit, brotes)
	var palette := StandardMaterial3D.new()
	palette.vertex_color_use_as_albedo = true
	palette.vertex_color_is_srgb = true
	palette.roughness = 1.0
	surface.set_material(palette)
	mesh_view.mesh = surface.commit()


func _box(surface: SurfaceTool, cube: Array, center: Vector3, size: Vector3, color: Color) -> void:
	var vertices: PackedVector3Array = cube[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = cube[Mesh.ARRAY_NORMAL]
	var indices: PackedInt32Array = cube[Mesh.ARRAY_INDEX]
	for index in indices:
		surface.set_color(color)
		surface.set_normal(normals[index])
		surface.add_vertex(center + vertices[index] * size)
