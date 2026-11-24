extends PanelContainer
## The folio follows the inspected socket. Input passes through it to the map.

const Journal := preload("res://scripts/field_journal.gd")
var category := Label.new()
var level := Label.new()
var title := Label.new()
var effect := Label.new()
var numbers := Label.new()
var requirement := Label.new()
var actions := Label.new()
var _panel := Journal.box(Color("#fbf4e3"), Color("#998569"), 13, 9)

func _ready() -> void:
	name = "UpgradeDetail"
	z_index = 5
	mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	custom_minimum_size.x = 282
	_panel.border_width_left = 3
	_panel.shadow_size = 4
	_panel.shadow_offset = Vector2(1, 3)
	_panel.shadow_color = Color("#50402d31")
	add_theme_stylebox_override("panel", _panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	add_child(column)
	var row := HBoxContainer.new()
	column.add_child(row)
	category.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_line(row, category, 12, Journal.sans())
	_line(row, level, 12, Journal.sans())
	_line(column, title, 24, Journal.serif())
	for item: Label in [effect, numbers, requirement]:
		_line(column, item, 15, Journal.sans())
	for item: Label in [title, effect, numbers, requirement, actions]:
		item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var rule := ColorRect.new()
	rule.custom_minimum_size.y = 1
	rule.color = Journal.RULE
	column.add_child(rule)
	_line(column, actions, 14, Journal.sans())
	hide()

func _line(parent: Control, label: Label, pixels: int, font: Font) -> void:
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", pixels)
	label.add_theme_color_override("font_color", Color("#3d3326"))
	parent.add_child(label)

func set_pigment(tint: Color) -> void:
	_panel.border_color = tint
	category.add_theme_color_override("font_color", tint)

func place(socket: Rect2, bounds: Vector2) -> void:
	# Reset the previous height when a shorter entry replaces a long one.
	reset_size()
	var gap := 12.0
	var corner := socket.end + Vector2(gap, 0)
	if corner.x + size.x > bounds.x:
		corner.x = socket.position.x - size.x - gap
	corner.y = socket.get_center().y - size.y / 2
	var top := 38.0 if size.y + 65 <= bounds.y else 3.0
	var bottom := 25.0 if size.y + 65 <= bounds.y else 3.0
	var first := Vector2(3, top)
	position = corner.clamp(first, (bounds - size - Vector2(3, bottom)).max(first)).round()
