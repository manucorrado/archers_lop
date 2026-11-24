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
	check(game.run.stage == 9 and game.run.rank_of("rain") == 0, "Reaching target nine keeps rain locked in a new run")
	game.run.sap = 5000
	for id in ["damage", "rate", "recurve", "rate_step_01", "rate_step_02", "longbow"]:
		check(game.run.buy(id), "Unlocking rain's parent via " + id)
	game._set_view("shop")
	game._change_upgrade("rain", false)
	check(game.run.rank_of("rain") == 0, "Rain must be paid for even with the bow equipped")
	game.run.sap = 3200
	game._change_upgrade("rain", false)
	check(game.run.rank_of("rain") == 1 and game.run.sap == 0 and game.hud.notice_es.contains("Lluvia") and game.hud.notice_en.contains("rain"),
			"Buying arrow rain spends its advertised price and announces the unlock")
	game._resume_play()
	game.run.equip("branch")
	game.run.arrows = 1
	game.run.ranks["spark"] = 1
	for i in 3:
		await physics_frame
	game._shoot()
	check(game.in_flight.size() == 4 and game.run.arrows == 0, "One remaining arrow calls three free arrows")
	check(game.hud.rain_status.is_visible_in_tree() and game.hud.rain_status.text.contains("cayendo"), "The ledger shows when purchased rain is falling")
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

	game._set_view("shop")
	game.run.sap = 5000
	check(game.run.buy("weak"), "Precision opens the combo purchase")
	var before_power := game.run.sap
	game._change_upgrade("combo", false)
	check(game.run.sap == before_power - 190 and game.hud.shop_notice.text.contains("Combo"), "The shop announces the purchased combo")
	for i in 8:
		game.run.buy("damage")
	check(game.run.volley_size() == 1, "Nine damage ranks still release single arrows")
	before_power = game.run.sap
	game._change_upgrade("damage", false)
	check(game.run.sap == before_power - 1250 and game.hud.notice_es.contains("Disparo triple") and game.hud.notice_en.contains("Triple shot"),
			"The tenth damage rank unlocks and names triple shot in both languages")
	game._resume_play()
	check(game.hud.combo_panel.is_visible_in_tree() and game.hud.combo_hint.text == "Listo", "Combo is visible and ready before the first bought streak")
	game.run.manual_impact("body", 5, 10, 0)
	game._sync()
	check(game.hud.combo_hint.text == "En racha", "A landed arrow activates the streak in the HUD")
	game.run.arrows = 2
	var pose := game.archer.save_pose()
	pose.yaw += PI
	game.archer.restore_pose(pose)
	game._shoot()
	initial_hp = game.run.hp
	check(game.hud.triple_status.is_visible_in_tree() and game.hud.triple_status.text.contains("2/3"), "A partial triple shot reports its real arrow count")
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
	var legacy := game.run.save_state()
	legacy.erase("purchased_rain_rule")
	legacy.ranks.erase("rain")
	legacy.ranks.combo = 1
	legacy.ranks.refund = 1
	legacy.paid_prices.clear()
	var migrated := Game.Run.new()
	check(migrated.restore_state(legacy), "A pre-purchase-rule run can resume")
	var old_offers := migrated.offers()
	check(migrated.rank_of("rain") == 1 and old_offers.rain.refund_cost == 0 and old_offers.combo.refund_cost == 19 and old_offers.damage.refund_cost == 154,
			"Legacy auto-rain and the original combo and triple-shot prices survive migration")
	check(migrated.refund("rain") and migrated.restore_state(migrated.save_state()) and migrated.rank_of("rain") == 0,
			"An already migrated game can sell rain without regaining it on every load")
	for voice: AudioStreamPlayer in game.find_children("*", "AudioStreamPlayer", true, false):
		voice.stop()
	unload_current_scene()
	for i in 4:
		await process_frame
		OS.delay_msec(30)
	if not failed:
		print("PASS: final arrow rain, ammunition, saved flights, bow damage, aim and boss phases.")
	quit(1 if failed else 0)
