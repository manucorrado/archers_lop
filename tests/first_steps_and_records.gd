extends SceneTree

const Run = preload("res://scripts/run.gd")
const Guide = preload("res://scripts/first_steps.gd")
const Log = preload("res://scripts/run_log.gd")
const Save = preload("res://scripts/save_data.gd")


func _initialize() -> void:
	var qa := OS.get_environment("ARCHER_QA_DIR").replace("\\", "/")
	if qa.is_empty() or not OS.get_user_data_dir().begins_with(qa + "/"):
		quit(1)
		return
	var run := Run.new()
	var state := run.snapshot()
	var target := Vector3(0, 2, -4)
	var pos := Vector3.ZERO
	var ok: bool = Guide.objective(state, pos, target).kind == "wood"
	state.hits = 1
	ok = ok and Guide.objective(state, pos, target).kind == "dog"
	state.near_dog = true
	ok = ok and Guide.objective(state, pos, target).is_empty()
	state.near_dog = false
	state.workshop = true
	state.arrows = 4
	ok = ok and Guide.objective(state, pos, target).is_empty()
	state.workshop_piles = [3, 3, 0, 0]
	state.workshop_stock = 6
	var goal := Guide.objective(state, pos, target)
	ok = ok and goal.kind == "supply" and goal.at.z == Guide.Clearing.WORKSHOP_LANDINGS[1].z
	state.collected = 3
	ok = ok and Guide.objective(state, pos, target).kind == "wood"
	state.fired_after_collect = true
	ok = ok and Guide.objective(state, pos, target).is_empty()
	var times := Log.splits({"broke_5": 70.0, "broke_10": 205.0})
	ok = ok and times == {"act1": 70.0, "act2": 135.0, "total": 205.0}
	ok = ok and Log.splits({"broke_10": 220.0}) == {"total": 220.0}
	ok = ok and Save.store_campaign({"profile": "demo"}) and Save.update_best_times(times)
	ok = ok and Save.update_best_times({"act1": 75.0, "act2": 120.0, "total": 210.0})
	ok = ok and Save.best_times() == {"act1": 70.0, "act2": 120.0, "total": 205.0}
	ok = ok and Save.load_campaign() == {"profile": "demo"}
	if ok:
		print("PASS: first route waymarks, split timing and local records independent of the campaign.")
	else:
		printerr("FAIL: first steps and local records")
	quit(0 if ok else 1)
