extends SceneTree

const Game = preload("res://scripts/game.gd")
const Run = preload("res://scripts/run.gd")
const SaveData = preload("res://scripts/save_data.gd")
const NODE := Run.Paths.SENTINEL_NODE
var failed := false


func _initialize() -> void:
	var qa := OS.get_environment("ARCHER_QA_DIR").replace("\\", "/")
	if qa.is_empty() or not OS.get_user_data_dir().begins_with(qa + "/"):
		printerr("Use tests/run-tests.ps1 to isolate the crossbow checkpoint.")
		quit(1)
		return
	_rules()
	_play.call_deferred()


func _check(ok: bool, what: String) -> void:
	if not ok:
		printerr("FAIL: ", what)
		failed = true


func _build(run: Run) -> void:
	run.sap = 4000
	for id in ["damage", "workshop", "wheel", "wheel_step_01", "wheel_step_02", "wheel_step_03", "wheel_step_04"]:
		_check(run.buy(id), "Reach the crossbow through " + id)
	var old_rate := run.production_rate()
	_check(run.offers()[NODE].cost == 235 and run.buy(NODE), "The outer bearing unlocks the crossbow")
	_check(is_equal_approx(run.production_rate() - old_rate, 0.025), "The bearing retains its production increase")


func _rules() -> void:
	var run := Run.new()
	_check(run.load_sentinel() == 0, "A new campaign has no magazine")
	_build(run)
	var legacy := run.save_state()
	legacy.erase("sentinel_wait")
	legacy.erase("sentinel_ammo")
	_check(run.restore_state(legacy) and run.sentinel_ammo == 0 and run.rank_of(NODE) == 1,
		"Owners of the old bearing can use the empty station")
	run.arrows = 7
	_check(run.load_sentinel() == 3 and run.arrows == 4 and run.load_sentinel() == 0, "The player always keeps four arrows")
	run.arrows = 24
	_check(run.load_sentinel() == 8 and run.load_sentinel() == 1 and run.sentinel_ammo == 12 and run.arrows == 15,
		"Transfers respect both the eight-arrow batch and twelve-arrow magazine")
	_check(run.load_sentinel() == 0 and run.arrows == 15, "A full magazine leaves the quiver untouched")
	_check(run.tick_sentinel(0.75).is_empty(), "A loaded bolt takes two seconds")
	var resumed := Run.new()
	_check(resumed.restore_state(run.save_state()) and resumed.tick_sentinel(1.25) == "body" and resumed.sentinel_ammo == 11,
		"Reload keeps the magazine and the remaining interval")
	run.stage = 10
	run.hp = floori(run.max_hp() * 2 / 3.0) + 1
	_check(run.core_needs_hit() and run.tick_sentinel(8.0).is_empty() and run.sentinel_ammo == 12,
		"A required hollow freezes the crossbow without wasting arrows")
	run.strike_part(1, "root_0")
	_check(run.tick_sentinel(1.25) == "body" and run.sentinel_ammo == 11, "A personal core hit frees the station")
	run.stage = 5
	run.hp = run.max_hp()
	run.damage_part(run.hp, "body")
	_check(run.sentinel_target() == "right", "The crossbow tracks the nearer half")
	run.damage_part(run.right_hp, "right")
	_check(run.sentinel_target() == "left", "The surviving half remains a valid target")
	run.damage_part(run.left_hp, "left")
	_check(run.tick_sentinel(4.0).is_empty() and run.sentinel_ammo == 11, "A broken target costs no further ammunition")
	var dropped := run.knot_stock
	run.arrows = 22
	run.buy("refund")
	_check(run.refund(NODE) and run.arrows == 24 and run.knot_stock == dropped + 9 and run.sentinel_ammo == 0,
		"Refunds return stored arrows and leave overflow in the accessible trunk bundle")


func _play() -> void:
	change_scene_to_file("res://main.tscn")
	await scene_changed
	var game := current_scene as Game
	game._start_campaign()
	_build(game.run)
	game.run.stage = 7
	game.run.hp = game.run.max_hp()
	game.run.ranks.combo = 1
	game.run.combo = 4.0
	game.run.combo_grace = 40.0
	game._redraw_world()
	game.archer.position = game.clearing.sentinel.position + Vector3(0, 0, 1.25)
	game._sync()
	_check(game.hud.values.near_sentinel and game.run.sentinel_ammo == 0, "Walking to the empty station identifies it in the HUD")
	_interact(game)
	_check(game.view == "play" and game.run.sentinel_ammo == 8 and game.run.arrows == 16, "Interaction transfers eight arrows")
	var saved: Dictionary = SaveData.load_campaign()
	_check(saved.run.sentinel_ammo == 8 and saved.run.arrows == 16, "The input checkpoint captures both sides of the transfer")
	game.run.sentinel_wait = 0.01
	game._physics_process(0.02)
	_check(game.in_flight.size() == 1 and game.run.sentinel_ammo == 7, "Firing creates one physical bolt and spends one arrow")
	game._set_view("pause")
	game._manual_save()
	game._physics_process(4.0)
	_check(game.run.sentinel_ammo == 7 and game.run.hp == game.run.max_hp(), "The paused station and flying bolt remain frozen")
	game._resume_campaign()
	_check(game.view == "pause" and game.in_flight.size() == 1 and game.run.sentinel_ammo == 7, "Checkpoint reload restores the bolt exactly once")
	game._resume_play()
	var balance := game.run.sap
	var streak := game.run.combo
	game._physics_process(0.5)
	var effective := roundi(8 * Run.POWER[6])
	_check(game.run.hp == game.run.max_hp() - effective and (game.run.sap - balance) * 8 + game.run.sap_remainder == effective,
		"A mounted hit pays the exact base damage exchange")
	_check(game.run.hits == 0 and game.run.shots == 0 and game.run.combo == streak and game.run.spark_hits == 0,
		"Crossbow bolts leave manual hit, streak and spark counters intact")
	if not failed:
		print("PASS: crossbow purchases, inventory, phases, reloading, real input, flight and base sap.")
	quit(1 if failed else 0)


func _interact(game: Game) -> void:
	var event := InputEventAction.new()
	event.action = "shop"
	event.pressed = true
	game.get_viewport().push_input(event, true)
