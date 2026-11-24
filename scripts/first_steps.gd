extends Control
## Bearings at the edge of the view; names and actions beside the reticle.

const Clearing = preload("res://scripts/clearing.gd")
const Journal = preload("res://scripts/field_journal.gd")
const PALE := Color("#fff2cc")
const SHADOW := Color("#251f19d8")

var camera: Camera3D
var supply_position: Variant = null
var near_dog := false
var language := "es"
var shop_key := ""
var pet_key := ""
var guide_font := Journal.serif()
var _behind_side := {"dog": -1.0, "supply": 1.0}


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	hide()


func update_targets(playing: bool, supply: Variant, in_reach: bool, locale: String, interact: String, pet: String) -> void:
	supply_position = supply
	near_dog = in_reach
	language = locale
	shop_key = interact
	pet_key = pet
	visible = playing
	set_process(playing)
	queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw()


func _bearing(subject: String, destination: Vector3, focus_radius: float) -> Vector2:
	var local := camera.to_local(destination)
	var direction: Vector2
	if local.z < -camera.near:
		var offset := camera.unproject_position(destination) - size * 0.5
		if offset.length() <= size.y * focus_radius:
			return Vector2.ZERO
		direction = offset.normalized()
	else:
		# Keep the side stable while the target is directly behind the player.
		if absf(local.x) > maxf(0.02, absf(local.z) * 0.06):
			_behind_side[subject] = signf(local.x)
		direction = Vector2(_behind_side[subject], clampf(-local.y / maxf(0.1, local.length()), -0.6, 0.6)).normalized()
	return direction


func _edge(direction: Vector2) -> Vector2:
	var extent := size * Vector2(0.465, 0.32)
	return (size * 0.5 + direction * minf(extent.x / maxf(absf(direction.x), 0.001),
			extent.y / maxf(absf(direction.y), 0.001))).round()


func _draw() -> void:
	if not is_instance_valid(camera) or size.x <= 0:
		return
	var dog := _bearing("dog", Clearing.DOG_POSITION + Vector3.UP, 0.34 if near_dog else 0.11)
	var supply := Vector2.ZERO
	if supply_position != null:
		supply = _bearing("supply", supply_position, 0.11)
	if dog != Vector2.ZERO:
		_draw_edge("dog", dog, _edge(dog))
	if supply_position != null and supply != Vector2.ZERO:
		var point := _edge(supply)
		if dog != Vector2.ZERO and point.distance_to(_edge(dog)) < 54:
			point += Vector2.DOWN * 32 if absf(supply.x) > absf(supply.y) else Vector2.RIGHT * 50
		_draw_edge("supply", supply, point)
	if dog == Vector2.ZERO and (near_dog or supply_position == null or supply != Vector2.ZERO):
		_draw_focus("dog")
	elif supply_position != null and supply == Vector2.ZERO:
		_draw_focus("supply")
		if dog == Vector2.ZERO:
			# Both targets line up with the crosshair. Keep Pipo's bearing present.
			_draw_symbol("dog", size * 0.5 + Vector2(-30, 0))


func _draw_edge(subject: String, direction: Vector2, point: Vector2) -> void:
	_draw_symbol(subject, point - direction * 16)
	for shift in [0.0, 5.0]:
		var tip: Vector2 = point + direction * shift
		var wing := direction.orthogonal() * 4.5
		_line(tip - direction * 4 + wing, tip, 1.6)
		_line(tip, tip - direction * 4 - wing, 1.6)


func _draw_symbol(subject: String, at: Vector2) -> void:
	if subject == "dog":
		for mark: Vector2 in [Vector2(-6, -2), Vector2(-2, -6), Vector2(3, -6), Vector2(6, -2), Vector2(0, 3)]:
			var radius := 4.6 if mark.y > 0 else 2.25
			draw_circle(at + mark, radius + 1.1, SHADOW, true, -1, true)
			draw_circle(at + mark, radius, PALE, true, -1, true)
	else:
		for x in [-3, 2]:
			var tip := at + Vector2(x + 4, -8)
			var tail := tip + Vector2(-7, 15)
			_line(tail, tip, 1.5)
			_line(tip + Vector2(-3, 2), tip, 1.5)
			_line(tip + Vector2(1, 4), tip, 1.5)
			_line(tail + Vector2(-1, -3), tail, 1.5)
		_line(at + Vector2(-4, 1), at + Vector2(4, 4), 1.6)


func _line(start: Vector2, end: Vector2, width: float) -> void:
	draw_line(start, end, SHADOW, width + 2.0, true)
	draw_line(start, end, PALE, width, true)


func _draw_focus(subject: String) -> void:
	var dog := subject == "dog"
	var en := language == "en"
	var anchor := (size * 0.5).round() + Vector2(54, 5)
	_draw_symbol(subject, anchor - Vector2(0, 5))
	var name_text := "Pipo" if dog else ("Arrow bundle" if en else "Atado de flechas")
	_text(guide_font, anchor + Vector2(13, 0), name_text, 23)
	if not dog:
		_text(ThemeDB.fallback_font, anchor + Vector2(13, 20), "Walk closer to collect" if en else "Acercate para recoger", 15)
	elif near_dog:
		_action(anchor + Vector2(13, 20), shop_key, "Open upgrades" if en else "Abrir mejoras")
		if not pet_key.is_empty():
			_action(anchor + Vector2(13, 42), pet_key, "Pet Pipo" if en else "Acariciar a Pipo")


func _action(at: Vector2, key: String, action: String) -> void:
	var font := ThemeDB.fallback_font
	var width := ceilf(font.get_string_size(key, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x) + 9
	var cap := Rect2(at + Vector2(0, -14), Vector2(width, 18))
	draw_rect(cap, SHADOW)
	draw_rect(cap, PALE.darkened(0.15), false, 1.0)
	draw_string(font, at + Vector2(4, 0), key, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, PALE)
	_text(font, at + Vector2(width + 6, 0), action, 15)


func _text(font: Font, at: Vector2, value: String, points: int) -> void:
	draw_string_outline(font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, points, 4, SHADOW)
	draw_string(font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, points, PALE)
