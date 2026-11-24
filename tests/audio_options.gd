extends SceneTree

const Game := preload("res://scripts/game.gd")
const Prefs := preload("res://scripts/play_preferences.gd")
const Timbres := preload("res://scripts/arrow_timbres.gd")
var game: Game
var failures: PackedStringArray = []

func _initialize() -> void:
	var qa := OS.get_environment("ARCHER_QA_DIR").replace("\\", "/")
	if qa.is_empty() or not OS.get_user_data_dir().begins_with(qa + "/"):
		printerr("Use an isolated QA profile for the audio settings test.")
		quit(1)
		return
	_run.call_deferred()

func _check(value: bool, message: String) -> void:
	if not value:
		failures.append(message)
		printerr("FAIL: ", message)

func _pick(picker: OptionButton, index: int) -> void:
	picker.select(index)
	picker.item_selected.emit(index)

func _run() -> void:
	change_scene_to_file("res://main.tscn")
	await scene_changed
	game = current_scene
	var hud := game.hud
	var sound := game.archer._sound
	hud._open_submenu("settings")
	hud._change_tab("audio")
	var old_branch_hit: AudioStream = sound._voices.hit.stream
	var shot := hud.find_child("ShotTimbre", true, false) as OptionButton
	var impact := hud.find_child("ImpactTimbre", true, false) as OptionButton
	if not shot or not impact:
		printerr("FAIL: missing release/impact selectors")
		quit(1)
		return
	for selector: OptionButton in [shot, impact]:
		var cue := "shot" if selector == shot else "arrow_impact"
		var variants := {}
		for index in selector.item_count:
			var opposite := "arrow_impact" if selector == shot else "shot"
			var other_stream: AudioStream = sound._voices[opposite].stream
			_pick(selector, index)
			var audition: AudioStreamPlayer = sound._preview_voices[cue]
			var live: AudioStreamPlayer = sound._voices[cue]
			variants[live.stream] = true
			_check(paused and audition.can_process() and audition.playing, "Changing a timbre auditions it while paused")
			_check(audition.stream == live.stream and audition.volume_db == live.volume_db, "Audition uses the live stream and gain")
			_check(sound._voices[opposite].stream == other_stream, "Selecting one timbre preserves the other")
		_check(variants.size() == 5, "Five distinct playable variants for " + cue)
	_pick(shot, 1)
	_pick(impact, 2)
	var reloaded := Prefs.new()
	reloaded.load_settings()
	_check(reloaded.options.shot_timbre == shot.get_selected_metadata() and
			reloaded.options.impact_timbre == impact.get_selected_metadata(), "Both independent selections survive reloading")
	var bow_volume := hud.find_child("VolumeBow", true, false) as HSlider
	var impact_level: float = sound._voices.arrow_impact.volume_db
	bow_volume.value = 0.0
	_check(sound._preview_voices.shot.volume_db < -90 and sound._voices.arrow_impact.volume_db == impact_level,
			"Muting bow release preserves the wood impact level")
	bow_volume.value = 1.0
	(hud.find_child("PreviewPair", true, false) as Button).pressed.emit()
	_check(sound._preview_voices.shot.playing and not sound._preview_voices.arrow_impact.playing, "Combined preview starts with a shot")
	await create_timer(0.1, true, false, true).timeout
	_check(sound._preview_voices.arrow_impact.playing, "The impact follows the release even during pause")
	(hud.find_child("PreviewBurst", true, false) as Button).pressed.emit()
	root.focus_exited.emit()
	await create_timer(0.18, true, false, true).timeout
	_check(not sound._preview_voices.shot.playing and not sound._preview_voices.arrow_impact.playing, "Focus loss cancels the entire burst")
	root.focus_entered.emit()
	hud._switch_language()
	shot = hud.find_child("ShotTimbre", true, false) as OptionButton
	_check(shot.accessibility_name == "String release" and shot.text == "String and fiber · recording", "English labels keep the selection")
	(hud.find_child("PreviewBurst", true, false) as Button).pressed.emit()
	hud._open_submenu("")
	await create_timer(0.18, true, false, true).timeout
	_check(not sound._preview_voices.shot.playing and not sound._preview_voices.arrow_impact.playing, "Leaving settings cancels pending sounds")
	game._start_campaign()
	game.archer.play_shot(game.clearing.target_center("body"))
	_check(sound._voices.shot.playing, "The live bow uses the selected release")
	var flight := {"end": Vector3.ZERO, "id": "body", "damage": 1, "weak_damage": 1, "serial": game.run.target_serial}
	flight.source = "sentinel"
	game._land_shot(flight)
	_check(not sound._voices.arrow_impact.playing, "Crossbow hits stay independent")
	flight.erase("source")
	flight.damage = game.run.hp
	game._land_shot(flight)
	_check(game.run.hp == 0 and sound._voices.arrow_impact.playing and sound._voices["break"].playing,
			"The final manual arrow plays both the selected impact and the tree breaking")
	_check(not sound._voices.hit.playing and sound._voices.hit.stream == old_branch_hit, "Branch hit keeps its original voice")
	var config := ConfigFile.new()
	config.load(Prefs.FILE)
	config.set_value("comfort", Timbres.SHOT, false)
	config.set_value("comfort", Timbres.IMPACT, "retired_sample")
	config.save(Prefs.FILE)
	reloaded.load_settings()
	_check(reloaded.options.shot_timbre == Timbres.DEFAULT_SHOT and reloaded.options.impact_timbre == Timbres.DEFAULT_IMPACT,
			"Invalid or retired sample IDs fall back to playable defaults")
	if failures.is_empty():
		print("PASS: Bilingual bow audio selectors, persisted samples, paused previews, live impacts and focus cancellation.")
	unload_current_scene()
	# The mixer uses wall time even when the test accelerates simulation with --fixed-fps.
	for i in 4:
		await process_frame
		OS.delay_msec(30)
	quit(0 if failures.is_empty() else 1)
