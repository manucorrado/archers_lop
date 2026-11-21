extends RefCounted
## Each binding stores a physical key (positive) or a mouse button (negative).

const FILE := "user://interface.cfg"
const DEFAULT_BINDINGS := {
	"move_forward": KEY_W, "move_back": KEY_S, "move_left": KEY_A, "move_right": KEY_D,
	"shoot": -MOUSE_BUTTON_LEFT, "aim": -MOUSE_BUTTON_RIGHT, "strike": KEY_F,
	"shop": KEY_E, "pause": KEY_ESCAPE, "bow_1": KEY_1, "bow_2": KEY_2, "bow_3": KEY_3,
	"bow_previous": -MOUSE_BUTTON_WHEEL_UP, "bow_next": -MOUSE_BUTTON_WHEEL_DOWN,
	"jump": KEY_SPACE, "pet_dog": KEY_R,
}
const ACTION_NAMES := {
	"move_forward": ["Avanzar", "Move forward"], "move_back": ["Retroceder", "Move backward"],
	"move_left": ["Ir a la izquierda", "Move left"], "move_right": ["Ir a la derecha", "Move right"],
	"shoot": ["Disparar", "Shoot"], "aim": ["Acercar la mira", "Aim down sights"],
	"strike": ["Golpe de rama", "Branch strike"], "shop": ["Interactuar", "Interact"],
	"pause": ["Pausar", "Pause"], "bow_1": ["Arco de rama", "Branch bow"],
	"bow_2": ["Arco recurvo", "Recurve bow"], "bow_3": ["Arco largo", "Longbow"],
	"bow_next": ["Arco siguiente", "Next bow"],
	"bow_previous": ["Arco anterior", "Previous bow"],
	"jump": ["Saltar", "Jump"], "pet_dog": ["Acariciar al perro", "Pet the dog"],
}
const MOUSE_NAMES := {
	1: ["Clic izquierdo", "Left click"], 2: ["Clic derecho", "Right click"],
	3: ["Clic central", "Middle click"], 4: ["Rueda arriba", "Wheel up"],
	5: ["Rueda abajo", "Wheel down"], 6: ["Rueda izquierda", "Wheel left"],
	7: ["Rueda derecha", "Wheel right"], 8: ["Botón lateral 1", "Side button 1"],
	9: ["Botón lateral 2", "Side button 2"],
}
const KEY_NAMES := {
	KEY_UP: ["Flecha arriba", "Up arrow"], KEY_DOWN: ["Flecha abajo", "Down arrow"],
	KEY_LEFT: ["Flecha izquierda", "Left arrow"], KEY_RIGHT: ["Flecha derecha", "Right arrow"],
	KEY_SPACE: ["Espacio", "Space"], KEY_CTRL: ["Ctrl", "Ctrl"], KEY_SHIFT: ["Mayús", "Shift"],
	KEY_ESCAPE: ["Esc", "Esc"], KEY_ENTER: ["Intro", "Enter"], KEY_BACKSPACE: ["Retroceso", "Backspace"],
	KEY_DELETE: ["Supr", "Delete"], KEY_HOME: ["Inicio", "Home"], KEY_END: ["Fin", "End"],
	KEY_PAGEUP: ["Re Pág", "Page up"], KEY_PAGEDOWN: ["Av Pág", "Page down"],
}
const DEFAULTS := {
	"sensitivity": 1.0, "fov": 70.0, "zoom": 1.0, "shake": 0.65, "flashes": 0.65,
	"reticle_size": 1.0, "damage_opacity": 0.9, "group_damage": true, "toggle_fire": false,
	"first_steps": true,
	"volume_bow": 0.85, "volume_world": 0.85, "volume_ui": 0.8,
}

var language := "es"
var options := DEFAULTS.duplicate()
var bindings := DEFAULT_BINDINGS.duplicate()

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(FILE) != OK:
		config.load(FILE + ".bak")
	language = "en" if config.get_value("interface", "language", "es") == "en" else "es"
	for id in DEFAULTS:
		var saved = config.get_value("comfort", id, DEFAULTS[id])
		if typeof(DEFAULTS[id]) == TYPE_BOOL and typeof(saved) == TYPE_BOOL:
			options[id] = saved
		elif typeof(DEFAULTS[id]) == TYPE_FLOAT and typeof(saved) in [TYPE_FLOAT, TYPE_INT]:
			options[id] = clampf(saved, 55.0, 105.0) if id == "fov" else clampf(saved, 0.0, 3.0)
	var saved_bindings := {}
	for id in DEFAULT_BINDINGS:
		if not config.has_section_key("bindings", id):
			continue
		var code = config.get_value("bindings", id)
		if typeof(code) != TYPE_INT or code == 0 or code < -9 or code in saved_bindings.values():
			saved_bindings.clear()
			break
		saved_bindings[id] = code
	if config.get_value("interface", "version", 1) < 2 and saved_bindings.get("shop") == KEY_TAB and KEY_E not in saved_bindings.values():
		saved_bindings.shop = KEY_E
	# Allocate new actions around every previous binding, including customized keys.
	for id in DEFAULT_BINDINGS:
		if id in saved_bindings:
			continue
		for candidate in [DEFAULT_BINDINGS[id], KEY_J, KEY_V, KEY_B, KEY_N, KEY_M, KEY_H, KEY_G, KEY_K, KEY_L, KEY_P, KEY_U, KEY_I, KEY_O, KEY_Y, KEY_T, KEY_C, KEY_X, KEY_Z]:
			if candidate not in saved_bindings.values():
				saved_bindings[id] = candidate
				break
	bindings = saved_bindings
	apply_bindings()

func persist() -> Error:
	var config := ConfigFile.new()
	config.set_value("interface", "version", 2)
	config.set_value("interface", "language", language)
	for id in options:
		config.set_value("comfort", id, options[id])
	for id in bindings:
		config.set_value("bindings", id, bindings[id])
	var temporary := FILE + ".tmp"
	var error := config.save(temporary)
	if error != OK:
		return error
	if FileAccess.file_exists(FILE):
		error = DirAccess.copy_absolute(FILE, FILE + ".bak")
		if error != OK:
			return error
	return DirAccess.rename_absolute(temporary, FILE)

func apply_bindings() -> void:
	for id in bindings:
		if not InputMap.has_action(id):
			InputMap.add_action(id)
		Input.action_release(id)
		InputMap.action_erase_events(id)
		var code := int(bindings[id])
		if code < 0:
			var button := InputEventMouseButton.new()
			button.button_index = -code
			InputMap.action_add_event(id, button)
		else:
			var key := InputEventKey.new()
			key.physical_keycode = code
			InputMap.action_add_event(id, key)

func binding_name(id: String) -> String:
	var code := int(bindings[id])
	var locale := 0 if language == "es" else 1
	if code < 0:
		return MOUSE_NAMES[-code][locale]
	var displayed := code
	if DisplayServer.get_name() != "headless":
		var local_code := int(DisplayServer.keyboard_get_keycode_from_physical(code as Key))
		if local_code != 0:
			displayed = local_code
	if KEY_NAMES.has(displayed):
		return KEY_NAMES[displayed][locale]
	return OS.get_keycode_string(displayed as Key)
