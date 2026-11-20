extends SceneTree
## Comprueba las reglas de N1–5 sin depender de la animación ni del perfil del jugador.

const Run := preload("res://scripts/run.gd")
var failures := 0


func _initialize() -> void:
	_test_build_and_combo()
	_test_encounters()
	_test_boss_and_gifts()
	_test_spark_at_boss_threshold()
	_test_gift_effects()
	_test_observed_session()
	_test_empty_return()
	if failures == 0:
		print("PASS: act I purchases, combo, opportunities, boss milestones and seeded gifts.")
	quit(1 if failures > 0 else 0)


func _expect(condition: bool, description: String) -> void:
	if not condition:
		printerr("FAIL: ", description)
		failures += 1


func _test_build_and_combo() -> void:
	var run := Run.new()
	for i in 6:
		run.note_shot()
		run.manual_impact("body", run.damage(), run.damage(true), 0)
	_expect(run.sap == 4 and run.hp == 100, "Six regular arrows pay four sap")
	_expect(run.buy("damage") and run.damage() == 12, "The first purchase changes the next shot")
	run.damage_part(100, "body")
	run.next_knot()
	run.sap = 150
	_expect(not run.buy("recurve") and not run.buy("spark"), "Act gates cannot be bypassed with sap")
	_expect(run.buy("workshop"), "The workshop is available from N2")
	run.damage_part(run.hp, "body")
	run.next_knot()
	_expect(run.buy("spark"), "The first phenomenon opens in N3")
	var post_purchase_hits := run.hits
	for i in 7:
		var impact := run.manual_impact("body", run.damage(), run.damage(true), 0)
		_expect(impact.spark == 0, "Chispa waits for its eighth primary hit")
	var discharge := run.manual_impact("body", run.damage(), run.damage(true), 0)
	_expect(discharge.spark == roundi(20 * Run.POWER[2]) and run.hits == post_purchase_hits + 8,
		"Chispa pays damage without increasing manual hits")
	var before := run.combo
	run.tick(2.5)
	_expect(is_equal_approx(before, run.combo), "Combo holds during the grace period")
	run.tick(0.4)
	_expect(is_equal_approx(run.combo, before - 0.2), "Combo decays by half a unit per second")
	run.damage_part(run.hp, "body")
	run.next_knot()
	var balance := run.sap
	var arrows := run.arrows
	_expect(run.buy("recurve") and run.sap == balance - 37, "N4 recurve costs 37")
	_expect(run.bow == "recurve" and is_equal_approx(run.shot_interval(), 0.4), "Recurve fires 2.5 times per second")
	_expect(run.equip("branch") and run.arrows == arrows and run.shot_interval() == 1.0,
		"Changing bows preserves the quiver and changes cadence")


func _test_encounters() -> void:
	var run := Run.new()
	run.run_seed = 492
	run.sap = 8
	run.buy("damage")
	run.damage_part(run.hp, "body")
	run.next_knot()
	run.tick(2.0)
	_expect(run.target_active and run.target_serial == 1, "The first diana is shown during N2")
	var impact := run.manual_impact("target", run.damage(), run.damage(true), run.target_serial)
	_expect(impact.direct == run.damage(true) and is_equal_approx(run.combo, 1.25), "Diana applies weak damage and a single combo bonus")
	run.tick(8)
	_expect(run.seeds.size() == 3, "The first seed rain displays its targets")
	impact = run.manual_impact("seed_0", run.damage(), run.damage(true), run.event_serial)
	_expect(impact.hit and impact.direct == 0 and run.seed_drops.seed_0 == 4, "A seed drops a physical bundle")
	_expect(not run.manual_impact("seed_0", 10, 15, run.event_serial).hit, "A second hit cannot collect the same reward")
	run.arrows = run.capacity() - 1
	_expect(run.collect_seeds("seed_0") == 1 and run.seed_drops.seed_0 == 3, "Partial collection leaves the remainder")
	var restored := Run.new()
	_expect(restored.restore_state(run.save_state()), "An active event can be restored")
	_expect(restored.save_state() == run.save_state(), "RNG, event, combo and drops survive restore")
	run.tick(11)
	restored.tick(11)
	_expect(run.event_remaining == 0 and run.hp > 0 and restored.save_state() == run.save_state(),
		"Expiring the event leaves identical campaign progress")


func _test_boss_and_gifts() -> void:
	var run := Run.new()
	run.run_seed = 921
	for i in 4:
		run.damage_part(run.hp, "body")
		run.next_knot()
	var budget_before := run.sap
	var first_half := floori(run.max_hp() * 0.5)
	_expect(run.damage_part(run.max_hp() * 2, "body") == first_half, "Overshoot stops at the split")
	_expect(run.split and run.left_hp + run.right_hp == run.hp, "The remaining health belongs to two live roots")
	var checkpoint := Run.new()
	checkpoint.restore_state(run.save_state())
	var left_before := run.left_hp
	_expect(checkpoint.damage_part(100000, "body") == 0, "The old body cannot take split damage")
	run.damage_part(100000, "left")
	checkpoint.damage_part(100000, "left")
	_expect(checkpoint.save_state() == run.save_state() and left_before > 0 and run.hp == run.right_hp,
		"Resuming the split yields the same checkpoint after the first lobe")
	_expect(run.damage_part(100000, "left") == 0 and run.hp > 0, "A destroyed lobe cannot damage the other")
	run.damage_part(100000, "right")
	_expect(run.hp == 0 and run.sap == budget_before + Run.SAP_BUDGET[4], "Boss shares a single sap budget")
	run.prepare_gifts()
	var offer := run.gift_offer.duplicate()
	_expect(offer.size() == 3 and offer[0] != offer[1] and offer[0] != offer[2] and offer[1] != offer[2],
		"The three offered cards are distinct")
	checkpoint.restore_state(run.save_state())
	checkpoint.prepare_gifts()
	_expect(checkpoint.gift_offer == offer and not offer.has("D03"), "Offer keeps its exact order and excludes the workshop card without a workshop")
	_expect(checkpoint.choose_gift(offer[1]) and not checkpoint.choose_gift(offer[0]), "Exactly one choice can be confirmed")
	run.restore_state(checkpoint.save_state())
	_expect(run.chosen_gift == offer[1] and run.gift_offer.is_empty(), "The confirmed gift survives a second resume")


func _test_spark_at_boss_threshold() -> void:
	var run := Run.new()
	for i in 4:
		run.damage_part(run.hp, "body")
		run.next_knot()
	run.buy("damage")
	run.buy("spark")
	for i in 7:
		run.manual_impact("body", run.damage(), run.damage(true), 0)
	run.damage_part(run.vulnerability("body") - run.damage() - 10, "body")
	var before := run.save_state()
	var result := run.manual_impact("body", run.damage(), run.damage(true), 0)
	_expect(result.spark == 10 and run.split and run.left_hp + run.right_hp == run.hp,
		"The eighth-hit spark opens the boss split and discards its excess damage")
	var checkpoint := Run.new()
	checkpoint.restore_state(before)
	checkpoint.manual_impact("body", checkpoint.damage(), checkpoint.damage(true), 0)
	_expect(checkpoint.save_state() == run.save_state(), "Replaying a pending threshold hit reproduces the exact same payment")
	var after := run.save_state()
	var repeated := run.manual_impact("body", 100000, 100000, 0)
	_expect(not repeated.hit and after == run.save_state(), "A late hit on the body cannot repeat the split or its payment")


func _test_gift_effects() -> void:
	for id: String in Run.FIRST_GIFTS + ["D03"]:
		var run := Run.new()
		run.gift_offer = [id]
		run.choose_gift(id)
		match id:
			"D01": _expect(is_equal_approx(run.shot_interval(), 1.0 / 1.5), "Hare's pulse changes cadence")
			"D03": _expect(is_equal_approx(run.production_rate(), 1.95), "Wellspring multiplies workshop output")
			"D04": _expect(run.damage() == 12, "Living bark changes manual damage")
			"D08": _expect(run.capacity() == 48, "Deep quiver holds an extra 24 arrows")
			"D09": _expect(is_equal_approx(run.pickup_radius(), 3.5), "Magnetic leaves extends pickup reach")
			"D14":
				run.manual_impact("body", 10, 15, 0)
				_expect(is_equal_approx(run.combo_grace, 4.5), "Long breath extends the combo grace window")


func _test_observed_session() -> void:
	var run := Run.new()
	run.sample_session(5000000)
	run.tick(6)
	run.sample_session(11000000)
	run.manual_impact("body", 10, 15, 0)
	run.sap = 4
	# Three minutes reading the shop with simulation paused.
	run.sample_session(191000000)
	run.buy("damage")
	_expect(run.observations.first_purchase == 6 and run.session_observations.first_purchase == 186,
		"Time spent reading the shop counts towards the observed 90-second target")
	var data := run.save_state()
	var restored := Run.new()
	restored.restore_state(data)
	restored.sample_session(2000000000)
	restored.sample_session(2003000000)
	restored.mark("after_reopen")
	_expect(restored.session_observations.after_reopen == 189 and restored.observations.after_reopen == 6,
		"Only time in an open session is added after loading into pause")
	for field in ["session_elapsed_us", "session_observations", "at_workshop"]:
		data.erase(field)
	var legacy := Run.new()
	_expect(legacy.restore_state(data), "An older checkpoint without observed times still loads")
	legacy.sample_session(9000000)
	legacy.mark("after_legacy_load")
	_expect(legacy.observations.first_purchase == 6 and legacy.session_observations.is_empty(),
		"An unknown observed duration is never inferred from active campaign time")


func _test_empty_return() -> void:
	var run := Run.new()
	run.ranks["workshop"] = 1
	run.arrows = 0
	run.workshop_stock = 1
	run.observe_workshop_visit(true)
	run.collect(true)
	run.note_shot()
	run.observe_workshop_visit(true)
	run.workshop_stock = 1
	run.collect(true)
	run.note_shot()
	var restored := Run.new()
	restored.restore_state(run.save_state())
	restored.observe_workshop_visit(true)
	_expect(not restored.observations.has("returned_empty_to_workshop"),
		"Shooting on the workshop tray and reloading in place are not new visits")
	restored.observe_workshop_visit(false)
	restored.observe_workshop_visit(true)
	_expect(restored.observations.has("returned_empty_to_workshop"),
		"Returning from outside with an empty quiver records a distinct visit")
