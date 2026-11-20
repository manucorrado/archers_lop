@tool
extends Node3D
## Visual recipe. Edit the root of pino.tscn in the Inspector to preview a variant.

const ForestPalette = preload("res://scripts/forest_palette.gd")
const DEFAULT_PALETTE = preload("res://assets/paleta_claro.tres")

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
@export_range(3, 6) var pisos := 4:
	set(value):
		pisos = value
		_request_rebuild()
@export_range(-0.4, 0.4, 0.05) var inclinacion := 0.0:
	set(value):
		inclinacion = value
		_request_rebuild()
@export_group("Paleta")
@export var paleta: ForestPalette = DEFAULT_PALETTE:
	set(value):
		if paleta and paleta.changed.is_connected(_request_rebuild):
			paleta.changed.disconnect(_request_rebuild)
		paleta = value
		if paleta:
			paleta.changed.connect(_request_rebuild)
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
	var colors := paleta if paleta else DEFAULT_PALETTE as ForestPalette
	if not colors.changed.is_connected(_request_rebuild):
		colors.changed.connect(_request_rebuild)
	_box(surface, box, Vector3(0, 12, 0) * unit, Vector3(3, 24, 3) * unit, colors.corteza)
	for tier in pisos:
		var fraction := float(tier) / float(pisos - 1)
		var width := lerpf(17.0, 5.0, fraction) * anchura
		var center := Vector3(rng.randi_range(-1, 1) + inclinacion * fraction * 11, 10 + 15 * fraction, rng.randi_range(-1, 1))
		var shade := colors.follaje.lerp(colors.brotes, fraction * 0.36)
		_box(surface, box, center * unit, Vector3(width, 5, width * 0.73) * unit, shade)
		_box(surface, box, center * unit, Vector3(width * 0.70, 5, width) * unit, shade)
		_box(surface, box, (center + Vector3.UP * 3.0) * unit,
			Vector3(width * 0.60, 2, width * 0.68) * unit, shade.lerp(colors.brotes, 0.28))
	_box(surface, box, Vector3(inclinacion * 11, 29.5, 0) * unit, Vector3(2, 5, 2) * unit, colors.brotes)
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
