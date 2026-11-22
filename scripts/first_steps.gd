extends Control
## Paper waymarks for finding Pipo and loose arrows.

const Clearing = preload("res://scripts/clearing.gd")
const Journal = preload("res://scripts/field_journal.gd")
const NAMES := {
	"dog": ["Pipo", "Pipo"],
	"supply": ["Flechas", "Arrows"],
}

var camera: Camera3D
var destination := Vector3.ZERO
var kind := ""
var language := "es"
var guide_font := Journal.serif()
var settle := 0.0


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	hide()


static func objective(state: Dictionary, player: Vector3) -> Dictionary:
	if state.get("fired_after_collect", false) or state.hp <= 0 or state.stage >= 5:
		return {}
	if state.get("near_dog", false) or state.get("near_brizno", false) or state.get("near_sentinel", false):
		return {}
	if state.arrows <= 0 and state.workshop_stock == 0:
		if state.knot_stock > 0:
			return {"kind": "supply", "at": Clearing.KNOT_PICKUP + Vector3.UP * 0.8}
		if not state.workshop:
			return {}
	if state.hits == 0 or state.collected > 0:
		return {}
	var history: Dictionary = state.observations
	if not state.workshop:
		var free_damage := not history.has("buy_damage") and int(state.damage_rank) == 0
		var shop_ready: bool = state.offers.workshop.available and not history.has("buy_workshop")
		if free_damage or shop_ready:
			return {"kind": "dog", "at": Clearing.DOG_POSITION + Vector3.UP * 1.95}
		return {}
	if state.arrows >= state.capacity:
		return {}
	var nearest := -1
	var distance := INF
	for i in state.workshop_piles.size():
		var landing: Vector3 = Clearing.WORKSHOP_LANDINGS[i]
		var gap := player.distance_squared_to(landing)
		if int(state.workshop_piles[i]) > 0 and gap < distance:
			nearest = i
			distance = gap
	if nearest < 0:
		return {}
	return {"kind": "supply", "at": Clearing.WORKSHOP_LANDINGS[nearest] + Vector3.UP * 0.8}


func update_goal(goal: Dictionary, locale: String) -> void:
	var next: String = goal.get("kind", "")
	if next != kind:
		settle = 0.85
	kind = next
	language = locale
	destination = goal.get("at", Vector3.ZERO)
	visible = not kind.is_empty()
	set_process(visible)
	queue_redraw()


func _process(delta: float) -> void:
	settle = maxf(0.0, settle - delta)
	queue_redraw()


func _draw() -> void:
	if settle > 0 or kind.is_empty() or not is_instance_valid(camera):
		return
	var center := size * 0.5
	var local := camera.to_local(destination)
	var bounds := Rect2(size * Vector2(0.10, 0.29), size * Vector2(0.80, 0.37))
	var point := center
	var direction := Vector2.ZERO
	if local.z < -camera.near:
		point = camera.unproject_position(destination)
		if not bounds.has_point(point):
			direction = (point - center).normalized()
	else:
		direction = Vector2(local.x, -local.y * 0.3).normalized()
		if absf(direction.x) < 0.25:
			direction = Vector2.LEFT if local.x < 0.0 else Vector2.RIGHT
	if direction != Vector2.ZERO:
		var limit_x := bounds.end.x - center.x if direction.x >= 0 else center.x - bounds.position.x
		var limit_y := bounds.end.y - center.y if direction.y >= 0 else center.y - bounds.position.y
		point = center + direction * minf(limit_x / maxf(0.001, absf(direction.x)), limit_y / maxf(0.001, absf(direction.y)))
	else:
		# Pipo already wears an in-world nameplate. The guide only points toward him
		# from the edge of the screen.
		if kind == "dog":
			return
		direction = Vector2.DOWN
		if point.distance_squared_to(center) < 48.0 * 48.0:
			point.y = minf(point.y, center.y - 42)
	var label: String = NAMES[kind][1 if language == "en" else 0]
	var width := ceilf(guide_font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x) + 20
	var card := Rect2((point - Vector2(width / 2, 13)).round(), Vector2(width, 26))
	var tip := point + direction * minf(card.size.x / (2 * maxf(0.001, absf(direction.x))), 13 / maxf(0.001, absf(direction.y)))
	draw_colored_polygon(PackedVector2Array([tip + direction * 8, tip + direction.orthogonal() * 6, tip - direction.orthogonal() * 6]), Journal.INK)
	draw_rect(card, Journal.PAPER)
	draw_rect(card, Journal.INK, false, 1.5)
	draw_string(guide_font, card.position + Vector2(10, 18), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Journal.INK)
