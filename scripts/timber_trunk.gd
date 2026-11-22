extends RefCounted
## Cross sections sampled on a square grid keep the silhouette stepped on every side.

const Blocks = preload("res://scripts/voxel_blocks.gd")
const RADIUS := [1, 2, 3, 4, 4, 4, 3, 2, 1]
const BARK := Color("#533e32")
const WOOD := Color("#976442")
const CUT := Color("#c79258")


static func build(blocks: Blocks, base: Vector3, size: Vector3, seed_: int, tilt := 0.0) -> void:
	var start := blocks.poses.size()
	var pitch := Vector2(size.x, size.z) / 9.0
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_ + 8317
	var height := size.y
	for x in 9:
		var depth: int = RADIUS[x]
		var cx := (x - 4) * pitch.x
		var half_z := (depth + 0.5) * pitch.y
		blocks.box(Vector3(cx, height * 0.5, 0), Vector3(pitch.x, height, 2 * half_z),
				BARK.lerp(WOOD, rng.randf_range(0.16, 0.38)))
		for z in range(-depth, depth + 1):
			var ring := Vector2(x - 4.35, z + 0.15).length()
			var tint := CUT.darkened(0.28 if (ring > 1.75 and ring < 2.65) or ring < 0.77 else 0.02)
			var cap_height := 0.05
			if absi(z) == depth or absi(x - 4) == RADIUS[z + 4]:
				tint = WOOD.darkened(0.18)
				if posmod(x * 3 + z + seed_, 5) == 0:
					cap_height = 0.12
			blocks.box(Vector3(cx, height + cap_height * 0.5, z * pitch.y), Vector3(pitch.x, cap_height, pitch.y), tint)
		for sign_z in [-1.0, 1.0]:
			_bark_strip(blocks, Vector3(cx, 0, sign_z * half_z), Vector3(0, 0, sign_z), pitch.x, height, rng)
	for z in 9:
		var extent: int = RADIUS[z]
		for sign_x in [-1, 1]:
			var edge := Vector3(sign_x * (extent + 0.5) * pitch.x, 0, (z - 4) * pitch.y)
			_bark_strip(blocks, edge, Vector3(sign_x, 0, 0), pitch.y, height, rng)
	var scar := Vector3(0.07 * size.x, size.y * 0.64, -size.z / 2.0 - 0.065)
	blocks.box(scar, Vector3(size.x * 0.16, size.y * 0.09, 0.064), BARK, Vector3(0, 0, 0.42))
	blocks.box(scar - Vector3.BACK * 0.037, Vector3(size.x * 0.09, size.y * 0.04, 0.029), WOOD, Vector3(0, 0, 0.42))
	var pose := Transform3D(Basis(Vector3.BACK, tilt), base)
	for i in range(start, blocks.poses.size()):
		blocks.poses[i] = pose * blocks.poses[i]


static func _bark_strip(blocks: Blocks, edge: Vector3, normal: Vector3, width: float, height: float, rng: RandomNumberGenerator) -> void:
	var y := rng.randf_range(0.0, 0.1)
	while y < height - 0.08:
		var length := minf(height * rng.randf_range(0.13, 0.35), height - y - 0.02)
		var thickness := rng.randf_range(0.018, 0.046)
		var center := edge + Vector3.UP * (y + length / 2.0) + normal * (thickness * 0.4)
		var face_width := width * rng.randf_range(0.58, 0.84)
		var size := Vector3(face_width, length, thickness) if normal.x == 0 else Vector3(thickness, length, face_width)
		blocks.box(center, size, BARK.lerp(WOOD, rng.randf_range(0.27, 0.83)))
		y += length + rng.randf_range(0.015, 0.034)


static func collision(blocks: Blocks, cube: BoxMesh, growth: Vector3) -> ConcavePolygonShape3D:
	# The hit surface follows the same voxels as the bark, roots and branches.
	# Scale the vertices, not the physics body: the last target has nonuniform growth.
	var unit := cube.get_faces()
	var faces := PackedVector3Array()
	for pose in blocks.poses:
		faces.append_array(Transform3D(Basis.from_scale(growth), Vector3.ZERO) * pose * unit)
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	return shape
