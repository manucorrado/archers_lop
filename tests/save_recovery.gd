extends SceneTree

const Save = preload("res://scripts/save_data.gd")


func _initialize() -> void:
	var qa := OS.get_environment("ARCHER_QA_DIR").replace("\\", "/")
	if qa.is_empty() or not OS.get_user_data_dir().begins_with(qa + "/"):
		printerr("Use tests/run-tests.ps1 to isolate the campaign under test.")
		quit(1)
		return
	var states := [
		{"stage": 5, "left_hp": 420, "right_hp": 932},
		{"stage": 5, "left_hp": 0, "right_hp": 491},
		{"stage": 5, "cards": ["D04", "D08", "D01"]},
	]
	for state: Dictionary in states:
		if not Save.store_campaign(state) or Save.load_campaign() != state:
			printerr("FAIL: checkpoint did not round-trip")
			quit(1)
			return
	# After three successful writes A is current and B contains the previous phase.
	var interrupted := FileAccess.open(Save.SLOTS[1] + ".tmp", FileAccess.WRITE)
	interrupted.store_8(1)
	interrupted.close()
	var ok: bool = Save.load_campaign() == states[2]
	var corrupted := FileAccess.open(Save.SLOTS[0], FileAccess.READ_WRITE)
	corrupted.seek_end(-4)
	var original := corrupted.get_8()
	corrupted.seek_end(-4)
	corrupted.store_8(original ^ 0xff)
	corrupted.close()
	ok = ok and Save.load_campaign() == states[1]
	ok = ok and Save.store_campaign(states[2]) and Save.load_campaign() == states[2]
	if ok:
		print("PASS: three checkpoints, interrupted write, checksum failure, fallback and subsequent save.")
	else:
		printerr("FAIL: campaign recovery")
	quit(0 if ok else 1)
