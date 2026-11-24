extends SceneTree

const Game := preload("res://scripts/game.gd")
var failed := false


func _initialize() -> void:
	var qa := OS.get_environment("ARCHER_QA_DIR").replace("\\", "/")
	if qa.is_empty() or not OS.get_user_data_dir().begins_with(qa + "/"):
		printerr("Use an isolated profile for the final rain test.")
		quit(1)
		return
	test.call_deferred()


func check(condition: bool, message: String) -> void:
	if not condition:
		printerr("FAIL: ", message)
		failed = true


func test() -> void:
	change_scene_to_file("res://main.tscn")
	await scene_changed
	var game := current_scene as Game
	game._start_campaign()
	game.set_physics_process(false)
	game.run.stage = 8
	game.run.hp = game.run.max_hp()
	game._redraw_world()
	for i in 3:
		await physics_frame
	game._shoot()
	check(game.in_flight.size() == 1, "The eighth target has ordinary shots")
	game._tick_flights(1.0)
	game.run.hp = 0
	game._next_knot()
	check(game.run.stage == 9 and game.hud.notice_es.contains("Lluvia") and game.hud.notice_en.contains("rain"),
			"Entering the ninth target announces the new power in both languages")
	game.run.arrows = 1
	game.run.ranks["spark"] = 1
	for i in 3:
		await physics_frame
	game._shoot()
	check(game.in_flight.size() == 4 and game.run.arrows == 0, "One remaining arrow calls three free arrows")
	var direct: Dictionary = game.in_flight[0]
	check(direct.id == "body", "The original shot was aimed at the tree")
	var damage: int = direct.damage
	var initial_hp := game.run.hp
	var initial_hits := game.run.hits
	game._tick_flights(direct.duration + 0.028)
	check(game.run.hp == initial_hp - damage and game.in_flight.size() == 3, "The original arrow hits before the rain")
	check(game.archer._rain.multimesh.visible_instance_count == 1, "Only the first falling arrow has appeared")
	check(game._save_campaign(), "A partly resolved volley can be saved")
	game._resume_campaign()
	check(game.view == "pause" and game.in_flight.size() == 3 and game.archer._rain.multimesh.visible_instance_count == 1,
			"Restore reproduces the same falling and pending arrows")
	game._resume_play()
	var bow_credit: int = game.run.damage_by_source.bow
	game._tick_flights(1.0)
	check(game.run.hp == initial_hp - 4 * damage and game.run.damage_by_source.bow == bow_credit + 3 * damage,
			"Rain applies each snapshotted arrow's damage once and credits the bow")
	check(game.run.hits == initial_hits + 1 and game.run.spark_hits == 1 and game.run.arrows == 0,
			"Extra projectiles do not count as precision hits or ignite extra sparks")

	game.run.ranks["damage"] = 10
	game.run.arrows = 2
	var pose := game.archer.save_pose()
	pose.yaw += PI
	game.archer.restore_pose(pose)
	game._shoot()
	initial_hp = game.run.hp
	check(game.in_flight.size() == 8 and game.run.arrows == 0, "A partially filled triple shot only copies two paid arrows")
	game._tick_flights(1.5)
	check(game.run.hp == initial_hp, "A volley aimed away from the target misses with every copy")

	game.run.stage = 10
	game.run.hp = game.run.max_hp()
	game._redraw_world()
	var hits: Array[Dictionary] = [{"id":"core_0", "damage":game.run.hp}]
	game._land_arrow_rain(hits)
	game._land_arrow_rain(hits)
	check(game.run.core_phase == 0 and game.run.core_needs_hit() and not game.run.core_hit, "Rain cannot unlock a boss hollow")
	game.run.manual_impact("core_0", 10, 15, 0)
	check(game.run.core_phase == 1, "A player arrow at the active hollow still advances the boss")
	for voice: AudioStreamPlayer in game.find_children("*", "AudioStreamPlayer", true, false):
		voice.stop()
	unload_current_scene()
	for i in 4:
		await process_frame
		OS.delay_msec(30)
	if not failed:
		print("PASS: final arrow rain, ammunition, saved flights, bow damage, aim and boss phases.")
	quit(1 if failed else 0)
