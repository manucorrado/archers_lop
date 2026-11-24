extends SceneTree
## Shoot actual physics rays through the corners that used to be solid boxes.

const Clearing = preload("res://scripts/clearing.gd")
var clearing := Clearing.new()
var failed := false

func _initialize() -> void:
	_run.call_deferred()

func _ray(from: Vector3, to: Vector3) -> String:
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var hit := clearing.get_world_3d().direct_space_state.intersect_ray(query)
	return clearing.target_id(hit.get("collider"), hit.get("position", to))

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failed = true
		printerr("FAIL: ", message)

func _run() -> void:
	root.add_child(clearing)
	var origin := Vector3(0, 0, Clearing.TARGET_POSITION.z)
	for stage in [1, 5, 9, 10, 15, 20]:
		clearing.sync_encounter({"stage": stage, "hp": 100, "max_hp": 100})
		await physics_frame
		await physics_frame
		var size := clearing._growth()
		_expect((clearing._crack.wood_tint != Color.WHITE) == (stage >= 10),
			"The end grain changes to dark timber at target 10")
		for side in [-1.0, 1.0]:
			var corner := origin + Vector3(side * 0.99, 0, -0.90) * size
			_expect(_ray(corner + Vector3.UP * 3.3 * size.y, corner + Vector3.UP * 0.8 * size.y) == "",
					"An arrow passes the empty rear corner of target %d" % stage)
		var center := origin + Vector3(0.0, 1.20, 0.0) * size
		_expect(_ray(center + Vector3.RIGHT * 5, center) == "body", "The side bark takes a hit")
		_expect(_ray(center + Vector3.FORWARD * 5, center) == "body", "The rear bark takes a hit")
	if not failed:
		for phase in 3:
			clearing.sync_encounter({"stage": 10, "hp": 100, "max_hp": 100, "core_phase": phase})
			await physics_frame
			for id in ["core_%d" % phase, "root_%d" % phase]:
				var spot := clearing.target_center(id)
				_expect(_ray(spot + Vector3.BACK * 4, spot - Vector3.BACK * 0.2) == id,
						"The exposed hollow or root intercepts the shot: %s" % id)
	clearing.sync_encounter({"stage": 5, "hp": 50, "max_hp": 100, "split": true, "left_hp": 25, "right_hp": 25})
	await physics_frame
	await physics_frame
	for id in ["left", "right"]:
		var spot := clearing.target_center(id)
		_expect(_ray(spot + Vector3.BACK * 4, spot - Vector3.BACK) == id, "Each fork can be hit separately")
		var corner := Vector3(spot.x, 0, origin.z - 0.89)
		_expect(_ray(corner + Vector3.UP * 6, corner + Vector3.UP) == "", "Split bark has open corners")
	_expect(_ray(origin + Vector3(0, 2.9, 4), origin + Vector3(0, 2.9, -1.5)) == "", "The gap between the halves is open")
	if not failed:
		print("PASS: stepped trunk corners, bark hits, both fork marks and all final boss sockets and roots.")
	quit(1 if failed else 0)
