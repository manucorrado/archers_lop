extends CanvasLayer

signal advance_requested
signal leave_requested

const Stories := preload("res://assets/charlas_de_brizno.tres")
const Journal := preload("res://scripts/field_journal.gd")

var topic := ""
var page := 0
var heard := {}
var line := Label.new()
var _counter := Label.new()
var _next := Button.new()
var _leave := Button.new()

func _ready() -> void:
	layer = 3
	visible = false
	var column := VBoxContainer.new()
	add_child(column)
	column.anchor_left = 0.18
	column.anchor_right = 0.82
	column.anchor_bottom = 0.96
	column.alignment = BoxContainer.ALIGNMENT_END
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel := Journal.sheet(26, 14)
	column.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 7)
	panel.add_child(content)
	var header := HBoxContainer.new()
	content.add_child(header)
	var nameplate := Label.new()
	nameplate.text = "Brizno"
	nameplate.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	nameplate.add_theme_font_override("font", Journal.serif())
	nameplate.add_theme_font_size_override("font_size", 26)
	nameplate.add_theme_color_override("font_color", Journal.INK)
	nameplate.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(nameplate)
	_counter.add_theme_color_override("font_color", Journal.MUTED)
	header.add_child(_counter)
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.add_theme_color_override("font_color", Journal.INK)
	line.add_theme_font_override("font", Journal.serif())
	line.add_theme_font_size_override("font_size", 22)
	content.add_child(line)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_END
	buttons.add_theme_constant_override("separation", 12)
	content.add_child(buttons)
	for button: Button in [_leave, _next]:
		var primary := button == _next
		button.add_theme_stylebox_override("normal", Journal.box(Journal.INK if primary else Journal.CANVAS, Journal.RULE, 14, 4))
		button.add_theme_stylebox_override("hover", Journal.box(Journal.COVER, Journal.INK, 14, 4))
		button.add_theme_stylebox_override("pressed", Journal.box(Journal.INK, Journal.INK, 14, 4))
		var focus := Journal.box(Color.TRANSPARENT, Journal.ACCENT, 14, 4)
		focus.set_border_width_all(2)
		button.add_theme_stylebox_override("focus", focus)
		button.add_theme_color_override("font_color", Journal.PAPER if primary else Journal.INK)
		button.add_theme_color_override("font_hover_color", Journal.PAPER)
		button.add_theme_color_override("font_pressed_color", Journal.PAPER)
		button.add_theme_color_override("font_focus_color", Journal.PAPER if primary else Journal.INK)
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		buttons.add_child(button)
	_next.pressed.connect(func(): advance_requested.emit())
	_leave.pressed.connect(func(): leave_requested.emit())

func begin(stage: int, workshop: bool, split: bool) -> bool:
	if topic.is_empty() or Stories.find_story(topic).is_empty():
		topic = Stories.choose(heard, stage, workshop, split)
		page = 0
	return not topic.is_empty()

func display(language: String, interact_key: String, pause_key: String) -> void:
	var story: Dictionary = Stories.find_story(topic)
	if story.is_empty():
		topic = ""
		page = 0
		leave_requested.emit()
		return
	var text := Array(story[language])
	page = clampi(page, 0, text.size() - 1)
	line.text = text[page]
	_counter.text = "%d / %d" % [page + 1, text.size()]
	var final_page := page + 1 == text.size()
	_next.text = "%s · %s" % [interact_key, ("Despedirse" if language == "es" else "Say goodbye") if final_page else ("Seguir" if language == "es" else "Next")]
	_leave.text = "%s · %s" % [pause_key, "Salir" if language == "es" else "Leave"]
	_leave.visible = not final_page
	show()
	_next.grab_focus()

func advance() -> bool:
	var story: Dictionary = Stories.find_story(topic)
	if not story.is_empty():
		page += 1
		if page < story.es.size():
			return true
		heard[topic] = int(heard.get(topic, 0)) + 1
	topic = ""
	page = 0
	return false

func bookmark() -> Dictionary:
	return {"heard": heard.duplicate(), "topic": topic, "page": page, "open": visible}

func restore(data: Variant) -> void:
	heard.clear()
	page = 0
	topic = ""
	if not data is Dictionary:
		return
	var visits: Variant = data.get("heard")
	if visits is Dictionary:
		for id in visits:
			if id is String and visits[id] is int:
				heard[id] = maxi(0, visits[id])
	var entry: Dictionary = Stories.find_story(str(data.get("topic", "")))
	if not entry.is_empty():
		topic = entry.id
		page = clampi(int(data.page) if data.get("page") is int else 0, 0, entry.es.size() - 1)
