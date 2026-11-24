extends SceneTree

const Run = preload("res://scripts/run.gd")
const Log = preload("res://scripts/run_log.gd")
const Save = preload("res://scripts/save_data.gd")


func _initialize() -> void:
	var qa := OS.get_environment("ARCHER_QA_DIR").replace("\\", "/")
	if qa.is_empty() or not OS.get_user_data_dir().begins_with(qa + "/"):
		quit(1)
		return
	var run := Run.new()
	var piles := {"0": Vector3.RIGHT * 8, "knot": Vector3.RIGHT, "seed_0": Vector3.RIGHT * 16}
	var pos := Vector3.ZERO
	var hints = run.supply_hints
	var ok: bool = hints.choose(piles, pos, 570.0, false, true).is_empty()
	ok = ok and hints.choose(piles, pos, 599.9, true, true) == "knot"
	ok = ok and hints.choose(piles, pos, 599.9, true, false).is_empty()
	ok = ok and hints.choose(piles, pos, 600.0, true, true).is_empty()
	ok = ok and hints.choose(piles, pos, 659.9, true, true).is_empty()
	ok = ok and hints.choose(piles, pos, 660.0, false, true).is_empty()
	ok = ok and hints.choose(piles, pos, 660.0, true, true) == "knot"
	run.elapsed = 665.0
	var checkpoint := run.save_state()
	var restored := Run.new()
	ok = ok and restored.restore_state(checkpoint)
	hints = restored.supply_hints
	ok = ok and hints.choose(piles, piles["0"], 667.9, true, true) == "knot"
	ok = ok and hints.choose(piles, pos, 668.0, true, true).is_empty()
	ok = ok and hints.choose(piles, pos, 749.9, true, true).is_empty()
	ok = ok and hints.choose(piles, pos, 750.0, true, true) == "0"
	# The workshop delivers more arrows onto the same landing several times.
	for second in [751.0, 762.0, 808.0]:
		hints.choose(piles, pos, second, true, true)
	ok = ok and hints.choose(piles, pos, 840.0, true, true) == "seed_0"
	ok = ok and hints.choose(piles, pos, 930.0, true, true).is_empty()
	restored.arrows = restored.capacity() - 1
	restored.workshop_piles[0] = 3
	restored.elapsed = 940.0
	ok = ok and restored.collect(true, 0) == 1
	ok = ok and hints.choose(piles, pos, 1029.9, true, true).is_empty()
	ok = ok and hints.choose(piles, pos, 1030.0, true, true) == "0"
	checkpoint.erase("supply_hints")
	ok = ok and restored.restore_state(checkpoint)
	ok = ok and hints.choose(piles, pos, restored.elapsed, true, true).is_empty()
	var times := Log.splits({"broke_5": 70.0, "broke_10": 205.0})
	ok = ok and times == {"act1": 70.0, "act2": 135.0, "total": 205.0}
	ok = ok and Log.splits({"broke_10": 220.0}) == {"total": 220.0}
	ok = ok and Save.store_campaign({"profile": "demo"}) and Save.update_best_times(times)
	ok = ok and Save.update_best_times({"act1": 75.0, "act2": 120.0, "total": 210.0})
	ok = ok and Save.best_times() == {"act1": 70.0, "act2": 120.0, "total": 205.0}
	times = Log.splits({"broke_5": 82.0, "broke_10": 220.0, "broke_15": 312.0, "broke_20": 480.0})
	ok = ok and times.act3 == 92.0 and times.act4 == 168.0 and times.total20 == 480.0
	ok = ok and Save.update_best_times(times) and Save.best_times().total20 == 480.0 and Save.best_times().total == 205.0
	ok = ok and Save.load_campaign() == {"profile": "demo"}
	if ok:
		print("PASS: early and stale supply bearings, cooldowns, pickup, save migration, split timing and local records.")
	else:
		printerr("FAIL: first steps and local records")
	quit(0 if ok else 1)
