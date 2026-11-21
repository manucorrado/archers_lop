extends Control
## Map sockets and their purchase requirements share a single set of vertices.

const Icons := preload("res://scripts/upgrade_icons.gd")
const Paths := preload("res://scripts/upgrade_paths.gd")
const LATENT := Color("#455a4f")
const OPEN := Color("#92a990")
const GROWN := Color("#dfb77a")
const MAP_CENTER := Vector2(493.5, 474)
const MAP_SPAN := Vector2(822, 761)
const MIN_ZOOM := 0.75
const MAX_ZOOM := 5.0

class Socket extends Button:
	var symbol: Texture2D
	var rank := 0
	var ranks := 1
	var met := false
	var affordable := false
	var inspected := false

	func _draw() -> void:
		var c := size * 0.5
		var radius := c.x - 2
		var outline := Color("#6c8173")
		var fill := Color("#263931")
		if rank > 0:
			outline = Color("#dbb574")
			fill = Color("#514539")
		elif affordable:
			outline = Color("#d0dfbb")
			fill = Color("#3b5645")
		elif met:
			outline = Color("#91a78c")
		if inspected or has_focus() or is_hovered():
			draw_circle(c, radius + 1.5, Color("#e9d5a7"), false, 1.2, true)
		draw_circle(c, radius, fill, true, -1, true)
		draw_circle(c, radius, outline, false, 1.1, true)
		if rank > 0 and ranks > 1 and radius >= 7:
			draw_arc(c, radius - 2, -PI * 0.5, -PI * 0.5 + TAU * rank / ranks,
				36, Color("#f5ca80"), 1.6, true)
		var icon_size := Vector2.ONE * floorf(radius * 1.40)
		var tint := Color.WHITE if met or rank > 0 else Color("#91a697")
		draw_texture_rect(symbol, Rect2((c - icon_size * 0.5).round(), icon_size), false, tint)

var buttons: Dictionary = {}
var parents: Dictionary = {}
var offers: Dictionary = {}
var revealed: Dictionary = {}
var language := "es"
var zoom := 1.0
var pan := Vector2.ZERO
var _nearest: Dictionary = {}
var _drag_button := 0
var _last_drag_point := Vector2.ZERO
var _zoom_value: Button
var _toolbar := HBoxContainer.new()

func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(_place_buttons)
	add_child(_toolbar)
	_toolbar.name = "Zoom"
	_toolbar.z_index = 1
	_toolbar.mouse_filter = Control.MOUSE_FILTER_STOP
	_toolbar.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_toolbar.offset_left = -135
	_toolbar.offset_top = 6
	_toolbar.offset_right = -6
	_toolbar.offset_bottom = 34
	_toolbar.add_theme_constant_override("separation", 2)
	_zoom_button("−", "Alejar", "Zoom out", func(): _zoom_at(zoom / 1.25, size / 2))
	_zoom_value = _zoom_button("100 %", "Centrar mapa (Inicio)", "Fit map (Home)", _reset_camera)
	_zoom_button("+", "Acercar", "Zoom in", func(): _zoom_at(zoom * 1.25, size / 2))
	tooltip_text = ("Rueda: zoom · Arrastrá el fondo para mover el mapa"
		if language == "es" else "Scroll to zoom · Drag the background to pan")

func _zoom_button(caption: String, es: String, en: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.tooltip_text = es if language == "es" else en
	button.accessibility_name = button.tooltip_text
	button.custom_minimum_size = Vector2(52 if caption.contains("%") else 30, 26)
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color("#e6e0c6"))
	for state in ["normal", "hover", "pressed"]:
		var box := StyleBoxFlat.new()
		box.bg_color = Color("#243b30") if state == "normal" else Color("#3f5844")
		box.set_border_width_all(1)
		box.border_color = Color("#627365")
		button.add_theme_stylebox_override(state, box)
	button.pressed.connect(action)
	_toolbar.add_child(button)
	return button

func add_socket(id: String) -> Socket:
	var node := Socket.new()
	node.symbol = Icons.texture(id)
	node.flat = true
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.focus_mode = Control.FOCUS_ALL
	for style in ["normal", "hover", "focus", "pressed", "hover_pressed"]:
		node.add_theme_stylebox_override(style, StyleBoxEmpty.new())
	node.mouse_entered.connect(node.queue_redraw)
	node.mouse_exited.connect(node.queue_redraw)
	node.focus_entered.connect(_focus_socket.bind(node))
	node.focus_exited.connect(node.queue_redraw)
	buttons[id] = node
	add_child(node)
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
	# On a first visit the whole bow would reduce the five central emblems to a
	# tiny cluster. Frame the grip once and keep the camera still during purchases.
	if revealed.size() <= 10:
		zoom = 2.0
		pan = (MAP_CENTER - Paths.position_of("damage")) * _scale_factor()
		_zoom_value.text = "200 %"
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
	for id: String in buttons:
		buttons[id].visible = revealed.has(id)
	queue_redraw()

func closest_revealed(id: String) -> String:
	while not revealed.has(id) and parents.has(id):
		id = parents[id]
	return id if revealed.has(id) else "damage"

func _scale_factor() -> float:
	return maxf(0.01, minf((size.x - 44) / MAP_SPAN.x, (size.y - 46) / MAP_SPAN.y)) * zoom

func _point(p: Vector2) -> Vector2:
	return size * 0.5 + pan + (p - MAP_CENTER) * _scale_factor()

func _place_buttons() -> void:
	var factor := _scale_factor()
	for id: String in buttons:
		var node: Socket = buttons[id]
		# Each hit rectangle fits between its neighbors even at overview scale.
		var target_size := 40.0 if id == "damage" else 33.0
		var room := 0.88 * float(_nearest.get(id, target_size))
		var diameter := clampf(minf(target_size, room) * factor, 8.0, target_size)
		node.size = Vector2.ONE * floorf(diameter)
		node.position = (_point(Paths.position_of(id)) - node.size * 0.5).round()
		node.queue_redraw()
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
	pan = Vector2.ZERO
	_zoom_value.text = "100 %"
	_place_buttons()

func _ensure_in_view(node: Socket) -> void:
	var margin := node.size / 2 + Vector2(6, 6)
	var center := node.get_rect().get_center()
	var delta := center.clamp(margin, size - margin) - center
	if _toolbar.get_rect().grow(margin.y).has_point(center + delta):
		delta.y = _toolbar.get_rect().end.y + margin.y - center.y
	if delta.length_squared() > 0.01:
		pan += delta
		_limit_pan()
		_place_buttons()

func _focus_socket(node: Socket) -> void:
	_ensure_in_view(node)
	node.queue_redraw()

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		_drag_button = 0
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var focus := get_viewport().gui_get_focus_owner()
		if focus == null or not is_ancestor_of(focus):
			return
		var anchor := get_local_mouse_position()
		if focus is Socket:
			anchor = focus.get_rect().get_center()
		match event.keycode:
			KEY_PLUS, KEY_EQUAL, KEY_KP_ADD: _zoom_at(zoom * 1.25, anchor)
			KEY_MINUS, KEY_KP_SUBTRACT: _zoom_at(zoom / 1.25, anchor)
			KEY_HOME: _reset_camera()
			_: return
		get_viewport().set_input_as_handled()
	elif event is InputEventMouse:
		var local := make_input_local(event) as InputEventMouse
		if event is InputEventMouseMotion:
			if _drag_button != 0:
				pan += local.position - _last_drag_point
				_last_drag_point = local.position
				_limit_pan()
				_place_buttons()
				get_viewport().set_input_as_handled()
			return
		if not event is InputEventMouseButton:
			return
		if _drag_button != 0 and event.button_index == _drag_button and not event.pressed:
			_drag_button = 0
			get_viewport().set_input_as_handled()
			return
		if not event.pressed or not Rect2(Vector2.ZERO, size).has_point(local.position) or _toolbar.get_rect().has_point(local.position):
			return
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var direction := 1.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1.0
			_zoom_at(zoom * pow(1.22, direction * maxf(0.1, event.factor)), local.position)
		elif event.button_index == MOUSE_BUTTON_MIDDLE or (event.button_index == MOUSE_BUTTON_LEFT and _empty_at(local.position)):
			_drag_button = event.button_index
			_last_drag_point = local.position
		else:
			return
		get_viewport().set_input_as_handled()

func _empty_at(point: Vector2) -> bool:
	for id: String in revealed:
		if buttons[id].get_rect().has_point(point):
			return false
	return true

func update_socket(id: String, offer: Dictionary, inspected: bool) -> void:
	offers[id] = offer
	var socket: Socket = buttons[id]
	socket.rank = int(offer.rank)
	socket.ranks = int(offer.max_rank)
	socket.met = bool(offer.requirement_met)
	socket.affordable = bool(offer.available)
	socket.inspected = inspected
	socket.queue_redraw()

func _edge(from: String, to: String, tint: Color, width: float) -> void:
	draw_line(_point(Paths.position_of(from)), _point(Paths.position_of(to)), tint, width, true)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#172a24"))
	draw_rect(Rect2(Vector2.ZERO, size), Color("#46594b"), false, 1.0)
	for id: String in revealed:
		var parent: String = parents[id]
		if not parent.is_empty():
			var offer: Dictionary = offers[id]
			var tone := GROWN if int(offer.rank) > 0 else OPEN if bool(offer.requirement_met) else LATENT
			_edge(parent, id, tone, 1.8)
	for pair: Array in Paths.SEAMS:
		if int(offers.get(pair[0], {}).get("rank", 0)) > 0 and int(offers.get(pair[1], {}).get("rank", 0)) > 0:
			_edge(pair[0], pair[1], GROWN, 1.3)
