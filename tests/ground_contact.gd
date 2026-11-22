extends SceneTree

const Clearing := preload("res://scripts/clearing.gd")
const Game := preload("res://scripts/game.gd")
const Shepherd := preload("res://scripts/shepherd.gd")
var game: Game
var failed := false


func _initialize() -> void:
	var qa := OS.get_environment("ARCHER_QA_DIR").replace("\\", "/")
	if qa.is_empty() or not OS.get_user_data_dir().begins_with(qa + "/"):
		printerr("Run the camera test with an isolated profile.")
		quit(1)
		return
	_run.call_deferred()


func _check(condition: bool, description: String) -> void:
	if not condition:
		failed = true
		printerr("FAIL: ", description)


func _at_rest(feet: Vector3, landmark: Vector3) -> void:
	var direction := (feet + Vector3.UP * game.archer.EYE_HEIGHT).direction_to(landmark)
	game.archer.restore_pose({"x": feet.x, "y": feet.y, "z": feet.z,
		"yaw": atan2(-direction.x, -direction.z), "pitch": asin(direction.y)})
	for i in 30:
		await physics_frame
	var origin := game.archer.camera.global_position
	var sample := game.archer.camera.unproject_position(landmark)
	for i in 90:
		await physics_frame
		if game.archer.camera.global_position.distance_to(origin) > 0.0001 or game.archer.camera.unproject_position(landmark).distance_to(sample) > 0.15:
			_check(false, "An idle viewpoint moved against the landmark at %s" % landmark)
			break
	_check(game.archer.is_on_floor(), "The archer keeps floor contact while resting")


func _run() -> void:
	change_scene_to_file("res://main.tscn")
	await scene_changed
	game = current_scene
	game._start_campaign()
	game.run.ranks["workshop"] = 1
	game._redraw_world()
	await _at_rest(Clearing.BRIZNO_POSITION + Vector3(-0.71, 0.0366, 0.212), Clearing.BRIZNO_POSITION + Vector3.UP)
	await _at_rest(Clearing.DOG_POSITION + Vector3(-0.65, 0.0339, -0.666), Clearing.DOG_POSITION + Vector3.UP)
	await _at_rest(Clearing.WORKSHOP_BASE + Vector3(1.48, 0.0109, 1.843), Clearing.WORKSHOP_BASE + Vector3.UP)

	game.archer.restore_pose({"x": 0.0, "y": 0.01, "z": 5.0})
	Input.action_press("move_right")
	for i in 20:
		await physics_frame
	Input.action_release("move_right")
	_check(game.archer.position.x > 0.5, "The archer can walk along the ground")
	var jump := InputEventAction.new()
	jump.action = "jump"
	jump.pressed = true
	root.push_input(jump, true)
	var peak := 0.0
	for i in 90:
		await physics_frame
		peak = maxf(peak, game.archer.position.y)
	_check(peak > 0.35 and game.archer.is_on_floor(), "Jumping still leaves the ground and lands")

	var dog: Shepherd = game.clearing._dog
	dog.set_process(false)
	for i in 3600:
		dog._process(1.0 / 60.0)
	var tail := dog.get_node("Cola") as Node3D
	var angle := tail.rotation.y
	var max_step := 0.0
	for i in 180:
		if i == 0 or i == 25:
			dog.pet()
		dog._process(1.0 / 60.0)
		max_step = maxf(max_step, absf(angle_difference(angle, tail.rotation.y)))
		angle = tail.rotation.y
	_check(max_step < 0.20, "Petting after a minute changes the wag speed without jumping between poses")
	if not failed:
		print("PASS: steady grounded camera at all three landmarks, walking, jumping and continuous pet animation.")
	quit(1 if failed else 0)
