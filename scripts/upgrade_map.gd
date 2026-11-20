extends Control
## Lay out the same prerequisite relationships the shop uses to authorize purchases.

const CARD := Vector2(154, 46)
const COLUMN := 184
const ROW := 53

var buttons: Dictionary = {}
var parents: Dictionary = {}
var unlocked_edges: Dictionary = {}
var _next_leaf := 0


func arrange(offers: Dictionary) -> void:
	var children := {}
	var roots: Array[String] = []
	for id: String in buttons:
		var parent: String = offers[id].requires
		if parent.is_empty():
			roots.append(id)
		else:
			parents[id] = parent
			if not children.has(parent):
				children[parent] = []
			children[parent].append(id)
	_next_leaf = 0
	for id in roots:
		_place_branch(id, 0, children)
	queue_redraw()


func _place_branch(id: String, depth: int, children: Dictionary) -> float:
	var row := float(_next_leaf)
	if children.has(id):
		var child_rows: Array[float] = []
		for child: String in children[id]:
			child_rows.append(_place_branch(child, depth + 1, children))
		row = (child_rows.front() + child_rows.back()) * 0.5
	else:
		_next_leaf += 1
	var button: Button = buttons[id]
	button.position = Vector2(4 + depth * COLUMN, 4 + row * ROW)
	button.size = CARD
	custom_minimum_size = custom_minimum_size.max(button.position + button.size + Vector2(4, 4))
	return row


func _draw() -> void:
	for child: String in parents:
		var parent: Button = buttons[parents[child]]
		var button: Button = buttons[child]
		var start := parent.position + Vector2(parent.size.x, parent.size.y * 0.5)
		var finish := button.position + Vector2(0, button.size.y * 0.5)
		var elbow := (start.x + finish.x) * 0.5
		var tint := Color("#dec08b") if unlocked_edges.get(child, false) else Color("#64766b")
		draw_polyline(PackedVector2Array([start, Vector2(elbow, start.y), Vector2(elbow, finish.y), finish]), tint, 2.0)
