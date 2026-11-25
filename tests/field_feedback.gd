extends SceneTree

const Game := preload("res://scripts/game.gd")
const Run := preload("res://scripts/run.gd")
const AmountFormat := preload("res://scripts/amount_format.gd")
var failures := 0

func _initialize() -> void:
	var qa := OS.get_environment("ARCHER_QA_DIR").replace("\\", "/")
	if qa.is_empty() or not OS.get_user_data_dir().begins_with(qa + "/"):
		quit(1)
		return
	exercise.call_deferred()

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: ", message)

func exercise() -> void:
	for pair: Array in [[0,"0"], [850,"850"], [12500,"12,500"], [99999,"99,999"],
			[100000,"100K"], [9999999,"9999K"], [10000000,"10M"],
			[9999999999,"9999M"], [10000000000,"10B"], [83825374000,"83B"],
			[9223372036854775807,"9223Qa"], ["1" + "0".repeat(64),"10Vg"],
			["9".repeat(67),"9999Vg"], ["1" + "0".repeat(67),"1e67"]]:
		check(AmountFormat.short(pair[0], "en") == pair[1], "Truncated damage display " + str(pair[0]))
	check(AmountFormat.short(99999, "es") == "99.999", "Use local grouping for full amounts")
	for group in range(2, AmountFormat.SUFFIXES.size()):
		var boundary := "1" + "0".repeat(group * 3 + 1)
		check(AmountFormat.short(boundary) == "10" + AmountFormat.SUFFIXES[group], "First two-digit amount per suffix")
	var run := Run.new()
	for i in 3:
		check(run.take_pickup_notice(), "First pickups are announced")
	var restored := Run.new()
	check(restored.restore_state(run.save_state()), "Reload pickup counter")
	check(restored.take_pickup_notice() and restored.take_pickup_notice() and not restored.take_pickup_notice(),
			"Only two pickup notices remain after save")
	var former := [343971,682439,1241118,2224036,5675221,5405481,10656062,19868582,35171092,83825374]
	for i in former.size():
		run.stage = 11 + i
		var factor := 1000 if run.stage == 20 else 100
		var old := run.save_state()
		old.hp = int(former[i]) / 2
		old.erase("target_max_hp")
		check(restored.restore_state(old) and restored.max_hp() == former[i] * factor and restored.hp == old.hp * factor,
				"Keep the damaged fraction of an old target %d" % run.stage)
		check(restored.restore_state(restored.save_state()) and restored.hp == old.hp * factor, "Scale only once")
	var legacy := run.save_state()
	legacy.hp = 0
	legacy.erase("target_max_hp")
	legacy.ranks = {"longbow": 1, "recurve": 1, "refund": 1}
	legacy.paid_prices = {}
	check(restored.restore_state(legacy) and restored.hp == 0 and restored.refund("longbow") and restored.refund("recurve")
			and restored.sap == legacy.sap + 1670 + 37, "Completed runs and historical bow refunds survive")
	run.stage = 20
	run.hp = run.max_hp()
	var balance := run.sap
	check(run.damage_part(83825374000, "body") == 83825374000 and run.hp == 0 and run.sap == balance + 10478171750,
			"Final tree pays full 64-bit damage")
	var game := Game.new()
	root.add_child(game)
	await process_frame
	game._start_campaign()
	var marker := game.trail_marker
	game.run.elapsed = 89.0
	game._sync()
	check(marker.show_dog_guide, "Early dog bearing")
	game.run.elapsed = 90.0
	game._sync()
	check(not marker.show_dog_guide, "Expired dog bearing")
	game.run.elapsed = 1.0
	game.run.buy("damage")
	game._sync()
	check(not marker.show_dog_guide, "Finding the first purchase ends the bearing early")
	var point := game.clearing.target_center("body")
	var numbers := game.hud.impact_numbers
	game.hud.show_damage(12, point)
	game.hud.show_damage(8, point + Vector3.RIGHT * 0.1)
	game.hud.show_damage(7, point + Vector3.LEFT * 2)
	check(numbers.stamps.size() == 2 and numbers.stamps[0].amount == 20 and numbers.stamps[1].point == point + Vector3.LEFT * 2,
			"Group only nearby world-space impacts")
	var camera := game.archer.camera
	var before := camera.unproject_position(point)
	game.archer.rotate_y(0.2)
	check(before.distance_to(camera.unproject_position(point)) > 5.0 and numbers.stamps[0].point == point + Vector3.RIGHT * 0.1,
			"Turning moves the projected label, leaving its anchor on the tree")
	game.hud.options.damage_opacity = 0.0
	game.hud.show_damage(20, point, "sentinel")
	check(numbers.stamps.size() == 2, "Hidden damage numbers stay hidden")
	if failures == 0:
		print("PASS: world impacts, guidance expiry, five pickups, historical bow prices and 64-bit late health.")
	quit(1 if failures else 0)
