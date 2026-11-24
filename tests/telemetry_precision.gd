extends SceneTree

const Run = preload("res://scripts/run.gd")
const Log = preload("res://scripts/run_log.gd")
const Game = preload("res://scripts/game.gd")

var failed := false


func _initialize() -> void:
	var qa := OS.get_environment("ARCHER_QA_DIR").replace("\\", "/")
	if qa.is_empty() or not OS.get_user_data_dir().begins_with(qa + "/"):
		printerr("Use tests/run-tests.ps1 to isolate the run journal checkpoint.")
		quit(1)
		return
	_test.call_deferred()


func _test() -> void:
	_precision()
	_sources()
	_clocks()
	_tenth_entry()
	await _gameplay()
	if not failed:
		print("PASS: precision returns, effective damage, focused session timing and target 10 entry report.")
	quit(1 if failed else 0)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failed = true
		printerr("FAIL: ", message)


func _precision() -> void:
	var run := Run.new()
	run.stage = 2
	run.hp = run.max_hp()
	run.arrows = 12
	run._offer_target()
	run.manual_impact("target", 10, 15, run.target_serial)
	_check(run.arrows == 12, "The first act keeps its original weak-point reward")
	run.stage = 5
	run.hp = 0
	run.event_clock = 0.0
	run.prepare_gifts()
	run.choose_gift(run.gift_offer[0])
	_check(run.seen_target and run.next_knot() and run.stage == 6 and run.target_active and run.target_clock == 7.0,
		"A returning player gets a full bullseye window as soon as the sixth tree appears")
	run.tick(0.1)
	_check(run.target_active and run.seeds.is_empty(), "Pending seed rain cannot preempt the first act-two opportunity")
	var serial := run.target_serial
	run.manual_impact("target", 10, 15, serial - 1)
	run.strike_part(4, "target")
	_check(run.target_active and run.arrows == 12, "Old arrows and branch strikes cannot collect the timed target")
	var hit := run.manual_impact("target", 10, 15, serial)
	run.manual_impact("target", 10, 15, serial)
	run.manual_impact("target", 10, 15, serial)
	_check(hit.arrows_returned == 3 and run.arrows == 15 and not run.target_active, "A triple collects only once")
	var restored := Run.new()
	_check(restored.restore_state(run.save_state()), "The collected target is saved")
	restored.manual_impact("target", 10, 15, serial)
	_check(restored.arrows == 15, "Reopening cannot collect the same target twice")
	restored._offer_target()
	restored.arrows = restored.capacity() - 1
	hit = restored.manual_impact("target", 10, 15, restored.target_serial)
	_check(hit.arrows_returned == 1 and restored.arrows == restored.capacity(), "Return is capped at actual quiver space")
	restored._offer_target()
	hit = restored.manual_impact("target", 10, 15, restored.target_serial)
	_check(hit.arrows_returned == 0 and not restored.target_active, "A full quiver still consumes the opportunity")
	restored.stage = 10
	restored.hp = restored.max_hp()
	restored.arrows = 0
	restored.manual_impact("core_0", 10, 15, serial)
	_check(restored.arrows == 0, "A boss hollow is not a timed bullseye")


func _sources() -> void:
	var run := Run.new()
	run.ranks.spark = 1
	run.spark_hits = 7
	run.manual_impact("body", 11, 18, 0)
	run.strike_part(4, "body")
	run.damage_part(25, "body", false, "sentinel")
	run.manual_impact("body", 9999, 9999, 0)
	run.damage_part(25, "body", false, "sentinel")
	_check(run.hp == 0 and run.damage_by_source == {"bow": 111, "spark": 20, "branch": 4, "sentinel": 25, "other": 0},
		"All and only the tree's 160 HP are attributed across damage sources")
	_check(run.sap == 20 and run.sap_remainder == 0, "Attribution preserves damage earnings")
	var resumed := Run.new()
	_check(resumed.restore_state(run.save_state()) and resumed.damage_by_source == run.damage_by_source,
		"Attribution survives a checkpoint")
	var legacy := run.save_state()
	legacy.erase("damage_by_source")
	legacy.erase("damage_history_complete")
	_check(resumed.restore_state(legacy) and not resumed.damage_history_complete and resumed.damage_by_source.bow == 0,
		"An older save starts a partial sample with no inferred damage")
	_check(resumed.next_knot(), "Legacy play can progress")
	resumed.manual_impact("body", 18, 24, 0)
	_check(resumed.damage_by_source.bow == 18 and not resumed.save_state().damage_history_complete,
		"Partial samples stay identified on subsequent saves")


func _clocks() -> void:
	var run := Run.new()
	run.sample_session(1000000)
	run.tick(2)
	run.sample_session(3000000)
	run.set_session_focus(false, 5000000)
	run.sample_session(22000000)
	run.set_session_focus(true, 32000000)
	run.sample_session(33000000)
	_check(run.experience_us == 5000000 and run.elapsed == 2, "Focused menu time counts, time outside the window does not")
	run.stage = 5
	run.hp = 0
	run.prepare_gifts()
	run.choose_gift(run.gift_offer[0])
	run.sample_session(43000000)
	_check(run.experience_us == 15000000, "Reading the first summary belongs to the same experience")
	var restored := Run.new()
	_check(restored.restore_state(run.save_state()), "Focused clock saves")
	restored.sample_session(86000000000)
	restored.sample_session(86004000000)
	_check(restored.experience_us == 19000000, "The closed interval is excluded")
	restored.next_knot()
	restored.stage = 10
	restored.hp = 0
	restored.prepare_gifts()
	restored.sample_session(86010000000)
	restored.choose_gift(restored.gift_offer[0])
	restored.sample_session(86099000000)
	_check(restored.experience_us == 25000000 and restored.observations.second_gift == 2, "Final card locks both endpoints")
	var legacy := restored.save_state()
	legacy.erase("experience_us")
	_check(restored.restore_state(legacy) and restored.experience_us == -1, "Legacy focus history remains unavailable")


func _tenth_entry() -> void:
	var run := Run.new()
	run.stage = 9
	run.hp = 0
	run.sap = 100
	for id: String in ["damage", "damage", "workshop", "refund"]:
		_check(run.buy(id), "Buy real ranks for tenth target")
	run.first_gift = "D01"
	var ranks := run.ranks.duplicate()
	var paid := run.paid_prices.duplicate(true)
	var balance := run.sap
	_check(run.next_knot() and run.tenth_entry == {"ranks": ranks, "paid_prices": paid, "sap": balance,
		"bow": "branch", "gift": "D01"}, "Entry captures the actual holdings, prices and sap at spawn")
	_check(run.refund("damage") and run.tenth_entry.ranks.damage == 2 and run.tenth_entry.paid_prices.damage == paid.damage,
		"Refunds after entry never change the historical price or rank")
	var restored := Run.new()
	_check(restored.restore_state(run.save_state()) and restored.tenth_entry == run.tenth_entry, "The tenth snapshot reloads")
	var state := restored.snapshot()
	for lang: String in ["es", "en"]:
		var page := VBoxContainer.new()
		root.add_child(page)
		Log.build(page, state, lang, {"damage": ["Daño", "Damage"]}, {"D01": ["Liebre", "Hare"]})
		var tabs := page.get_child(1) as TabContainer
		_check(tabs.get_tab_count() == 3, "All report pages are navigable in " + lang)
		tabs.current_tab = 2
		var expected := ("Al aparecer el árbol     4 niveles comprados     ·     %d de savia" if lang == "es" else
			"When the tree appeared     4 upgrade levels owned     ·     %d sap on hand") % balance
		var has_balance := false
		for label: Label in tabs.get_current_tab_control().find_children("*", "Label", true, false):
			has_balance = has_balance or label.text == expected
		_check(has_balance, "Report renders the saved entrance balance in " + lang)
		page.free()
	var legacy := run.save_state()
	legacy.erase("tenth_entry")
	_check(restored.restore_state(legacy) and restored.tenth_entry.is_empty(), "An old save past entry has no invented snapshot")


func _gameplay() -> void:
	change_scene_to_file("res://main.tscn")
	await scene_changed
	var game := current_scene as Game
	game._start_campaign()
	game.run.stage = 6
	game.run.hp = game.run.max_hp()
	game.run.arrows = 8
	game.run._offer_target()
	game._redraw_world()
	var flight := {"id": "body", "damage": 8, "source": "sentinel", "end": game.clearing.target_center("body")}
	game._land_shot(flight)
	_check(game.run.damage_by_source.sentinel == 8 and game.run.target_active and game.run.arrows == 8,
		"A real crossbow impact has its own source and leaves the opportunity alone")
	flight = {"id": "target", "damage": 10, "weak_damage": 15, "serial": game.run.target_serial,
		"end": game.clearing.target_center("target")}
	game._land_shot(flight)
	_check(game.run.damage_by_source.bow == 15 and game.run.arrows == 11 and not game.run.target_active,
		"A real arrow impact credits bow damage and adds the returned arrows to the carried stack")
	game._manual_save()
	game._resume_campaign()
	_check(game.view == "pause" and game.run.arrows == 11 and game.run.damage_by_source.sentinel == 8,
		"Both counters survive reopening the actual game checkpoint")
	game._resume_play()
	game._land_shot(flight)
	_check(game.run.arrows == 11, "An arrow in flight at save time cannot reclaim a restored target")
	for voice: AudioStreamPlayer in game.find_children("*", "AudioStreamPlayer", true, false):
		voice.stop()
	game.queue_free()
	# Let the audio thread release the playback before tearing down the headless engine.
	var drained := Time.get_ticks_msec() + 100
	while Time.get_ticks_msec() < drained:
		await process_frame
