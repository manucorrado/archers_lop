extends Node3D

const TARGET_POSITION := Vector3(0.0, 1.65, -5.0)
const WORKSHOP_PICKUP := Vector3(-6.6, 0.0, 0.15)
const DOG_POSITION := Vector3(-6.85, 0, 6.05)
const BRIZNO_POSITION := Vector3(6.7, 0, -0.65)
const ARENA_HALF_WIDTH := 11.70
const ARENA_HALF_LENGTH := 13.55
const DOG_REACH := 1.9
const KNOT_PICKUP := Vector3(0.9, 0.0, -2.85)
const WORKSHOP_BASE := Vector3(-7.2, 0.0, -1.40)
const WORKSHOP_LANDINGS: Array[Vector3] = [
	Vector3(-5.0, 0, 4.8), Vector3(0.7, 0, 2.0), Vector3(4.5, 0, -0.5), Vector3(-7.9, 0, -5.2)
]
const LAUNCH_ORIGIN := WORKSHOP_BASE + Vector3(0.23, 1.12, 1.52)
const CORE_SOCKETS: Array[Vector3] = [
	Vector3(-1.15, 2.90, -3.37), Vector3(1.14, 4.86, -3.37), Vector3(-0.26, 6.98, -3.37)
]
const CORE_ROOTS: Array[Vector3] = [
	Vector3(-1.93, 0.30, -2.96), Vector3(1.92, 0.30, -2.91), Vector3(0.0, 0.30, -2.47)
]
const KIT = preload("res://assets/kit_claro.tres")
const TimberFace = preload("res://scripts/timber_face.gd")
const TimberTrunk = preload("res://scripts/timber_trunk.gd")
const CUE_AUDIO := preload("res://scripts/bow_audio.gd")

const BARK := Color("#533e32")
const WOOD := Color("#976442")
const CUT := Color("#c79258")
const SAP := Color("#ffb641")
const FEATHER := Color("#fff0bb")
const MOSS := Color("#75845a")
const STONE := Color("#788176")

const Blocks = preload("res://scripts/voxel_blocks.gd")
const DOG = preload("res://assets/ovejero.tscn")
const BRIZNO := preload("res://assets/brizno.tscn")
const Journal := preload("res://scripts/field_journal.gd")

var _cube := BoxMesh.new()
var sentinel := preload("res://scripts/sentinel.gd").new()
var _dog = DOG.instantiate()
var _dog_sign := Sprite3D.new()
var _sign_check := 0.0
var _rng := RandomNumberGenerator.new()
var _knot := StaticBody3D.new()
var _knot_geometry: Node3D
var _knot_collider := CollisionShape3D.new()
var _workshop := Node3D.new()
var _workshop_collision: CollisionShape3D
var _footings := Node3D.new()
var _wheel := Node3D.new()
var _tray := Node3D.new()
var _workshop_piles: Array = []
var _flying_bundles := {}
var _glow_material := ShaderMaterial.new()
var _first_pickup_help := true
var _knot_piles: Array[Node3D] = []
var _chip_mesh := BoxMesh.new()
var _stage := 0
var _built := false
var _wheel_time := 0.0
var _crack: TimberFace
var _cavities := Node3D.new()
var _targets := {}
var _seed_piles := {}
var _audio_sources := {}
var _split := false
var _last_encounter_stage := 0
var _flashes := 1.0
var _world_volume := 1.0

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
	_dog.position = DOG_POSITION
	add_child(_dog)
	_dog.look_at(Vector3.ZERO, Vector3.UP, true)
	_add_dog_nameplate()
	var courier := BRIZNO.instantiate() as Node3D
	courier.position = BRIZNO_POSITION
	courier.rotation.y = -0.86
	add_child(courier)
	_make_workshop()
	_prepare_pickup_glow()
	for landing in WORKSHOP_LANDINGS:
		var models: Array[Node3D] = []
		_make_pile_models(landing, models)
		_workshop_piles.append(models)
	_make_pile_models(KNOT_PICKUP, _knot_piles)
	_knot.name = "Nudo"
	_knot.position = Vector3(TARGET_POSITION.x, 0, TARGET_POSITION.z)
	add_child(_knot)
	_knot.add_to_group("knot")
	_knot.add_child(_knot_collider)
	_make_encounter()
	set_stage(1)
	set_workshop(false)
	set_piles(0, 0)
	add_child(sentinel)
	sentinel.build(_cube, preload("res://scripts/run.gd").SENTINEL_CAPACITY)

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
	atmosphere.tonemap_exposure = 0.90
	atmosphere.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	atmosphere.ambient_light_sky_contribution = 0.0
	atmosphere.ambient_light_color = Color("#c7d4cc")
	atmosphere.ambient_light_energy = 0.43
	atmosphere.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	atmosphere.fog_enabled = true
	atmosphere.fog_light_color = Color("#b4c5bf")
	atmosphere.fog_density = 0.007
	atmosphere.fog_sky_affect = 0.12
	var world_light := WorldEnvironment.new()
	world_light.environment = atmosphere
	add_child(world_light)
	var sun := DirectionalLight3D.new()
	sun.light_color = Color("#fff6e9")
	sun.light_energy = 0.50
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 40.0
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	add_child(sun)
	sun.look_at_from_position(Vector3(-11, 16, 9), Vector3.ZERO)

func _make_landscape() -> void:
	var terrain := Blocks.new()
	terrain.box(Vector3(0, -0.27, 0), Vector3(142, 0.54, 142), Color("#6e805c"))
	# Broken edges of a packed-earth firing path. Heights stay below ankle level.
	for index in range(58):
		var z := _rng.randf_range(-7.0, 8.5)
		var x := sin(z * 0.5) * 0.42 + _rng.randf_range(-1.35, 1.35)
		terrain.box(Vector3(x, 0.009 + float(index) * 0.0007, z), Vector3(_rng.randf_range(0.6, 2.1), 0.018, _rng.randf_range(0.65, 1.6)), Color("#948967").lerp(Color("#a49a78"), _rng.randf()))
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
			var post_spacing := 2.0 * (ARENA_HALF_LENGTH - 0.45) / 6.0
			var z := -(ARENA_HALF_LENGTH - 0.45) + index * post_spacing
			var post := Vector3((ARENA_HALF_WIDTH - 0.24) * side, 0.0, z)
			terrain.box(post + Vector3(0, 0.52, 0), Vector3(0.28, 1.04, 0.34), BARK)
			terrain.box(post + Vector3(0, 1.06, 0), Vector3(0.30, 0.08, 0.36), CUT)
			if index < 6:
				terrain.beam(post + Vector3(0, 0.67, 0), post + Vector3(0, 0.55, post_spacing), 0.14, 0.14, WOOD)
	for side in [-1, 1]:
		for index in range(11):
			var base := Vector3((index / 5.0 - 1.0) * (ARENA_HALF_WIDTH - 0.5), 0.0, (ARENA_HALF_LENGTH - 0.2) * side)
			_rock(terrain, base, _rng.randf_range(0.45, 0.78))
	# A weathered reference stone to judge the size of each successive knot.
	terrain.box(Vector3(2.5, 0.43, -4.1), Vector3(0.67, 0.86, 0.62), STONE)
	terrain.box(Vector3(2.46, 0.93, -4.12), Vector3(0.51, 0.17, 0.52), Color("#a3a88b"))
	for index in range(3):
		terrain.box(Vector3(2.52, 0.23 + index * 0.20, -3.783), Vector3(0.28 - index * 0.045, 0.045, 0.035), Color("#515c53"))
	# Grass, small wildflowers and stones stay on the shoulders of the lane.
	for index in range(270):
		var point := Vector3(_rng.randf_range(-14, 14), 0, _rng.randf_range(-15, 15))
		if absf(point.x) < 2.1 and point.z > -7.0:
			continue
		if point.distance_to(WORKSHOP_BASE) < 2.2 or point.distance_to(WORKSHOP_PICKUP) < 1.45 or point.distance_to(DOG_POSITION) < 0.85:
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
		Vector3(-5.9, 0, -14.4), Vector3(5.8, 0, -14.3), Vector3(-11.9, 0, 2.6),
		Vector3(12.4, 0, 4.2), Vector3(-4.2, 0, 14.3)
	]
	var pines: Array[PackedScene] = [KIT.pino_normal, KIT.pino_alto, KIT.pino_inclinado]
	for i in pine_sites.size():
		var scene := pines[i % pines.size()]
		if scene == null:
			continue
		var pine := scene.instantiate() as Node3D
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
		_collider(limits, Vector3(side * ARENA_HALF_WIDTH, 1.7, 0), Vector3(0.55, 3.4, 2 * ARENA_HALF_LENGTH + 0.65))
		_collider(limits, Vector3(0, 1.7, side * ARENA_HALF_LENGTH), Vector3(2 * ARENA_HALF_WIDTH + 0.55, 3.4, 0.65))
	_collider(limits, Vector3(2.48, 0.5, -4.1), Vector3(0.68, 1.0, 0.64))
	var dog_shape := _collider(limits, DOG_POSITION + Vector3(0, 0.41, 0), Vector3(0.42, 0.82, 0.52))
	dog_shape.rotation.y = atan2(-DOG_POSITION.x, -DOG_POSITION.z)
	_collider(limits, BRIZNO_POSITION + Vector3.UP * 0.48, Vector3(0.48, 0.96, 0.44))
	for side in [-1, 1]:
		_collider(limits, Vector3(8.0 * side, 1.6, -8.2), Vector3(0.5, 3.2, 0.5))

func is_near_dog(feet: Vector3) -> bool:
	return feet.distance_squared_to(DOG_POSITION) <= DOG_REACH * DOG_REACH

func is_near_brizno(feet: Vector3) -> bool:
	return feet.distance_squared_to(BRIZNO_POSITION) <= 2.0 * 2.0

func _add_dog_nameplate() -> void:
	var surface := SubViewport.new()
	surface.size = Vector2i(116, 44)
	surface.transparent_bg = true
	surface.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(surface)
	var box := Journal.sheet(7, 1)
	box.size = Vector2(surface.size)
	surface.add_child(box)
	var nameplate := Label.new()
	nameplate.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	nameplate.text = "Pipo"
	nameplate.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nameplate.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var face := Journal.serif()
	face.font_italic = true
	nameplate.add_theme_font_override("font", face)
	nameplate.add_theme_font_size_override("font_size", 30)
	nameplate.add_theme_color_override("font_color", Journal.INK)
	box.add_child(nameplate)
	_dog_sign.name = "Pipo"
	_dog_sign.texture = surface.get_texture()
	_dog_sign.fixed_size = true
	_dog_sign.pixel_size = 0.00085
	_dog_sign.visibility_range_end = 20.0
	_dog_sign.no_depth_test = true
	_dog_sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_dog_sign.position = DOG_POSITION + Vector3.UP * 1.48
	_dog_sign.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_dog_sign)

func _physics_process(delta: float) -> void:
	_sign_check -= delta
	if _sign_check > 0.0:
		return
	_sign_check = 0.12
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var head := DOG_POSITION + Vector3.UP * 0.95
	_dog_sign.visible = camera.global_position.distance_squared_to(head) < 400.0 and not camera.is_position_behind(head)
	if _dog_sign.visible:
		var sight := PhysicsRayQueryParameters3D.create(camera.global_position, head)
		var player := camera.get_parent() as CollisionObject3D
		if player:
			sight.exclude = [player.get_rid()]
		_dog_sign.visible = get_world_3d().direct_space_state.intersect_ray(sight).is_empty()

func pet_dog() -> void:
	_dog.pet()

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
	var growth := _growth()
	TimberTrunk.build(blocks, Vector3(0, 0, -0.04), Vector3(2.18, 2.47, 1.96), stage)
	# A sawn branch leaves a flat patch of end grain on the rounded trunk.
	var face_widths := [0.42, 0.73, 0.92, 1.00, 0.93, 0.76, 0.44]
	for i in range(7):
		blocks.box(Vector3(0, 1.45 + (i - 3) * 0.22, 0.815),
				Vector3(1.45 * float(face_widths[i]), 0.22, 0.34), BARK.lightened(0.07))
	for side in [-1, 1]:
		blocks.beam(Vector3(0.70 * side, 0.74, 0.06), Vector3(1.44 * side, 0.15, 0.32), 0.46, 0.68, BARK)
		blocks.box(Vector3(1.33 * side, 0.11, 0.42), Vector3(0.64, 0.22, 0.63), WOOD.darkened(0.2))
		blocks.beam(Vector3(0.76 * side, 1.87, -0.28), Vector3(1.18 * side, 2.73, -0.35), 0.23, 0.36, WOOD)
		var root_base := Vector3(0.43 * side, 0.72, 0.70)
		var root_knee := Vector3(0.58 * side, 0.24, 0.97)
		var root_tip := Vector3(1.18 * side, 0.10, 1.18)
		blocks.beam(root_base, root_knee, 0.29, 0.31, WOOD.darkened(0.23))
		blocks.beam(root_knee, root_tip, 0.24, 0.21, WOOD.darkened(0.12))
		blocks.beam(Vector3(0.88*side,0.57,0.45),Vector3(1.01*side,1.98,0.46),0.18,0.25,BARK.lightened(0.07))
		blocks.beam(Vector3(0.80*side,1.79,0.05),Vector3(1.17*side,2.58 + 0.18*side,0.12),0.29,0.34,BARK)
		blocks.box(Vector3(1.17*side,2.58 + 0.18*side,0.12),Vector3(0.27,0.065,0.32),CUT)
	if stage == 5:
		for facing in [-1.0, 1.0]:
			blocks.beam(Vector3(facing * 0.47, 1.53, 0), Vector3(facing * 0.95, 2.98, -0.08), 0.54, 0.53, WOOD)
			blocks.box(Vector3(facing * 0.95, 2.96, -0.08), Vector3(0.50, 0.11, 0.51), CUT)
	# Fresh shoots mark each stage along the jagged crown rather than covering the rings.
	for i in range(mini(stage + 1, 6)):
		var sprout := Vector3(-0.8 + i * 0.30, 2.40 + 0.08 * (i % 2), -0.5)
		blocks.beam(sprout, sprout + Vector3(-0.08, 0.33, 0), 0.11, 0.11, MOSS)
		blocks.box(sprout + Vector3(-0.20, 0.31, 0), Vector3(0.33, 0.13, 0.19), Color("#93a962"))
	_knot_geometry = blocks.bake(_knot, _cube, "Madera y veta")
	_knot_geometry.scale = growth
	_crack = TimberFace.new()
	_crack.name = "Corte de madera"
	_crack.position = Vector3(0, 1.45, 0.986)
	_crack.scale = Vector3(0.68, 0.81, 1)
	_knot_geometry.add_child(_crack)
	_knot_collider.shape = TimberTrunk.collision(blocks, _cube, growth)

func _growth() -> Vector3:
	var progress := float(clampi(_stage, 1, 10) - 1) / 9.0
	return Vector3(1.0 + progress, 1.0 + 4.0 * progress, 1.0 + 0.32 * progress)


func _disc(blocks: Blocks, center: Vector3, radius: float, tone: Color) -> void:
	var widths := [0.54, 0.82, 0.96, 1.0, 0.96, 0.82, 0.54]
	for strip in 7:
		var y := radius * float(strip - 3) * (2.0 / 7.0)
		blocks.box(center + Vector3(0, y, 0), Vector3(radius * 2.0 * float(widths[strip]), radius * 2.0 / 7.0 + 0.002, 0.045), tone)

func _make_encounter() -> void:
	for id: String in ["left", "right"]:
		var side := -1.0 if id == "left" else 1.0
		var lobe := _new_interactive(id)
		lobe.add_to_group("knot")
		lobe.position = Vector3(side * 1.16, 0, TARGET_POSITION.z)
		var plates := Blocks.new()
		TimberTrunk.build(plates, Vector3(-side * 0.17, 0.0, 0), Vector3(1.13, 3.12, 1.51),
				15 if side < 0 else 16, -side * 0.11)
		plates.beam(Vector3(-side * 0.22, 0.47, 0.08), Vector3(side * 0.44, 0.15, 0.99), 0.49, 0.45, WOOD)
		plates.box(Vector3(side * 0.46, 0.13, 1.07), Vector3(0.61, 0.26, 0.55), BARK)
		TimberTrunk.build(plates, Vector3(side * 0.15, 2.84, -0.08), Vector3(0.76, 0.80, 0.90),
				25 if side < 0 else 26, -side * 0.29)
		plates.beam(Vector3(side * 0.43,2.07,0.08),Vector3(side * 0.87,2.77,0.15),0.28,0.36,BARK)
		plates.box(Vector3(side * 0.87,2.77,0.15),Vector3(0.27,0.08,0.35),CUT)
		plates.beam(Vector3(-side*0.25,1.45,0.63),Vector3(-side*0.44,0.18,0.75),0.19,0.21,WOOD.darkened(0.22))
		plates.beam(Vector3(side*0.16,1.08,0.60),Vector3(side*0.39,0.28,0.94),0.18,0.24,WOOD.darkened(0.12))
		plates.box(Vector3(side*0.48,3.52,0.31),Vector3(0.43,0.12,0.21),MOSS)
		plates.beam(Vector3(side*0.52,3.53,0.10),Vector3(side*0.66,3.89,0.08),0.085,0.095,MOSS)
		plates.box(Vector3(side*0.72,3.85,0.08),Vector3(0.27,0.105,0.16),Color("#9fa879"))
		for i in 5:
			var x := (i - 2) * 0.24
			var height := 1.49 - absf(x) * 0.87
			plates.box(Vector3(x, 1.94 + side * x * 0.38, 0.76), Vector3(0.245, height, 0.27), CUT.darkened(0.07 * (i % 3)))
		var lobe_scale := Vector3(1.10, 1.73, 1)
		plates.bake(lobe, _cube, "Madera hendida").scale = lobe_scale
		var mark := Blocks.new()
		_target_rings(mark, 0.38)
		var mark_mesh := mark.bake(lobe, _cube, "Blanco expuesto", false)
		mark_mesh.position = Vector3(0, 1.94 * lobe_scale.y, 1.01)
		var hull := CollisionShape3D.new()
		hull.shape = TimberTrunk.collision(plates, _cube, lobe_scale)
		lobe.add_child(hull)
		var mark_collision := CollisionShape3D.new()
		mark_collision.shape = TimberTrunk.collision(mark, _cube, Vector3.ONE)
		mark_collision.position = mark_mesh.position
		lobe.add_child(mark_collision)
		_set_interactive(id, false)
	_make_core_sockets()
	var target := _new_interactive("target")
	var ring := Blocks.new()
	_disc(ring, Vector3.ZERO, 0.40, Color("#382d30"))
	_disc(ring, Vector3(0, 0, 0.030), 0.346, FEATHER)
	_disc(ring, Vector3(0, 0, 0.062), 0.254, Color("#707e81"))
	_disc(ring, Vector3(0, 0, 0.094), 0.159, FEATHER)
	ring.box(Vector3(0,0,0.131), Vector3(0.10,0.10,0.022), BARK, Vector3(0,0,PI / 4))
	ring.box(Vector3(0,0.39,0.032), Vector3(0.105,0.20,0.050), FEATHER)
	ring.bake(target, _cube, "Diana")
	var disk := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = 0.40
	cylinder.height = 0.15
	disk.shape = cylinder
	disk.rotation.x = PI * 0.5
	disk.position.z = 0.05
	target.add_child(disk)
	_set_interactive("target", false)
	for i in 3:
		var id := "seed_%d" % i
		var seed_body := _new_interactive(id)
		var seed_mesh := Blocks.new()
		seed_mesh.box(Vector3(0, -0.10, 0), Vector3(0.35, 0.42, 0.31), Color("#dca965"), Vector3(0,0,0.22))
		seed_mesh.box(Vector3(0, 0.12, 0), Vector3(0.49, 0.19, 0.40), BARK)
		seed_mesh.beam(Vector3(0,0.16,0), Vector3(0.13,0.36,0), 0.055,0.055, CUT)
		for side in [-1.0,1.0]:
			seed_mesh.beam(Vector3(side*0.06,0.16,0), Vector3(side*0.40,0.31,0),0.16,0.07,FEATHER)
		seed_mesh.bake(seed_body, _cube, "Semilla alada")
		_collider(seed_body, Vector3.ZERO, Vector3(0.74, 0.58, 0.5))
		_set_interactive(id, false)
		var models: Array[Node3D] = []
		_make_pile_models(seed_drop_position(id), models)
		_seed_piles[id] = models
	var synth := CUE_AUDIO.new()
	for cue: String in ["target", "event"]:
		var source := AudioStreamPlayer3D.new()
		source.stream = synth._make_clip(cue, CUE_AUDIO.LENGTHS[cue])
		source.unit_size = 11.0
		add_child(source)
		_audio_sources[cue] = source
	synth.free()

func _new_interactive(id: String) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = id
	body.set_meta("target_id", id)
	add_child(body)
	_targets[id] = body
	return body

func _target_rings(blocks: Blocks, radius: float) -> void:
	_disc(blocks, Vector3.ZERO, radius, Color("#322925"))
	_disc(blocks, Vector3(0, 0, 0.028), radius * 0.84, FEATHER)
	_disc(blocks, Vector3(0, 0, 0.055), radius * 0.6, Color("#a45e2e"))
	_disc(blocks, Vector3(0, 0, 0.077), radius * 0.32, Color("#ffeab0"))

func _make_core_sockets() -> void:
	add_child(_cavities)
	for i in CORE_SOCKETS.size():
		var point := CORE_SOCKETS[i]
		var rim := Blocks.new()
		_disc(rim, Vector3.ZERO, 0.68, BARK.lightened(0.10))
		_disc(rim, Vector3(0, 0, 0.022), 0.56, Color("#4d3d33"))
		_disc(rim, Vector3(0, 0, 0.045), 0.41, Color("#382e29"))
		rim.bake(_cavities, _cube, "Cavidad").position = point
		var core := _new_interactive("core_%d" % i)
		core.position = point + Vector3(0, 0, 0.09)
		var layers := Blocks.new()
		_target_rings(layers, 0.52)
		layers.bake(core, _cube, "Corazón expuesto")
		var shape := CylinderShape3D.new()
		shape.radius = 0.53
		shape.height = 0.17
		var collider := CollisionShape3D.new()
		collider.shape = shape
		collider.rotation.x = PI * 0.5
		core.add_child(collider)
		_set_interactive("core_%d" % i, false)
		_make_core_root(i)
	_cavities.hide()

func _make_core_root(index: int) -> void:
	var start := CORE_SOCKETS[index]
	var foot := CORE_ROOTS[index]
	var spine: Array[Vector3] = [
		start - Vector3.UP * 0.51,
		Vector3(lerpf(start.x, foot.x, 0.22), start.y * 0.61, start.z - 0.025),
		Vector3(lerpf(start.x, foot.x, 0.57), 1.05, start.z),
		Vector3(lerpf(start.x, foot.x, 0.86), 0.49, start.z + 0.12),
		foot,
	]
	var root := _new_interactive("root_%d" % index)
	root.position = foot
	var wood := Blocks.new()
	var sap_line := Blocks.new()
	for segment in spine.size() - 1:
		var age := float(segment) / 3.0
		wood.beam(spine[segment], spine[segment + 1], lerpf(0.16, 0.40, age), lerpf(0.12, 0.26, age), WOOD.darkened(0.24))
		var front := Vector3.BACK * lerpf(0.075, 0.16, age)
		sap_line.beam(spine[segment] - foot + front, spine[segment + 1] - foot + front, 0.058, 0.04, SAP)
	wood.box(foot, Vector3(0.63, 0.43, 0.67), BARK, Vector3(-0.13,0,0))
	wood.bake(_cavities, _cube, "Raíz de la cavidad")
	sap_line.box(Vector3(0, 0.19, 0.17), Vector3(0.39, 0.13, 0.30), SAP)
	sap_line.box(Vector3(0, 0.265, 0.18), Vector3(0.17, 0.048, 0.15), FEATHER)
	sap_line.bake(root, _cube, "Savia en la raíz", false)
	_collider(root, Vector3.ZERO, Vector3(0.74, 0.62, 0.80))
	_set_interactive("root_%d" % index, false)

func _set_interactive(id: String, enabled: bool) -> void:
	var body: StaticBody3D = _targets[id]
	body.visible = enabled
	body.collision_layer = 1 if enabled else 0

func seed_drop_position(id: String) -> Vector3:
	match id:
		"seed_0": return Vector3(-2.95, 0, -2.1)
		"seed_1": return Vector3(1.85, 0, -1.95)
		_: return Vector3(3.45, 0, -1.56)

func target_center(id: String) -> Vector3:
	if id in ["left", "right"]:
		return (_targets[id] as Node3D).position + Vector3(0, 1.94 * 1.73, 0.96)
	if _targets.has(id):
		return (_targets[id] as Node3D).position
	return TARGET_POSITION + Vector3(0, 0, 1.05 * _growth().z)

func target_id(collider: Object, _point: Vector3) -> String:
	if collider == _knot and not _split:
		return "body"
	if collider is StaticBody3D and collider.visible:
		return str(collider.get_meta("target_id", ""))
	return ""

func sync_encounter(state: Dictionary) -> void:
	set_stage(int(state.get("stage", 1)))
	var was_split := _split
	_split = bool(state.get("split", false))
	if _split and not was_split and _last_encounter_stage == _stage:
		for id: String in ["left", "right"]:
			var lobe: StaticBody3D = _targets[id]
			var side := -1.0 if id == "left" else 1.0
			lobe.position.x = side * 0.57
			var open := lobe.create_tween()
			open.tween_property(lobe, "position:x", side * 1.16, 0.30).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_last_encounter_stage = _stage
	_knot_geometry.visible = not _split
	_knot.collision_layer = 0 if _split else 1
	var health_fraction := clampf(float(state.get("hp", 1)) / maxf(float(state.get("max_hp", 1)), 1), 0, 1)
	_crack.set_damage(1.0 - health_fraction)
	_set_interactive("left", _split and int(state.get("left_hp", 0)) > 0)
	_set_interactive("right", _split and int(state.get("right_hp", 0)) > 0)
	_set_interactive("target", bool(state.get("target_active", false)) and not _split)
	var diana: StaticBody3D = _targets["target"]
	var which := clampi(int(state.get("target_side", 0)), 0, 2)
	var x := [-0.60, 0.62, -0.21]
	var y := [0.28, -0.16, 0.64]
	diana.position = target_center("body") + Vector3(float(x[which]) * _growth().x, float(y[which]), 0.19)
	_cavities.visible = _stage == 10
	for i in CORE_SOCKETS.size():
		var exposed := _stage == 10 and int(state.get("core_phase", 0)) == i and int(state.get("hp", 0)) > 0
		_set_interactive("core_%d" % i, exposed)
		_set_interactive("root_%d" % i, exposed)
	_first_pickup_help = not state.get("fired_after_collect", false)
	_update_workshop_delivery(state)
	var active := {}
	for seed_state: Dictionary in state.get("seeds", []):
		active[seed_state.id] = float(seed_state.remaining)
	var drops: Dictionary = state.get("seed_drops", {})
	for id: String in _seed_piles:
		var alive := active.has(id)
		_set_interactive(id, alive)
		if alive:
			var t := clampf(float(active[id]) / 9.0, 0, 1)
			var seed_body: StaticBody3D = _targets[id]
			var lane := int(id.right(1))
			var wind := sin(t * TAU + lane) * sin(t * PI)
			seed_body.position = seed_drop_position(id) + Vector3(wind * 0.38, 0.45 + t * (3.1 + lane * 0.32), 0)
			seed_body.rotation.z = wind * 0.28
		_show_pile(_seed_piles[id], int(drops.get(id, 0)))

func apply_settings(options: Dictionary) -> void:
	_flashes = clampf(options.get("flashes", 1.0), 0, 1)
	_world_volume = clampf(options.get("volume_world", 1.0), 0, 1)
	sentinel.set_volume(_world_volume)
	for source: AudioStreamPlayer3D in _audio_sources.values():
		source.volume_db = -7 + linear_to_db(maxf(_world_volume, 0.00001))

func play_encounter_cue(cue: String) -> void:
	var key := "target" if cue.begins_with("core_") else cue
	if _audio_sources.has(key) and _world_volume > 0:
		var source: AudioStreamPlayer3D = _audio_sources[key]
		source.position = target_center("seed_0" if cue == "event" else cue)
		source.play()

func play_spark(point: Vector3) -> void:
	var trace := Blocks.new()
	var size := 0.028 + _flashes * 0.035
	var mid := point + Vector3(0.21, 0.29, 0.06)
	var bend := point + Vector3(0.12,0.40,0.14)
	trace.beam(point, mid, size, size, Color("#e0d3ff"))
	trace.beam(mid, bend, size, size, Color("#aa96d9"))
	trace.beam(bend, bend + Vector3(0.26,0.24,0.035), size, size, Color("#aa96d9"))
	var arc := trace.bake(self, _cube, "Chispa de copa", false)
	var fade := arc.create_tween()
	fade.tween_interval(0.14)
	fade.tween_callback(arc.queue_free)

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
	# A spring arm projects past the eave: each load leaves from the pale cradle.
	frame.beam(Vector3(0.23, 0.52, 0.46), Vector3(0.23, 0.87, 1.48), 0.19, 0.19, WOOD)
	for side in [-1, 1]:
		frame.beam(Vector3(0.23, 0.84, 1.32), Vector3(0.23 + side * 0.27, 1.07, 1.56), 0.105, 0.115, CUT)
	frame.box(Vector3(0.23, 0.99, 1.50), Vector3(0.57, 0.08, 0.26), FEATHER)
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
	for scene: PackedScene in [KIT.haz_pequeno, KIT.haz_mediano, KIT.haz_grande]:
		var model := scene.instantiate() as Node3D if scene else Node3D.new()
		add_child(model)
		model.position = location
		model.visible = false
		models.append(model)
	var glow := MeshInstance3D.new()
	glow.mesh = PlaneMesh.new()
	(glow.mesh as PlaneMesh).size = Vector2(1.75, 1.75)
	glow.material_override = _glow_material
	glow.position = location + Vector3(0, 0.075, 0)
	glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(glow)
	models[0].set_meta("pickup_glow", glow)
	glow.hide()

func _prepare_pickup_glow() -> void:
	var shader := Shader.new()
	shader.code = """
		shader_type spatial;
		render_mode unshaded, cull_disabled, depth_draw_never;
		void fragment() {
			float r = length(UV * 2.0 - 1.0);
			float halo = 1.0 - smoothstep(0.24, 1.0, r);
			float rim = 1.0 - smoothstep(0.0, 0.055, abs(r - 0.68));
			ALBEDO = mix(vec3(1.0, 0.60, 0.15), vec3(1.0, 0.90, 0.59), rim);
			ALPHA = 0.39 * halo + 0.50 * rim;
		}
	"""
	_glow_material.shader = shader

func workshop_landing_position(slot: int) -> Vector3:
	return WORKSHOP_LANDINGS[slot]

func _update_workshop_delivery(state: Dictionary) -> void:
	var piles: Array = state.get("workshop_piles", [])
	for slot in _workshop_piles.size():
		var amount := int(piles[slot]) if slot < piles.size() else 0
		_show_pile(_workshop_piles[slot], amount)
	_show_pile(_knot_piles, int(state.get("knot_stock", 0)))
	var visible_serials := {}
	for batch: Dictionary in state.get("workshop_flights", []):
		var serial: int = batch.serial
		visible_serials[serial] = true
		if not _flying_bundles.has(serial):
			var model := KIT.haz_pequeno.instantiate() as Node3D
			add_child(model)
			model.scale *= 0.83
			_flying_bundles[serial] = {"node": model, "landing": workshop_landing_position(batch.slot)}
		var flight: Dictionary = _flying_bundles[serial]
		flight.duration = batch.duration
		flight.age = maxf(0, float(batch.duration) - float(batch.remaining))
		_position_bundle(flight)
	for serial in _flying_bundles.keys():
		if not visible_serials.has(serial):
			var node: Node3D = _flying_bundles[serial].node
			node.hide()
			node.queue_free()
			_flying_bundles.erase(serial)

func _position_bundle(flight: Dictionary) -> void:
	var t := clampf(float(flight.age) / maxf(0.001, float(flight.duration)), 0, 1)
	var node: Node3D = flight.node
	node.position = LAUNCH_ORIGIN.lerp(flight.landing, t) + Vector3.UP * (8.4 * t * (1.0 - t))
	node.rotation.x = -1.4 * sin(t * PI)

func set_workshop(built: bool) -> void:
	_built = built
	_workshop.visible = built
	_workshop_collision.set_deferred("disabled", not built)

func set_piles(_workshop_amount: int, knot_amount: int) -> void:
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
	var glow: Node3D = models[0].get_meta("pickup_glow")
	glow.visible = amount > 0 and _first_pickup_help

func _process(delta: float) -> void:
	for flight: Dictionary in _flying_bundles.values():
		flight.age += delta
		_position_bundle(flight)
	if _built:
		_wheel_time = fmod(_wheel_time + delta * 2.5, TAU)
		_wheel.rotation.x = _wheel_time
		_tray.position.y = sin(_wheel_time * 2.0) * 0.065

func hit_feedback(point: Vector3) -> void:
	_splinters(point, roundi(1 + 4 * _flashes), 0.37)

func break_feedback() -> void:
	var growth := _knot_geometry.scale.x
	_splinters(TARGET_POSITION + Vector3(0.0, 0.12, 1.1 * growth), roundi(3 + 13 * _flashes), 1.35)
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
