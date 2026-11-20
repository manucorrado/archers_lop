@tool
extends Node3D
## Readable at pickup distance. Geometry and recipe have no gameplay state.

const ArrowRecipe = preload("res://scripts/arrow_recipe.gd")
const DEFAULT_ARROW = preload("res://assets/flecha.tres")

@export_group("Silueta")
@export_enum("Pequeño:3", "Mediano:5", "Grande:8") var flechas := 3:
	set(value):
		flechas = value
		_queue_build()
@export_range(0.25, 1.4, 0.05) var apertura := 0.75:
	set(value):
		apertura = value
		_queue_build()
@export_range(0.6, 1.3, 0.05, "suffix:m") var longitud := 0.80:
	set(value):
		longitud = value
		_queue_build()
@export var receta: ArrowRecipe = DEFAULT_ARROW:
	set(value):
		if receta and receta.changed.is_connected(_queue_build):
			receta.changed.disconnect(_queue_build)
		receta = value
		if receta:
			receta.changed.connect(_queue_build)
		_queue_build()

var _pending := false
var _stems: MultiMeshInstance3D
var _band: MeshInstance3D

func _ready() -> void:
	_build()

func _queue_build() -> void:
	if is_inside_tree() and not _pending:
		_pending = true
		_build.call_deferred()

func _build() -> void:
	_pending = false
	var arrow := receta if receta else DEFAULT_ARROW as ArrowRecipe
	if not arrow.changed.is_connected(_queue_build):
		arrow.changed.connect(_queue_build)
	if not _stems:
		_stems = MultiMeshInstance3D.new()
		_stems.name = "Flechas"
		add_child(_stems)
		_band = MeshInstance3D.new()
		_band.name = "Ligadura"
		_band.mesh = BoxMesh.new()
		_band.material_override = StandardMaterial3D.new()
		add_child(_band)
	var batch := MultiMesh.new()
	batch.transform_format = MultiMesh.TRANSFORM_3D
	batch.mesh = arrow.mesh()
	batch.instance_count = flechas
	for i in flechas:
		var spread := float(i) / maxf(flechas - 1, 1.0) - 0.5
		var tip := Vector3(spread * 0.21, 0.035, (i % 2) * 0.04)
		var axis := Vector3(spread * apertura, 0.85 + 0.04 * (i % 3), -0.47).normalized()
		var basis_fletching := Basis.looking_at(-axis, Vector3.UP)
		batch.set_instance_transform(i, Transform3D(basis_fletching.scaled(Vector3.ONE * longitud), tip + axis * longitud))
	_stems.multimesh = batch
	_band.position = Vector3(0, longitud * 0.29, -longitud * 0.15)
	_band.rotation.x = -0.48
	_band.scale = Vector3(0.23 + apertura * longitud * 0.28, 0.065, 0.10)
	(_band.material_override as StandardMaterial3D).albedo_color = arrow.paleta.ligadura if arrow.paleta else Color("#557167")
