extends SceneTree
## Comprueba las reglas de los dos actos sin depender del perfil del jugador.

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
	_test_workshop_scatter()
	_test_tree_costs()
	_test_refunds()
	_test_volley_and_cadence()
	_test_precise_and_steady()
	_test_second_act()
	_test_required_core()
	if failures == 0:
		print("PASS: two acts, rank purchases and refunds, volley and precision, scattered arrows, save migration, bosses and rewards.")
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
	_expect(not run.buy("recurve") and not run.buy("spark"), "Sap alone cannot skip a parent purchase")
	_expect(run.buy("workshop"), "Damage opens the workshop")
	run.damage_part(run.hp, "body")
	run.next_knot()
	_expect(run.buy("weak") and run.buy("spark"), "Precision opens the spark")
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
	_expect(run.buy("rate"), "Rate opens the next bow")
	var balance := run.sap
	var arrows := run.arrows
	_expect(run.buy("recurve") and run.sap == balance - 37, "N4 recurve costs 37")
	_expect(run.bow == "recurve" and is_equal_approx(1.0 / run.shot_interval(), 3.5), "Recurve has 2.5 base shots/s plus one for rate")
	_expect(run.equip("branch") and run.arrows == arrows and run.shot_interval() == 0.5,
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
	_expect(impact.weak_spot and impact.direct == run.damage(true) and is_equal_approx(run.combo, 1.25), "Diana reports a precise hit and a single combo bonus")
	_expect(not run.manual_impact("body", run.damage(), run.damage(true), 0).weak_spot,
		"A regular body hit does not emit weak-point feedback")
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
	run.buy("weak")
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
	for id: String in Run.FIRST_GIFTS + Run.LATER_GIFTS + ["D03"]:
		var run := Run.new()
		run.gift_offer = [id]
		run.choose_gift(id)
		match id:
			"D01": _expect(is_equal_approx(run.shot_interval(), 1.0 / 1.5), "Hare's pulse changes cadence")
			"D03": _expect(is_equal_approx(run.production_rate(), 1.625), "Wellspring multiplies workshop output")
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


func _test_workshop_scatter() -> void:
	var run := Run.new()
	run.ranks = {"damage": 1, "workshop": 1}
	run.run_seed = 0
	run.tick(2.5)
	_expect(run.workshop_stock == 0 and run.workshop_flights.size() == 1 and run.workshop_flights[0].count == 3,
		"The first three crafted arrows leave together before they can be picked up")
	var restored := Run.new()
	_expect(restored.restore_state(run.save_state()), "A batch in flight saves and loads")
	for game in [run, restored]:
		game.tick(7.9)
		_expect(game.workshop_piles == [3, 3, 3, 3], "Four batches land in distinct zones")
		game.arrows = 23
		_expect(game.collect(true, 2) == 1 and game.workshop_piles == [3, 3, 2, 3],
			"A partial pickup takes only the landed arrows next to the archer")
		_expect(is_equal_approx(game.workshop_stock + game.collected + game.workshop_buffer + game.workshop_fraction, 13),
			"Ground, quiver, buffer and fractional production account for all thirteen arrows")
	_expect(restored.save_state() == run.save_state(), "Relaunch preserves the batch destination and balances")
	var legacy := run.save_state()
	for field in ["workshop_piles", "workshop_buffer", "workshop_flights", "batches_launched"]:
		legacy.erase(field)
	legacy.workshop_stock = 31
	_expect(restored.restore_state(legacy) and restored.workshop_stock == 31 and restored.workshop_piles == [31, 0, 0, 0],
		"All arrows saved at an H2 tray transfer to a reachable landing zone")


func _test_tree_costs() -> void:
	var run := Run.new()
	run.sap = 3000
	var initial := run.offers()
	for id in initial:
		_expect(initial[id].available == (id == "damage"), "Only damage is initially available")
	_expect(run.buy("damage") and run.sap == 3000, "The root is free even with a positive wallet")
	_expect(run.observations.has("first_purchase") and not run.observations.has("first_paid_purchase"),
		"Claiming the free root is recorded separately from spending sap")
	var first_costs := {"damage": 9, "rate": 14, "weak": 14, "recurve": 37, "workshop": 17,
		"capacity": 7, "wheel": 21, "pickup": 11, "pace": 21, "spark": 18}
	var offers := run.offers()
	var open_children := []
	for id in offers:
		if id != "damage" and offers[id].available:
			open_children.append(id)
	_expect(open_children.size() == 4 and open_children.has("rate") and open_children.has("weak")
		and open_children.has("workshop") and open_children.has("refund"), "The root opens exactly four branches")
	for id in first_costs:
		_expect(offers[id].cost == first_costs[id], "A previously available paid rank keeps its price: " + id)
	for i in range(9):
		_expect(run.buy("damage"), "Damage has ten purchasable ranks")
	_expect(run.observations.has("first_paid_purchase"), "The first paid upgrade records a separate playtest time")
	for i in range(10):
		_expect(run.buy("rate"), "Attack speed has ten purchasable ranks")
	_expect(not run.buy("damage") and not run.buy("rate") and run.damage_rank == 10 and run.rank_of("rate") == 10,
		"Buying a completed branch cannot charge an eleventh rank")
	var full_price := 0
	for node: Dictionary in Run.TREE.values():
		for price: int in node.costs:
			full_price += price
	var earned := 0
	for index in 9:
		earned += Run.SAP_BUDGET[index]
	_expect(earned >= full_price * 0.9 and earned + floori(Run.SAP_BUDGET[9] * 0.6) >= full_price,
		"Base sap affords at least 90% of ranks by value before N10 and all ranks during its fight")


func _test_refunds() -> void:
	var run := Run.new()
	run.sap = 6000
	for id in ["damage", "damage", "workshop", "capacity", "pickup", "leap", "rate", "recurve", "longbow"]:
		_expect(run.buy(id), "Purchases alone open " + id)
	_expect(not run.refund("damage") and run.buy("refund") and not run.refund("refund"), "Refunding needs the permanent license")
	var balance := run.sap
	_expect(run.refund("damage") and run.damage_rank == 1 and run.sap == balance + 9, "One right click restores exactly one paid level")
	_expect(run.refund("damage") and run.sap == balance + 9 and not run.refund("damage"), "A free root pays zero and cannot be sold twice")
	_expect(run.workshop and run.rank_of("leap") == 1 and not run.buy("rate"), "Owned descendants still work; missing parents gate new ranks")
	_expect(run.bow == "longbow" and run.refund("longbow") and run.bow == "recurve", "Selling the equipped bow selects the remaining purchased bow")
	run.arrows = run.capacity()
	run.workshop_stock = 3
	run.seed_drops = {"seed_0": 4}
	_expect(run.refund("capacity") and run.arrows == 40 and run.collect(true) == 0 and run.collect_seeds("seed_0") == 0,
		"Shrinking the quiver preserves surplus arrows without draining or duplicating the ground stock")
	run.tick(2.5)
	var held := run.workshop_fraction
	_expect(run.refund("workshop") and run.workshop_flights.size() == 1, "An already launched batch outlives the workshop")
	var reload := Run.new()
	_expect(reload.restore_state(run.save_state()) and reload.save_state() == run.save_state(), "Refund balances and loose ammo survive reload")
	reload.tick(20.0)
	_expect(reload.workshop_stock == 6 and reload.workshop_flights.is_empty() and is_equal_approx(reload.workshop_fraction, held),
		"A sold workshop stops crafting and its last batch still lands exactly once")
	var legacy := Run.new()
	legacy.ranks = {"damage": 2}
	var data := legacy.save_state()
	data.erase("paid_prices")
	data.erase("workshop_piles")
	_expect(reload.restore_state(data), "A five-target save can migrate its original damage purchase price")
	reload.sap = 6
	reload.buy("refund")
	reload.refund("damage")
	reload.refund("damage")
	_expect(reload.sap == 13, "Legacy damage ranks return their actual four and nine sap")
	reload.buy("damage")
	reload.refund("damage")
	_expect(reload.sap == 13, "Rebuying the free rank never creates extra sap")
	var migrated := legacy.save_state()
	migrated.erase("paid_prices")
	migrated.observations = {"buy_damage": 3.0, "buy_workshop": 40.0}
	_expect(reload.restore_state(migrated) and reload.paid_prices.damage[0] == 4,
		"A legacy root can be recognized after the previous build already migrated the workshop")
	migrated.observations.first_paid_purchase = 40.0
	_expect(reload.restore_state(migrated) and reload.paid_prices.is_empty(),
		"A free root followed by a recorded first purchase keeps its zero refund")


func _test_volley_and_cadence() -> void:
	var run := Run.new()
	run.sap = 6000
	for i in 9:
		run.buy("damage")
	_expect(run.damage() == 52 and run.volley_size() == 1, "The first nine damage levels compound by twenty percent")
	_expect(run.buy("refund") and not run.buy("pet"), "Petting opens after maxing damage")
	run.buy("damage")
	_expect(run.buy("pet") and run.damage() == 62 and run.volley_size() == 3, "Damage ten unlocks three full-strength arrows and the late pet node")
	run.refund("damage")
	_expect(run.volley_size() == 1 and run.rank_of("pet") == 1, "Selling the capstone removes multishot and preserves the dog interaction")
	for i in 10:
		run.buy("rate")
		_expect(is_equal_approx(1.0 / run.shot_interval(), 2 + i), "Each rate level adds exactly one shot per second")
	run.buy("recurve")
	run.buy("longbow")
	_expect(run.bow == "longbow" and is_equal_approx(1.0 / run.shot_interval(), 12) and run.damage() == 114,
		"The third bow can be bought by prerequisites alone and has its own damage and cadence")


func _test_precise_and_steady() -> void:
	var run := Run.new()
	run.sap = 400
	for id in ["damage", "weak", "spark", "crit", "combo", "steady"]:
		run.buy(id)
	run.run_seed = 22
	run.stage = 2
	run.hp = run.max_hp()
	run.tick(2.0)
	_expect(run.damage(true) == roundi(10 * 1.2 * Run.POWER[1] * 2.0), "Precision doubles a weak-point hit")
	run.manual_impact("target", run.damage(), run.damage(true), run.target_serial)
	_expect(is_equal_approx(run.combo, 1.5) and is_equal_approx(run.combo_grace, 3.5), "An aimed hit with the combo node earns twice the streak gain and longer grace")
	var saw_critical := false
	var saw_normal := false
	for i in 80:
		run.tick(1.0)
		run.begin_volley()
		var expected := 10.0 * 1.2 * Run.POWER[1]
		expected *= 1.2 if i >= 3 else 1.0
		expected *= 2.0 if run.volley_critical else 1.0
		saw_critical = saw_critical or run.volley_critical
		saw_normal = saw_normal or not run.volley_critical
		_expect(run.volley_damage() == roundi(expected), "Only rolled criticals and uninterrupted volleys earn their modifiers")
	_expect(saw_critical and saw_normal, "The seeded volley series contains both critical and regular shots")
	var restored := Run.new()
	restored.restore_state(run.save_state())
	run.tick(1.0)
	restored.tick(1.0)
	run.begin_volley()
	restored.begin_volley()
	_expect(restored.volley_damage() == run.volley_damage() and restored.steady_count == 4, "Resuming preserves the next critical roll and firing streak")
	restored.tick(2.0)
	restored.begin_volley()
	_expect(restored.steady_count == 1, "A long break resets the uninterrupted-shot bonus")


func _test_second_act() -> void:
	var original := Run.new()
	original.stage = 5
	original.hp = 0
	original.chosen_gift = "D09"
	original.ranks = {"damage": 2, "workshop": 1}
	var saved := original.save_state()
	for field in ["first_gift", "core_phase", "workshop_piles", "workshop_buffer", "workshop_flights", "batches_launched"]:
		saved.erase(field)
	var run := Run.new()
	_expect(run.restore_state(saved) and run.at_act_summary() and run.snapshot().can_continue_act,
		"A completed H2 save opens the first act result and can continue")
	_expect(run.next_knot() and run.stage == 6 and is_equal_approx(run.pickup_radius(), 3.5) and run.damage_rank == 2,
		"An older card and purchases remain active after continuing")
	while run.stage < 10:
		run.damage_part(run.hp, "body")
		_expect(run.next_knot(), "Targets six through nine advance in the same campaign")
	var total := run.hp
	for phase in 3:
		var active := "core_%d" % phase
		var inactive := "core_%d" % ((phase + 1) % 3)
		var current_hit := run.manual_impact(active, 10, 15, 0)
		var inactive_hit := run.manual_impact(inactive, 10, 15, 0)
		_expect(current_hit.weak_spot and current_hit.direct == 15 and not inactive_hit.weak_spot and inactive_hit.direct == 10,
			"Only the current hollow rewards a precise manual hit")
		var hp_before := run.hp
		var effective := run.damage_part(total, "body")
		_expect(effective == hp_before - run.hp and run.core_phase == mini(phase + 1, 2),
			"Ordinary damage can clear a phase and cannot skip the next cavity")
		var check := Run.new()
		_expect(check.restore_state(run.save_state()) and check.hp == run.hp and check.core_phase == run.core_phase,
			"Reopening during the second boss restores the correct hollow")
	_expect(run.hp == 0 and not run.next_knot(), "N10 is the end of this demo")
	run.prepare_gifts()
	_expect(run.gift_offer.size() == 3 and not run.gift_offer.has("D09"), "The second offer excludes the previous reward")
	var second: String = run.gift_offer[0]
	_expect(run.choose_gift(second) and run.has_gift("D09") and run.has_gift(second) and run.at_act_summary(),
		"The second choice preserves both rewards and reaches the final result")


func _test_required_core() -> void:
	var run := Run.new()
	run.stage = 10
	run.hp = run.max_hp()
	run.arrows = 0
	for phase in 3:
		var current_layer := run.vulnerability("body")
		var hit := run.manual_impact("body", run.max_hp(), run.max_hp(), 0)
		_expect(hit.direct == current_layer - 1 and run.core_phase == phase and run.core_needs_hit(),
			"A body shot alone must leave one point in each layer")
		var before := run.save_state()
		_expect(not run.manual_impact("body", 100, 200, 0).hit and run.save_state() == before,
			"Camping on the trunk cannot farm rewards or pass the required target")
		_expect(not run.manual_impact("root_%d" % phase, 100, 200, 0).hit,
			"Shooting at the foot of the trunk cannot bypass aiming")
		var resumed := Run.new()
		_expect(resumed.restore_state(before) and resumed.core_needs_hit(), "A blocked layer survives reopening")
		if phase == 1:
			var finish := run.manual_impact("core_1", 100, 200, 0)
			_expect(finish.direct == 1, "The matching hollow unlocks the next layer")
		else:
			_expect(run.strike_part(20, "root_%d" % ((phase + 1) % 3)) == 0,
				"Only the root linked to the exposed hollow opens this layer")
			_expect(run.strike_part(20, "root_%d" % phase) == 1 and run.arrows == 0,
				"An archer with no arrows can advance by striking the matching root")
	_expect(run.hp == 0, "Three aimed contacts complete the second boss")
