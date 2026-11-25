extends Control
## Map sockets and their purchase requirements share a single set of vertices.

const Journal := preload("res://scripts/field_journal.gd")
const Icons := preload("res://scripts/upgrade_icons.gd")
const Paths := preload("res://scripts/upgrade_paths.gd")
const COLLECTION_ART := preload("res://assets/atlas_arco.svg")
signal inspection_changed(id: String)
signal map_moved
const PIGMENTS := {"damage": Color("#653524"), "speed": Color("#254b3b"),
	"supply": Color("#624718"), "utility": Color("#394765")}
const WALNUT_PIGMENTS := {"damage": Color("#e6ae89"), "speed": Color("#c1d5ac"),
	"supply": Color("#e8c796"), "utility": Color("#c5c7e0")}
const FAMILY_NAMES := {"damage": ["Daño", "Damage"], "speed": ["Cadencia", "Fire rate"],
	"supply": ["Suministro", "Supply"], "utility": ["Utilidad", "Utility"]}
const MAP_CENTER := Vector2(493.5, 474)
const MAP_SPAN := Vector2(822, 761)
const MIN_ZOOM := 0.75
const MAX_ZOOM := 5.0

const Socket := preload("res://scripts/atlas_socket.gd")
const Finish := preload("res://scripts/atlas_finish.gd")
const SURFACE_SHADER := preload("res://assets/atlas_superficie.gdshader")

var buttons: Dictionary = {}
var parents: Dictionary = {}
var offers: Dictionary = {}
var revealed: Dictionary = {}
var language := "es"
var atlas_style := "walnut"
var _colors: Dictionary
var _surface := ColorRect.new()
var _grain := ShaderMaterial.new()
var zoom := 1.0
var pan := Vector2.ZERO
var _map_center := MAP_CENTER
var _nearest: Dictionary = {}
var _drag_button := 0
var _dragging := false
var _pressed_socket := ""
var _press_point := Vector2.ZERO
var _last_drag_point := Vector2.ZERO
var _zoom_value: Button
var _toolbar := HBoxContainer.new()
var _legend := HBoxContainer.new()
var _rank_key := VBoxContainer.new()
var _collection := Button.new()
var _family_filter := ""
var _inspected := ""
var _keyboard_inspection := false
var _complete := false
var _has_snapshot := false
var _show_drawing := false
var _ink := 0.0
var _reveal: Tween
var animate_completion := true

static func group_for(id: String) -> String:
	match Paths.family(id).trim_suffix("_step"):
		"rate", "rate_flat", "recurve", "longbow", "steady", "rain": return "speed"
		"workshop", "wheel", "capacity", "pickup", "sentinel", "seeds": return "supply"
		"refund", "leap", "pace", "pet": return "utility"
		_: return "damage"

func group_name(group: String) -> String:
	return FAMILY_NAMES[group][0 if language == "es" else 1]

func family_ink(group: String) -> Color:
	return PIGMENTS[group] if atlas_style == "linen" else WALNUT_PIGMENTS[group]

func focus_entry() -> void:
	if _complete:
		_collection.grab_focus()
	elif buttons.has("damage"):
		buttons.damage.grab_focus()

func _ready() -> void:
	_colors = Finish.palette(atlas_style)
	_grain.shader = SURFACE_SHADER
	_grain.set_shader_parameter("ground", _colors.surface)
	_grain.set_shader_parameter("walnut", atlas_style != "linen")
	_surface.material = _grain
	_surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_surface.show_behind_parent = true
	add_child(_surface)
	_surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_grain.set_shader_parameter("dimensions", size)
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(_place_buttons)
	get_window().focus_exited.connect(_end_pointer)
	visibility_changed.connect(_end_pointer)
	add_child(_toolbar)
	_toolbar.name = "Zoom"
	_toolbar.z_index = 1
	_toolbar.mouse_filter = Control.MOUSE_FILTER_STOP
	_toolbar.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_toolbar.offset_left = -146
	_toolbar.offset_top = 12
	_toolbar.offset_right = -17
	_toolbar.offset_bottom = 34
	_toolbar.add_theme_constant_override("separation", 2)
	_zoom_button("−", "Alejar", "Zoom out", func(): _zoom_at(zoom / 1.25, size / 2))
	_zoom_value = _zoom_button("100 %", "Centrar mapa (Inicio)", "Fit map (Home)", _reset_camera)
	_zoom_button("+", "Acercar", "Zoom in", func(): _zoom_at(zoom * 1.25, size / 2))
	add_child(_legend)
	_legend.z_index = 1
	_legend.add_theme_constant_override("separation", 12)
	for group: String in FAMILY_NAMES:
		var tab := Button.new()
		tab.text = group_name(group)
		tab.name = group
		tab.toggle_mode = true
		Journal.style_entry(tab, Journal.serif(), "link")
		Finish.style_link(tab, atlas_style)
		for state in ["font_color", "font_pressed_color", "font_focus_color", "font_hover_color"]:
			tab.add_theme_color_override(state, family_ink(group))
		tab.pressed.connect(_highlight_family.bind(group))
		_legend.add_child(tab)
	_legend.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE, 16)
	add_child(_collection)
	_collection.position = Vector2(18, 13)
	_collection.z_index = 1
	Journal.style_entry(_collection, Journal.serif(), "action")
	Finish.style_link(_collection, atlas_style)
	_collection.pressed.connect(func(): _drawing(not _show_drawing, false))
	_collection.hide()
	_rank_key.mouse_filter = Control.MOUSE_FILTER_STOP
	_rank_key.z_index = 1
	add_child(_rank_key)
	_rank_key.position = Vector2(23, 16)
	_rank_key.add_theme_constant_override("separation", 3)
	var heading := Label.new()
	heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	heading.text = "Estado de las mejoras" if language == "es" else "Upgrade status"
	heading.add_theme_font_override("font", Journal.serif())
	heading.add_theme_font_size_override("font_size", 20)
	heading.add_theme_color_override("font_color", _colors.ink)
	_rank_key.add_child(heading)
	var status_labels := ["Sin comprar", "En progreso", "Completa"] if language == "es" else ["Unbought", "In progress", "Complete"]
	for i in 3:
		var line := HBoxContainer.new()
		line.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
		_rank_key.add_child(line)
		var sample := Socket.new()
		sample.atlas_style = atlas_style
		sample.rank = [0, 4, 10][i]
		sample.ranks = 10
		sample.met = true
		sample.stamped_symbol = Icons.texture("damage", (sample.rank < 10) if atlas_style != "linen" else (sample.rank == 10))
		sample.custom_minimum_size = Vector2(21,21)
		sample.flat = true
		sample.focus_mode = Control.FOCUS_NONE
		line.add_child(sample)
		var label := Label.new()
		label.text = status_labels[i]
		label.add_theme_font_override("font", Journal.sans())
		label.add_theme_font_size_override("font_size", 13)
		label.add_theme_color_override("font_color", _colors.muted)
		line.add_child(label)
	var hint := Label.new()
	hint.text = "Rueda para acercar · Arrastrá para mover" if language == "es" else "Wheel to zoom · Drag to pan"
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.add_theme_font_override("font", Journal.sans())
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", _colors.muted)
	hint.z_index = 1
	add_child(hint)
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 17)

func _highlight_family(group: String) -> void:
	_family_filter = "" if _family_filter == group else group
	for tab: Button in _legend.get_children():
		tab.set_pressed_no_signal(str(tab.name) == _family_filter)
	_tint_sockets()
	queue_redraw()

func _tint_sockets() -> void:
	for socket: Socket in buttons.values():
		var alpha := 0.28 if not _family_filter.is_empty() and socket.family != _family_filter else 1.0
		socket.modulate.a = alpha * (1.0 - _ink)

func _zoom_button(caption: String, es: String, en: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.tooltip_text = es if language == "es" else en
	button.accessibility_name = button.tooltip_text
	Journal.style_entry(button, Journal.sans(), "link")
	Finish.style_link(button, atlas_style)
	button.custom_minimum_size = Vector2(52 if caption.contains("%") else 30, 26)
	button.add_theme_font_size_override("font_size", 15)
	button.pressed.connect(action)
	_toolbar.add_child(button)
	return button

func add_socket(id: String) -> Socket:
	var node := Socket.new()
	node.family = group_for(id)
	node.atlas_style = atlas_style
	node.flat = true
	node.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.focus_mode = Control.FOCUS_ALL
	for style in ["normal", "hover", "focus", "pressed", "hover_pressed"]:
		node.add_theme_stylebox_override(style, StyleBoxEmpty.new())
	node.mouse_entered.connect(_mouse_inspect.bind(id))
	node.mouse_exited.connect(_mouse_left.bind(id))
	node.focus_entered.connect(_focus_socket.bind(node, id))
	node.focus_exited.connect(_blur.bind(id))
	buttons[id] = node
	add_child(node)
	# GUI hit tests visit siblings in reverse tree order, independently of z_index.
	move_child(node, _toolbar.get_index())
	return node

func arrange(new_offers: Dictionary) -> void:
	offers = new_offers
	for id: String in buttons:
		parents[id] = str(offers[id].requires)
		var distance := INF
		var location := Paths.position_of(id)
		for other: String in buttons:
			if other != id:
				distance = minf(distance, location.distance_to(Paths.position_of(other)))
		_nearest[id] = distance
	sync_visibility()
	# Frame only the known branches on arrival and hold the camera through purchases.
	if not _complete and not revealed.is_empty():
		var bounds := Rect2(Paths.position_of("damage"), Vector2.ZERO)
		for id: String in revealed:
			bounds = bounds.expand(Paths.position_of(id))
		_map_center = bounds.get_center()
		zoom = clampf(minf(MAP_SPAN.x / (bounds.size.x + 76), MAP_SPAN.y / (bounds.size.y + 76)), 1.0, 4.0)
		_zoom_value.text = "%d %%" % roundi(zoom * 100)
	_place_buttons()

func sync_visibility() -> void:
	revealed.clear()
	for id: String in buttons:
		var parent: String = parents[id]
		if parent.is_empty() or parent == "damage" or int(offers[parent].rank) > 0:
			revealed[id] = true
		# A refund or a migration can leave an owned node beyond a missing parent.
		# Its purchased descendants remain accessible and the route can be repurchased.
		if int(offers[id].rank) > 0:
			var path := id
			while not path.is_empty():
				revealed[path] = true
				path = parents[path]
	var all_owned := not offers.is_empty()
	for id: String in buttons:
		all_owned = all_owned and int(offers[id].rank) == int(offers[id].max_rank)
		buttons[id].visible = revealed.has(id) and (not _show_drawing or _ink < 1.0)
	if all_owned != _complete:
		_complete = all_owned
		_collection.visible = all_owned
		_legend.visible = not all_owned
		_drawing(all_owned, all_owned and _has_snapshot and animate_completion)
	_has_snapshot = true
	queue_redraw()

func _drawing(enabled: bool, animate: bool) -> void:
	if _reveal:
		_reveal.kill()
	_show_drawing = enabled
	_rank_key.visible = not _complete
	_set_inspection("")
	_collection.text = ("Ver mejoras" if language == "es" else "Inspect upgrades") if enabled else ("Ver arco y carcaj" if language == "es" else "View bow and quiver")
	for id: String in buttons:
		var socket: Socket = buttons[id]
		socket.mouse_filter = Control.MOUSE_FILTER_IGNORE if enabled else Control.MOUSE_FILTER_STOP
		socket.focus_mode = Control.FOCUS_NONE if enabled else Control.FOCUS_ALL
		socket.visible = revealed.has(id)
	if enabled:
		_reset_camera()
		if _has_snapshot:
			_collection.grab_focus()
	if animate:
		_reveal = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		_reveal.tween_method(_reveal_ink, _ink, 1.0, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	else:
		_reveal_ink(1.0 if enabled else 0.0)

func _reveal_ink(amount: float) -> void:
	_ink = amount
	if _ink >= 1.0:
		for socket: Socket in buttons.values():
			socket.hide()
	_tint_sockets()
	queue_redraw()

func closest_revealed(id: String) -> String:
	while not revealed.has(id) and parents.has(id):
		id = parents[id]
	return id if revealed.has(id) else "damage"

func _scale_factor() -> float:
	return maxf(0.01, minf((size.x - 44) / MAP_SPAN.x, (size.y - 46) / MAP_SPAN.y)) * zoom

func _point(p: Vector2) -> Vector2:
	return size * 0.5 + pan + (p - _map_center) * _scale_factor()

func _place_buttons() -> void:
	_grain.set_shader_parameter("dimensions", size)
	var factor := _scale_factor()
	for id: String in buttons:
		var node: Socket = buttons[id]
		# Each hit rectangle fits between its neighbors even at overview scale.
		var target_size := 48.0 if id == "damage" else 44.0
		var room := 0.88 * float(_nearest.get(id, target_size))
		var diameter := clampf(minf(target_size, room) * factor, 8.0, target_size)
		node.space_for_rank = diameter >= 25 and room * factor >= diameter + 15
		node.size = Vector2.ONE * floorf(diameter)
		node.position = (_point(Paths.position_of(id)) - node.size * 0.5).round()
		node.queue_redraw()
	map_moved.emit()
	queue_redraw()

func _limit_pan() -> void:
	var limit := (size + MAP_SPAN * _scale_factor()) / 2 - Vector2.ONE * 58
	pan = pan.clamp(-limit.max(Vector2.ZERO), limit.max(Vector2.ZERO))

func _zoom_at(requested: float, anchor: Vector2) -> void:
	var previous := zoom
	zoom = clampf(requested, MIN_ZOOM, MAX_ZOOM)
	pan += (anchor - size * 0.5 - pan) * (1.0 - zoom / previous)
	_limit_pan()
	_zoom_value.text = "%d %%" % roundi(zoom * 100)
	_place_buttons()

func _reset_camera() -> void:
	zoom = 1.0
	_map_center = MAP_CENTER
	pan = Vector2.ZERO
	_zoom_value.text = "100 %"
	_place_buttons()

func _ensure_in_view(node: Socket) -> void:
	if size.x < 60 or size.y < 60:
		return
	var margin := node.size / 2 + Vector2(6, 6)
	var center := node.get_rect().get_center()
	var delta := center.clamp(margin, size - margin) - center
	for bar: Control in [_toolbar, _legend, _collection, _rank_key]:
		if bar.visible and bar.get_rect().grow(margin.y).has_point(center + delta):
			if bar.position.y > size.y / 2:
				delta.y = bar.position.y - margin.y - center.y
			else:
				delta.y = bar.get_rect().end.y + margin.y - center.y
	if delta.length_squared() > 0.01:
		pan += delta
		_limit_pan()
		_place_buttons()

func _focus_socket(node: Socket, id: String) -> void:
	if _keyboard_inspection:
		_ensure_in_view(node)
		_set_inspection(id)

func _set_inspection(id: String) -> void:
	if _inspected == id:
		return
	if buttons.has(_inspected):
		buttons[_inspected].inspected = false
		buttons[_inspected].queue_redraw()
	_inspected = id
	if buttons.has(id):
		buttons[id].inspected = true
		buttons[id].queue_redraw()
	inspection_changed.emit(id)

func _mouse_inspect(id: String) -> void:
	if not _show_drawing and not _keyboard_inspection and _drag_button == 0:
		_set_inspection(id)

func _mouse_left(id: String) -> void:
	if not _keyboard_inspection and _inspected == id:
		_set_inspection("")

func _blur(id: String) -> void:
	if _keyboard_inspection and id == _inspected:
		_set_inspection("")

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		_keyboard_inspection = true
		var focus := get_viewport().gui_get_focus_owner()
		if focus == null or not is_ancestor_of(focus):
			return
		var anchor := get_local_mouse_position()
		if focus is Socket:
			anchor = focus.get_rect().get_center()
			_set_inspection(str(buttons.find_key(focus)))
		match event.keycode:
			KEY_PLUS, KEY_EQUAL, KEY_KP_ADD: _zoom_at(zoom * 1.25, anchor)
			KEY_MINUS, KEY_KP_SUBTRACT: _zoom_at(zoom / 1.25, anchor)
			KEY_HOME: _reset_camera()
			_: return
		get_viewport().set_input_as_handled()
	elif event is InputEventMouse:
		var local := make_input_local(event) as InputEventMouse
		if _keyboard_inspection:
			_keyboard_inspection = false
			_set_inspection(_socket_at(local.position) if not _show_drawing else "")
		if event is InputEventMouseMotion:
			if _drag_button != 0:
				var mask := MOUSE_BUTTON_MASK_LEFT if _drag_button == MOUSE_BUTTON_LEFT else MOUSE_BUTTON_MASK_MIDDLE
				if (event.button_mask & mask) == 0:
					_end_pointer()
					return
				if not _dragging and local.position.distance_squared_to(_press_point) > 16.0:
					_dragging = true
					_set_inspection("")
				if _dragging:
					pan += local.position - _last_drag_point
					_last_drag_point = local.position
					_limit_pan()
					_place_buttons()
				get_viewport().set_input_as_handled()
			return
		if not event is InputEventMouseButton:
			return
		if _drag_button != 0 and event.button_index == _drag_button and not event.pressed:
			var buy := _pressed_socket
			var was_click := not _dragging and local.position.distance_squared_to(_press_point) <= 16.0
			_end_pointer()
			get_viewport().set_input_as_handled()
			var under_pointer := _socket_at(local.position) if not _show_drawing else ""
			_set_inspection(under_pointer)
			if was_click and not buy.is_empty() and under_pointer == buy:
				buttons[buy].grab_focus()
				buttons[buy].pressed.emit()
			return
		if not event.pressed or not Rect2(Vector2.ZERO, size).has_point(local.position):
			return
		if _over_controls(local.position):
			return
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var direction := 1.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1.0
			_zoom_at(zoom * pow(1.22, direction * maxf(0.1, event.factor)), local.position)
		elif event.button_index in [MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_LEFT]:
			_drag_button = event.button_index
			_press_point = local.position
			_last_drag_point = local.position
			_dragging = _drag_button == MOUSE_BUTTON_MIDDLE
			_pressed_socket = _socket_at(local.position) if not _dragging and not _show_drawing else ""
			_set_inspection(_pressed_socket)
		else:
			return
		get_viewport().set_input_as_handled()

func _end_pointer() -> void:
	_drag_button = 0
	_dragging = false
	_pressed_socket = ""

func _socket_at(point: Vector2) -> String:
	if _over_controls(point):
		return ""
	var nearest := ""
	var best := INF
	for id: String in revealed:
		var rect: Rect2 = buttons[id].get_rect()
		if buttons[id].visible and rect.has_point(point):
			var distance := point.distance_squared_to(rect.get_center())
			if distance < best:
				nearest = id
				best = distance
	return nearest

func _over_controls(point: Vector2) -> bool:
	for bar: Control in [_toolbar, _legend, _collection, _rank_key]:
		if bar.visible and bar.get_rect().has_point(point):
			return true
	return false

func update_socket(id: String, offer: Dictionary) -> void:
	offers[id] = offer
	var socket: Socket = buttons[id]
	socket.rank = int(offer.rank)
	var stencil := Icons.for_rank(id, socket.rank)
	socket.ranks = int(offer.max_rank)
	var done := socket.rank >= socket.ranks
	socket.stamped_symbol = Icons.texture(stencil, done if atlas_style == "linen" else not done)
	socket.met = bool(offer.requirement_met)
	socket.affordable = bool(offer.available)
	socket.queue_redraw()

func _edge(from: String, to: String, tint: Color, width: float) -> void:
	draw_line(_point(Paths.position_of(from)), _point(Paths.position_of(to)), tint, width, true)

func _draw() -> void:
	if _colors.is_empty():
		return
	var walnut := atlas_style != "linen"
	if walnut and size.x > 32 and size.y > 32:
		var rim := Rect2(Vector2(7,7), size - Vector2(14,14))
		draw_rect(rim, Color("#a98c654d"), false, 1)
		for x: float in [rim.position.x, rim.end.x]:
			for y: float in [rim.position.y, rim.end.y]:
				var pin := Vector2(x,y)
				draw_circle(pin, 3.5, Color("#bda077"), true,-1,true)
				draw_line(pin - Vector2(1.5,-.75), pin + Vector2(1.5,-.75), Color("#6a5236"), 1.1,true)
	for id: String in revealed:
		var parent: String = parents[id]
		if not parent.is_empty():
			var offer: Dictionary = offers[id]
			var group := group_for(id)
			var owned := int(offer.rank) > 0
			var tone: Color = _colors.accent if owned else _colors.rule
			if not walnut and owned:
				tone = Color("#484334")
			if not _family_filter.is_empty() and group != _family_filter:
				tone = tone.lerp(_colors.surface, 0.70)
			tone.a = 1.0 - _ink
			if walnut:
				_edge(parent, id, Color(Color("#25180f"), tone.a), 4.3 if owned else 3.1)
			_edge(parent, id, tone, 2.5 if owned else 1.6)
	for pair: Array in Paths.SEAMS:
		if int(offers.get(pair[0], {}).get("rank", 0)) > 0 and int(offers.get(pair[1], {}).get("rank", 0)) > 0:
			_edge(pair[0], pair[1], Color(_colors.accent, 1.0 - _ink), 1.8)
	if _ink > 0.0:
		var art := Rect2(_point(Vector2(30, 40)), Vector2(1000, 900) * _scale_factor())
		if walnut:
			# The collected illustration keeps its original ink and rests on a mounted sheet.
			var mat := Rect2(_point(Vector2(65,77)), Vector2(873,794) * _scale_factor())
			draw_rect(mat, Color(Color("#efe4cb"), _ink))
			draw_rect(mat.grow(-3), Color(Color("#ac9876"), _ink), false, 1.5)
		draw_texture_rect(COLLECTION_ART, art, false, Color(1, 1, 1, _ink))
