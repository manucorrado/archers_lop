extends Node3D

const TARGET_POSITION := Vector3(0.0, 1.65, -5.0)
const WORKSHOP_PICKUP := Vector3(-3.6, 0.0, 0.15)
const KNOT_PICKUP := Vector3(0.9, 0.0, -2.85)
const WORKSHOP_BASE := Vector3(-4.3, 0.0, -1.15)
const PALETTE_PINE := preload("res://assets/pino.tscn")

const BARK := Color("#533e32")
const WOOD := Color("#976442")
const CUT := Color("#c79258")
const SAP := Color("#ffb641")
const FEATHER := Color("#fff0bb")
const MOSS := Color("#75845a")
const STONE := Color("#788176")

# Bake boxes with per-instance colors. A complete tree line or landmark takes
# one draw batch and all share one palette material, including the pickup LODs.
class Blocks:
	var poses: Array[Transform3D] = []
	var tones: Array[Color] = []

	func box(center: Vector3, size: Vector3, tone: Color, angles := Vector3.ZERO) -> void:
		var orientation := Basis.from_euler(angles)
		poses.append(Transform3D(orientation.scaled_local(size), center))
		tones.append(tone)

	func beam(a: Vector3, b: Vector3, width: float, depth: float, tone: Color) -> void:
		var direction := b - a
		var orientation := Basis(Quaternion(Vector3.UP, direction.normalized()))
		poses.append(Transform3D(orientation.scaled_local(Vector3(width, direction.length(), depth)), (a + b) * 0.5))
		tones.append(tone)

	func bake(parent: Node3D, unit_cube: BoxMesh, label: String, shadows := true) -> MultiMeshInstance3D:
		var multi := MultiMesh.new()
		multi.transform_format = MultiMesh.TRANSFORM_3D
		multi.use_colors = true
		multi.mesh = unit_cube
		multi.instance_count = poses.size()
		for index in poses.size():
			multi.set_instance_transform(index, poses[index])
			multi.set_instance_color(index, tones[index])
		var result := MultiMeshInstance3D.new()
		result.name = label
		result.multimesh = multi
		if not shadows:
			result.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		parent.add_child(result)
		return result

var _cube := BoxMesh.new()
var _rng := RandomNumberGenerator.new()
var _knot := StaticBody3D.new()
var _knot_geometry: Node3D
var _knot_collision := BoxShape3D.new()
var _knot_collider := CollisionShape3D.new()
var _workshop := Node3D.new()
var _workshop_collision: CollisionShape3D
var _footings := Node3D.new()
var _wheel := Node3D.new()
var _tray := Node3D.new()
var _workshop_piles: Array[Node3D] = []
var _knot_piles: Array[Node3D] = []
var _chip_mesh := BoxMesh.new()
var _stage := 0
var _built := false
var _wheel_time := 0.0

func _ready() -> void:
	_rng.seed = 32817
	var palette := StandardMaterial3D.new()
	palette.vertex_color_use_as_albedo = true
	palette.vertex_color_is_srgb = true
	palette.roughness = 1.0
	_cube.material = palette
	var chip_material := StandardMaterial3D.new()
	chip_material.albedo_color = SAP
	_chip_mesh.material = chip_material
	_setup_light()
	_make_landscape()
	_make_collisions()
	_make_workshop()
	_make_pile_models(WORKSHOP_PICKUP, _workshop_piles)
	_make_pile_models(KNOT_PICKUP, _knot_piles)
	_knot.name = "Nudo"
	_knot.position = Vector3(TARGET_POSITION.x, 0, TARGET_POSITION.z)
	add_child(_knot)
	_knot.add_to_group("knot")
	_knot_collider.shape = _knot_collision
	_knot.add_child(_knot_collider)
	set_stage(1)
	set_workshop(false)
	set_piles(0, 0)

func _setup_light() -> void:
	var sky_colors := ProceduralSkyMaterial.new()
	sky_colors.sky_top_color = Color("#568797")
	sky_colors.sky_horizon_color = Color("#cddacb")
	sky_colors.ground_horizon_color = sky_colors.sky_horizon_color
	sky_colors.ground_bottom_color = Color("#8b987a")
	sky_colors.sky_curve = 0.27
	var sky := Sky.new()
	sky.sky_material = sky_colors
	var atmosphere := Environment.new()
	atmosphere.background_mode = Environment.BG_SKY
	atmosphere.sky = sky
	atmosphere.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	atmosphere.ambient_light_sky_contribution = 0.0
	atmosphere.ambient_light_color = Color("#c7d4cc")
	atmosphere.ambient_light_energy = 0.48
	atmosphere.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	atmosphere.fog_enabled = true
	atmosphere.fog_light_color = Color("#b4c5bf")
	atmosphere.fog_density = 0.007
	atmosphere.fog_sky_affect = 0.12
	var world_light := WorldEnvironment.new()
	world_light.environment = atmosphere
	add_child(world_light)
	var sun := DirectionalLight3D.new()
	sun.light_color = Color("#fff0d8")
	sun.light_energy = 0.65
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 40.0
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	add_child(sun)
	sun.look_at_from_position(Vector3(-11, 16, 9), Vector3.ZERO)

func _make_landscape() -> void:
	var terrain := Blocks.new()
	terrain.box(Vector3(0, -0.27, 0), Vector3(142, 0.54, 142), Color("#859264"))
	# Broken edges of a packed-earth firing path. Heights stay below ankle level.
	for index in range(58):
		var z := _rng.randf_range(-7.0, 8.5)
		var x := sin(z * 0.5) * 0.42 + _rng.randf_range(-1.35, 1.35)
		terrain.box(Vector3(x, 0.009 + float(index) * 0.0005, z), Vector3(_rng.randf_range(0.6, 2.1), 0.018, _rng.randf_range(0.65, 1.6)), Color("#b19f76").lerp(Color("#c2ae80"), _rng.randf()))
	for index in 19:
		var along := _rng.randf()
		var point := Vector3(-0.7, 0.021, 2.5).lerp(WORKSHOP_PICKUP, along)
		point.x += _rng.randf_range(-0.36, 0.36)
		point.z += _rng.randf_range(-0.4, 0.4)
		point.y = 0.04 + float(index) * 0.0005
		terrain.box(point, Vector3(0.85, 0.016, 0.7), Color("#ab9d72"))
	# Wood and stone rails indicate the edge of the playable clearing.
	for side in [-1, 1]:
		for index in range(7):
			var z := -10.3 + index * 3.6
			var post := Vector3(10.15 * side, 0.0, z)
			terrain.box(post + Vector3(0, 0.52, 0), Vector3(0.28, 1.04, 0.34), BARK)
			terrain.box(post + Vector3(0, 1.06, 0), Vector3(0.30, 0.08, 0.36), CUT)
			if index < 6:
				terrain.beam(post + Vector3(0, 0.67, 0), post + Vector3(0, 0.55, 3.60), 0.14, 0.14, WOOD)
	for side in [-1, 1]:
		for index in range(11):
			var base := Vector3(-9.8 + index * 2.0, 0.0, 11.35 * side)
			_rock(terrain, base, _rng.randf_range(0.45, 0.78))
	# A weathered reference stone to judge the size of each successive knot.
	terrain.box(Vector3(2.5, 0.43, -4.1), Vector3(0.67, 0.86, 0.62), STONE)
	terrain.box(Vector3(2.46, 0.93, -4.12), Vector3(0.51, 0.17, 0.52), Color("#a3a88b"))
	for index in range(3):
		terrain.box(Vector3(2.52, 0.23 + index * 0.20, -3.783), Vector3(0.28 - index * 0.045, 0.045, 0.035), Color("#515c53"))
	# Grass, small wildflowers and stones stay on the shoulders of the lane.
	for index in range(270):
		var point := Vector3(_rng.randf_range(-13, 13), 0, _rng.randf_range(-13, 12))
		if absf(point.x) < 2.1 and point.z > -7.0:
			continue
		if point.distance_to(WORKSHOP_BASE) < 2.2 or point.distance_to(WORKSHOP_PICKUP) < 1.45:
			continue
		var tone := MOSS.lerp(Color("#9ba46c"), _rng.randf())
		for blade in range(3):
			var height := _rng.randf_range(0.12, 0.32)
			var foot := point + Vector3(_rng.randf_range(-0.15, 0.15), 0.0, _rng.randf_range(-0.16, 0.16))
			terrain.beam(foot, foot + Vector3((blade - 1) * 0.09, height, 0), 0.07, 0.065, tone)
		if index % 7 == 0:
			terrain.box(point + Vector3(0, 0.34, 0), Vector3(0.075, 0.68, 0.075), Color("#61734c"))
			terrain.box(point + Vector3(0, 0.64, 0), Vector3(0.22, 0.115, 0.18), Color("#dac07b"))
		elif index % 11 == 0:
			_rock(terrain, point, _rng.randf_range(0.25, 0.50))
	terrain.bake(self, _cube, "Claro")

	var forest := Blocks.new()
	var distant := Blocks.new()
	for ring in range(3):
		var count := 24 + ring * 10
		for index in count:
			var angle := TAU * (float(index) + _rng.randf_range(-0.3, 0.3)) / count
			var radius := 16.5 + ring * 10.0 + _rng.randf_range(-1.4, 1.7)
			var point := Vector3(cos(angle) * radius, 0, sin(angle) * radius)
			# A saddle between the pines lets sky and the distant ridge frame the target.
			if point.z < 0.0 and absf(point.x) < 4.0 + ring * 0.7:
				continue
			var height := _rng.randf_range(6.6, 12.3) * (1.0 + ring * 0.12)
			var layer := forest if ring == 0 else distant
			if index % 6 == 1 and ring == 0:
				_birch(layer, point, height * 0.78)
			else:
				_fir(layer, point, height, ring)
	for side in [-1, 1]:
		_birch(forest, Vector3(8.0 * side, 0, -8.2), 7.6 + side * 0.42)
		_fir(forest, Vector3(11.9 * side, 0, -3.5), 10.4 - side * 0.7, 0)
	forest.bake(self, _cube, "Linde")
	var pine_sites: Array[Vector3] = [
		Vector3(-5.9, 0, -12.2), Vector3(5.8, 0, -12.1), Vector3(-10.9, 0, 2.2),
		Vector3(11.1, 0, 4.2), Vector3(-4.2, 0, 12.1)
	]
	for i in pine_sites.size():
		var pine := PALETTE_PINE.instantiate() as Node3D
		pine.position = pine_sites[i]
		pine.rotation.y = i * PI * 0.22
		pine.scale = Vector3.ONE * (1.0 + (i % 3) * 0.16)
		add_child(pine)
	for index in range(20):
		var angle := float(index) / 20.0 * TAU
		var radius := _rng.randf_range(54, 63)
		var x := cos(angle) * radius
		var z := sin(angle) * radius
		var height := _rng.randf_range(5.0, 11.8)
		for step in range(4):
			var k := float(4 - step)
			distant.box(Vector3(x + step * 0.5, height * (step + 0.5) / 4, z), Vector3(4.4 * k, height / 4, 3.3 * k), Color("#899d91").lightened(step * 0.025))
	distant.bake(self, _cube, "Bosque lejano", false)

func _rock(blocks: Blocks, base: Vector3, size: float) -> void:
	blocks.box(base + Vector3(0, size * 0.25, 0), Vector3(size * 1.4, size * 0.5, size), STONE)
	blocks.box(base + Vector3(-size * 0.07, size * 0.61, 0), Vector3(size * 1.08, size * 0.24, size * 0.8), STONE.lightened(0.12))
	if size > 0.52:
		blocks.box(base + Vector3(-size * 0.2, size * 0.75, 0.04), Vector3(size * 0.72, size * 0.08, size * 0.63), MOSS)

func _fir(blocks: Blocks, base: Vector3, height: float, ring: int) -> void:
	var width := height * _rng.randf_range(0.3, 0.40)
	var shade := Color("#355c50").lerp(Color("#557659"), _rng.randf())
	shade = shade.lerp(Color("#869988"), ring * 0.18)
	blocks.box(base + Vector3(0, height * 0.26, 0), Vector3(height * 0.075, height * 0.52, height * 0.075), BARK.lightened(ring * 0.07))
	for tier in range(5):
		var fraction := 1.0 - tier * 0.175
		var w := width * fraction
		var y := height * (0.32 + tier * 0.137)
		var h := height * (0.13 + fraction * 0.025)
		var crown := base + Vector3(tier * 0.025, y, 0)
		var tint := shade.lightened(tier * 0.035)
		blocks.box(crown, Vector3(w, h, w * 0.67), tint)
		blocks.box(crown + Vector3(0, h * 0.04, 0), Vector3(w * 0.65, h * 0.92, w), tint)
		if ring == 0 and tier < 3:
			blocks.box(crown + Vector3(-w * 0.25, h * 0.51, w * 0.20), Vector3(w * 0.31, h * 0.12, w * 0.24), tint.lightened(0.10))
	blocks.box(base + Vector3(0.09, height * 0.953, 0), Vector3(width * 0.15, height * 0.10, width * 0.15), shade.lightened(0.20))

func _birch(blocks: Blocks, base: Vector3, height: float) -> void:
	var trunk := height * 0.055
	blocks.box(base + Vector3(0, height * 0.32, 0), Vector3(trunk, height * 0.64, trunk), Color("#dad6b0"))
	for band in range(5):
		blocks.box(base + Vector3(trunk * 0.13, height * (0.08 + band * 0.105), trunk * 0.505), Vector3(trunk * 0.7, trunk * 0.25, 0.04), Color("#666958"))
	for limb in [-1, 1]:
		var tip := base + Vector3(limb * height * 0.13, height * (0.69 + limb * 0.08), height * 0.03)
		blocks.beam(base + Vector3(0, height * 0.45, 0), tip, trunk * 0.64, trunk * 0.64, Color("#cec8a3"))
		var w := height * 0.35
		var leaves := Color("#77904e").lightened(0.08 * (limb + 1))
		blocks.box(tip, Vector3(w, height * 0.20, w * 0.76), leaves)
		blocks.box(tip + Vector3(-0.19, height * 0.11, -0.08), Vector3(w * 0.72, height * 0.12, w * 0.68), leaves.lightened(0.08))

func _make_collisions() -> void:
	var limits := StaticBody3D.new()
	limits.name = "Limites del claro"
	add_child(limits)
	_collider(limits, Vector3(0, -0.25, 0), Vector3(150, 0.5, 150))
	for side in [-1, 1]:
		_collider(limits, Vector3(side * 10.4, 1.7, 0), Vector3(0.55, 3.4, 24.0))
		_collider(limits, Vector3(0, 1.7, side * 11.55), Vector3(21.5, 3.4, 0.65))
	_collider(limits, Vector3(2.48, 0.5, -4.1), Vector3(0.68, 1.0, 0.64))
	for side in [-1, 1]:
		_collider(limits, Vector3(8.0 * side, 1.6, -8.2), Vector3(0.5, 3.2, 0.5))

func _collider(parent: StaticBody3D, center: Vector3, size: Vector3) -> CollisionShape3D:
	var node := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	node.position = center
	node.shape = shape
	parent.add_child(node)
	return node

func set_stage(stage: int) -> void:
	if stage == _stage:
		return
	_stage = stage
	if _knot_geometry != null:
		_knot_geometry.hide()
		_knot_geometry.queue_free()
	var blocks := Blocks.new()
	var growth := 1.0 + 0.19 * (clampi(stage, 1, 3) - 1)
	# A stump with torn crown and a sawn forward face. Thin horizontal strips
	# create stepped annual rings; the amber heart sits at the clean center.
	blocks.box(Vector3(0, 1.24, 0), Vector3(2.12, 2.46, 1.54), BARK)
	blocks.box(Vector3(0, 1.23, -0.13), Vector3(1.68, 2.44, 1.88), WOOD.darkened(0.2))
	for i in range(7):
		var x := (i - 3) * 0.30
		var height := 2.3 + 0.30 * sin(i * 2.3 + stage)
		blocks.box(Vector3(x, height * 0.5, -0.2), Vector3(0.27, height, 1.57), WOOD.lerp(BARK, float(i % 3) * 0.34))
		blocks.box(Vector3(x, height + 0.045, -0.20), Vector3(0.26, 0.09, 1.50), CUT.darkened(0.18))
	for side in [-1, 1]:
		blocks.beam(Vector3(0.70 * side, 0.74, 0.06), Vector3(1.44 * side, 0.15, 0.32), 0.46, 0.68, BARK)
		blocks.box(Vector3(1.33 * side, 0.11, 0.42), Vector3(0.64, 0.22, 0.63), WOOD.darkened(0.2))
		blocks.beam(Vector3(0.76 * side, 1.87, -0.28), Vector3(1.18 * side, 2.6 + stage * 0.13, -0.35), 0.23, 0.36, WOOD)
	# Seven horizontal chords leave a squared-off, octagonal ring silhouette.
	var face_y := TARGET_POSITION.y / growth
	_disc(blocks, Vector3(0, face_y, 0.82), 1.01, BARK.darkened(0.20))
	_disc(blocks, Vector3(0, face_y, 0.86), 0.90, CUT)
	_disc(blocks, Vector3(0, face_y, 0.90), 0.70, Color("#814d34"))
	_disc(blocks, Vector3(0, face_y, 0.94), 0.58, Color("#d79c55"))
	_disc(blocks, Vector3(0, face_y, 0.98), 0.40, Color("#6a4432"))
	_disc(blocks, Vector3(0, face_y, 1.02), 0.28, SAP)
	blocks.box(Vector3(0, face_y, 1.06), Vector3(0.17, 0.17, 0.04), FEATHER, Vector3(0, 0, PI / 4))
	# Fresh shoots mark each stage along the jagged crown rather than covering the rings.
	for i in range(stage + 1):
		var sprout := Vector3(-0.85 + i * 0.36, 2.45 + 0.13 * (i % 2), -0.5)
		blocks.beam(sprout, sprout + Vector3(-0.08, 0.33, 0), 0.11, 0.11, MOSS)
		blocks.box(sprout + Vector3(-0.20, 0.31, 0), Vector3(0.33, 0.13, 0.19), Color("#93a962"))
	_knot_geometry = blocks.bake(_knot, _cube, "Madera y veta")
	_knot_geometry.scale = Vector3.ONE * growth
	_knot_collision.size = Vector3(2.2, 2.64, 2.08) * growth
	_knot_collider.position = Vector3(0, 1.32, 0.025) * growth

func _disc(blocks: Blocks, center: Vector3, radius: float, tone: Color) -> void:
	var widths := [0.54, 0.82, 0.96, 1.0, 0.96, 0.82, 0.54]
	for strip in 7:
		var y := radius * float(strip - 3) * (2.0 / 7.0)
		blocks.box(center + Vector3(0, y, 0), Vector3(radius * 2.0 * float(widths[strip]), radius * 2.0 / 7.0 + 0.002, 0.045), tone)

func _make_workshop() -> void:
	_footings.position = WORKSHOP_BASE
	add_child(_footings)
	var foundation := Blocks.new()
	for x in [-0.72, 0.72]:
		for z in [-0.52, 0.52]:
			foundation.box(Vector3(x, 0.08, z), Vector3(0.36, 0.16, 0.36), STONE)
			foundation.box(Vector3(x, 0.25, z), Vector3(0.14, 0.20, 0.14), CUT)
	foundation.bake(_footings, _cube, "Zócalos")
	_workshop.position = WORKSHOP_BASE
	_workshop.name = "Taller de flechas"
	add_child(_workshop)
	var frame := Blocks.new()
	for side in [-1, 1]:
		for end in [-1, 1]:
			frame.box(Vector3(side * 0.72, 0.93, end * 0.51), Vector3(0.15, 1.76, 0.16), WOOD)
	frame.box(Vector3(0, 0.66, 0), Vector3(1.80, 0.19, 1.35), BARK)
	for plank in range(7):
		frame.box(Vector3((plank - 3) * 0.25, 0.79, 0), Vector3(0.23, 0.13, 1.34), CUT.darkened(0.045 * (plank % 3)))
	frame.beam(Vector3(-0.72, 0.23, -0.5), Vector3(0.72, 1.55, -0.5), 0.14, 0.11, BARK)
	# Lapped teal boards form a shallow pitched roof over a moving bright guide.
	for side in [-1, 1]:
		for step in range(4):
			frame.box(Vector3(0, 2.09 - step * 0.115, side * (0.08 + step * 0.19)), Vector3(2.08, 0.15, 0.32), Color("#487368").lightened(step * 0.028))
	frame.box(Vector3(0, 2.18, 0), Vector3(2.18, 0.15, 0.29), Color("#839482"))
	frame.box(Vector3(0.63, 1.51, 0.56), Vector3(0.39, 0.53, 0.065), Color("#d18b3c"))
	frame.box(Vector3(0.63, 1.56, 0.608), Vector3(0.07, 0.23, 0.035), FEATHER)
	frame.box(Vector3(0.63, 1.67, 0.61), Vector3(0.15, 0.09, 0.036), FEATHER)
	# Output chute leads from the bench to the pickup.
	frame.beam(Vector3(0.42, 0.63, 0.57), Vector3(0.66, 0.13, 1.0), 0.49, 0.10, WOOD)
	frame.bake(_workshop, _cube, "Caballetes")
	_wheel.position = Vector3(-0.87, 0.66, 0.0)
	_workshop.add_child(_wheel)
	var spokes := Blocks.new()
	for index in range(8):
		var angle := TAU * index / 8.0
		var end := Vector3(0, sin(angle), cos(angle)) * 0.44
		spokes.beam(Vector3.ZERO, end, 0.07, 0.08, CUT)
		spokes.box(end, Vector3(0.20, 0.18, 0.18), WOOD)
	spokes.box(Vector3.ZERO, Vector3(0.25, 0.17, 0.17), BARK)
	spokes.bake(_wheel, _cube, "Husillo")
	_workshop.add_child(_tray)
	var guide := Blocks.new()
	guide.box(Vector3(0, 1.04, 0.08), Vector3(1.03, 0.17, 0.36), BARK)
	for i in range(3):
		guide.box(Vector3((i - 1) * 0.19, 1.14, 0.1), Vector3(0.06, 0.055, 0.61), FEATHER)
	guide.bake(_tray, _cube, "Guía móvil")
	var solid := StaticBody3D.new()
	_workshop.add_child(solid)
	_workshop_collision = _collider(solid, Vector3(0, 0.86, -0.04), Vector3(1.74, 1.72, 1.22))

func _make_pile_models(location: Vector3, models: Array[Node3D]) -> void:
	for count in [3, 5, 8]:
		var bundle := Blocks.new()
		for i in range(count):
			var fraction := (i + 0.5) / float(count) - 0.5
			var tip := Vector3(fraction * 0.26, 0.07, 0.15 + (i % 2) * 0.05)
			var tail := Vector3(fraction * 0.66, 0.58 + 0.09 * (i % 3), -0.25 - 0.035 * i)
			var direction := (tail - tip).normalized()
			bundle.beam(tip, tail, 0.045, 0.045, CUT)
			bundle.beam(tail - direction * 0.16, tail, 0.14, 0.055, FEATHER)
			bundle.beam(tail - direction * 0.16, tail, 0.045, 0.135, Color("#e6d8a4"))
		bundle.box(Vector3(0, 0.27, -0.02), Vector3(0.38, 0.09, 0.16), Color("#49665d"), Vector3(-0.5, 0, 0))
		var model := bundle.bake(self, _cube, "Haz")
		model.position = location
		model.visible = false
		models.append(model)

func set_workshop(built: bool) -> void:
	_built = built
	_workshop.visible = built
	_workshop_collision.set_deferred("disabled", not built)

func set_piles(workshop_amount: int, knot_amount: int) -> void:
	_show_pile(_workshop_piles, workshop_amount if _built else 0)
	_show_pile(_knot_piles, knot_amount)

func _show_pile(models: Array[Node3D], amount: int) -> void:
	var level := -1
	if amount >= 16:
		level = 2
	elif amount >= 6:
		level = 1
	elif amount > 0:
		level = 0
	for i in models.size():
		models[i].visible = i == level

func _process(delta: float) -> void:
	if _built:
		_wheel_time = fmod(_wheel_time + delta * 2.5, TAU)
		_wheel.rotation.x = _wheel_time
		_tray.position.y = sin(_wheel_time * 2.0) * 0.065

func hit_feedback(point: Vector3) -> void:
	_splinters(point, 5, 0.37)

func break_feedback() -> void:
	var growth := _knot_geometry.scale.x
	_splinters(TARGET_POSITION + Vector3(0.0, 0.12, 1.1 * growth), 16, 1.35)
	var collapse := _knot_geometry.create_tween().set_parallel(true)
	collapse.tween_property(_knot_geometry, "scale", Vector3(growth * 1.06, 0.08, growth * 1.06), 0.36).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	collapse.tween_property(_knot_geometry, "rotation:z", 0.085, 0.34)

func _splinters(point: Vector3, count: int, radius: float) -> void:
	for i in count:
		var chip := MeshInstance3D.new()
		chip.mesh = _chip_mesh
		chip.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(chip)
		chip.global_position = point + Vector3(0, 0, 0.03)
		chip.scale = Vector3(0.04, 0.09, 0.045) * _rng.randf_range(0.8, 1.55)
		chip.rotation.z = _rng.randf_range(-PI, PI)
		var drift := Vector3(_rng.randf_range(-1, 1), _rng.randf_range(0.05, 1.0), _rng.randf_range(0.25, 1.1)) * radius
		var flight := create_tween().set_parallel(true)
		flight.tween_property(chip, "position", chip.position + drift, 0.27).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		flight.tween_property(chip, "scale", Vector3.ONE * 0.004, 0.20).set_delay(0.14)
		flight.chain().tween_callback(chip.queue_free)
