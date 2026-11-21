extends SceneTree
## Continue a conversation through ordinary input, language changes and a relaunch.

const Game := preload("res://scripts/game.gd")
const Tales := preload("res://assets/charlas_de_brizno.tres")
var game: Game
var failed := false

func _initialize() -> void:
	var qa := OS.get_environment("ARCHER_QA_DIR").replace("\\", "/")
	if qa.is_empty() or not OS.get_user_data_dir().begins_with(qa + "/"):
		printerr("Use tests/run-tests.ps1 to isolate the campaign under test.")
		quit(1)
		return
	_run.call_deferred()

func _expect(ok: bool, message: String) -> void:
	if not ok:
		printerr("FAIL: ", message)
		failed = true

func _load_game() -> void:
	change_scene_to_file("res://main.tscn")
	await scene_changed
	game = current_scene
	await physics_frame

func _tap(code: Key) -> void:
	for down: bool in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = code
		event.keycode = code
		event.pressed = down
		Input.parse_input_event(event)
		Input.flush_buffered_events()
		await physics_frame

func _check_unfinished_stories() -> void:
	var original := Tales.entries.duplicate()
	Tales.entries.assign([{}, {"id": "missing", "es": ["Hola"]}, {"id": "empty", "es": [], "en": []},
		{"id": "mismatch", "es": ["Hola", "Chau"], "en": ["Hello"]}, {"id": "blank", "es": ["Hola"], "en": [" "]},
		{"id": "pair", "es": PackedStringArray(["Listo"]), "en": PackedStringArray(["Ready"])},
		{"id": "pair", "es": ["Otro"], "en": ["Another"]}])
	_expect(Tales.choose({}, 1, false, false) == "pair" and Tales.readable_stories().size() == 1,
		"Missing or unfinished translations are skipped, including duplicates after a valid id")
	_expect(Tales.find_story("pair").es[0] == "Listo", "The first valid story with an id is used")
	game.dialogue.restore({"heard": {"missing": 1}, "topic": "missing", "page": 1})
	_expect(game.dialogue.topic.is_empty() and game.dialogue.heard.get("missing") == 1,
		"An old bookmark into an unfinished translation safely closes while preserving its history")
	game.dialogue.begin(1, false, false)
	game.dialogue.display("en", "E", "Esc")
	_expect(game.dialogue.line.text == "Ready", "Another complete story remains readable")
	Tales.entries.clear()
	_expect(not game.dialogue.advance() and game.dialogue.topic.is_empty(), "Removing a current story in the Inspector closes it safely")
	Tales.entries.assign(original)

func _run() -> void:
	_expect(Tales.readable_stories().size() == Tales.entries.size(), "Every shipped story has matching pages in both languages")
	_expect(Tales.choose({"arrival": 1}, 5, true, true) == "twins", "A newly split tree prompts its own story")
	_expect(Tales.choose({"arrival": 1}, 6, true, false) == "far_side", "The second act has an account of the changed clearing")
	await _load_game()
	game._start_campaign()
	await _tap(KEY_E)
	_expect(game.view == "play", "E at spawn does not open a conversation")
	game.archer.position = game.clearing.BRIZNO_POSITION + Vector3(0, 0, 1.45)
	game._sync()
	_expect(game.hud.guide_text.text.contains("Hablar con Brizno"), "Standing near Brizno names the interaction")
	await _tap(KEY_E)
	_expect(game.view == "dialogue" and game.dialogue.visible and not game.hud.hud.visible, "Interaction opens only the conversation")
	_expect(game.dialogue.line.text == Tales.find_story("arrival").es[0], "Brizno introduces himself in Spanish")
	var before := game.run.elapsed
	for i in 20:
		await physics_frame
	_expect(is_equal_approx(game.run.elapsed, before), "Reading freezes active time")
	await _tap(KEY_E)
	_expect(game.dialogue.page == 1, "One E press advances exactly one page")
	await _load_game()
	game.hud.language = "en"
	game.hud.preferences.language = "en"
	game._resume_campaign()
	_expect(game.view == "dialogue" and game.dialogue.line.text == Tales.find_story("arrival").en[1], "Continue restores the same open page in the active language")
	await _tap(KEY_ESCAPE)
	_expect(game.view == "play", "Escape releases the player without counting a finished conversation")
	await _tap(KEY_E)
	_expect(game.dialogue.page == 1 and game.dialogue.heard.is_empty(), "A visit after leaving resumes the bookmark")
	await _tap(KEY_E)
	_expect(game.view == "play" and game.dialogue.heard.get("arrival") == 1, "Finishing a conversation records it exactly once")
	await _tap(KEY_E)
	_expect(game.dialogue.topic == "pockets", "Talking again opens a fresh story")
	game.dialogue.restore({})
	_expect(game.dialogue.heard.is_empty() and game.dialogue.topic.is_empty(), "An older save starts with a fresh conversation history")
	_check_unfinished_stories()
	if not failed:
		print("PASS: Brizno interaction, bilingual stories, branches, pause, completion, interruption and saved page.")
	quit(1 if failed else 0)
