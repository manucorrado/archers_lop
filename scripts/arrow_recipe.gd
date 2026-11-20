@tool
extends Resource
## Dimensions are proportions of the arrow's length. The nock is at the origin.

const ForestPalette = preload("res://scripts/forest_palette.gd")
const DEFAULT_PALETTE = preload("res://assets/paleta_claro.tres")

@export_range(0.12, 0.35, 0.01) var largo_pluma := 0.19:
	set(value):
		largo_pluma = value
		_invalidate()
@export_range(0.035, 0.14, 0.005) var ancho_pluma := 0.07:
	set(value):
		ancho_pluma = value
		_invalidate()
@export_range(0.035, 0.095, 0.005) var ancho_punta := 0.065:
	set(value):
		ancho_punta = value
		_invalidate()
@export var paleta: ForestPalette = DEFAULT_PALETTE:
	set(value):
		if paleta and paleta.changed.is_connected(_invalidate):
			paleta.changed.disconnect(_invalidate)
		paleta = value
		if paleta:
			paleta.changed.connect(_invalidate)
		_invalidate()

var _mesh: ArrayMesh

func _invalidate() -> void:
	_mesh = null
	emit_changed()

func mesh() -> ArrayMesh:
	if _mesh:
		return _mesh
	var colors := paleta if paleta else DEFAULT_PALETTE as ForestPalette
	if not colors.changed.is_connected(_invalidate):
		colors.changed.connect(_invalidate)
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var cube := BoxMesh.new().surface_get_arrays(0)
	_box(surface, cube, Vector3(0, 0, -0.52), Vector3(0.023, 0.023, 0.94), colors.madera)
	_box(surface, cube, Vector3(0, 0, -0.035), Vector3(0.034, 0.034, 0.07), colors.ligadura)
	_box(surface, cube, Vector3(0, 0, -0.93), Vector3(ancho_punta, ancho_punta * 0.62, 0.10), colors.piedra)
	_box(surface, cube, Vector3(0, 0, -0.985), Vector3(ancho_punta * 0.48, ancho_punta * 0.4, 0.03), colors.piedra.lightened(0.16))
	for step in 3:
		var span := ancho_pluma * (1.0 - step * 0.25)
		var z := -0.055 - largo_pluma * (step + 0.5) / 3.0
		_box(surface, cube, Vector3(0, 0, z), Vector3(0.014, span * 2, largo_pluma / 3.0), colors.pluma)
		_box(surface, cube, Vector3(0, 0, z), Vector3(span * 2, 0.014, largo_pluma / 3.0), colors.pluma.darkened(0.13))
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.vertex_color_is_srgb = true
	material.roughness = 1.0
	surface.set_material(material)
	_mesh = surface.commit()
	return _mesh

func _box(surface: SurfaceTool, cube: Array, center: Vector3, size: Vector3, color: Color) -> void:
	var vertices: PackedVector3Array = cube[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = cube[Mesh.ARRAY_NORMAL]
	for i in cube[Mesh.ARRAY_INDEX]:
		surface.set_color(color)
		surface.set_normal(normals[i])
		surface.add_vertex(center + vertices[i] * size)
