extends SceneTree
## Guard the two upgrades from the player's recording and the geometry around them.

const Map := preload("res://scripts/upgrade_map.gd")
const Paths := preload("res://scripts/upgrade_paths.gd")
var map := Map.new()
var offers := {}
var failed := false

func _initialize() -> void:
	_run.call_deferred()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		printerr("FAIL: ", message)
		failed = true

func _run() -> void:
	root.add_child(map)
	map.size = Vector2(720, 500)
	map.position = Vector2(70, 45)
	var graph := Paths.build_tree()
	var segments := Paths.SEAMS.duplicate()
	for id: String in graph:
		var rule: Dictionary = graph[id]
		if not str(rule.parent).is_empty():
			segments.append([id, rule.parent])
		offers[id] = {"rank": 0, "max_rank": rule.costs.size(), "requires": rule.parent,
			"requirement_met": id == "damage", "available": id == "damage"}
		map.add_socket(id)
	map.arrange(offers)
	for id: String in graph:
		map.update_socket(id, offers[id], false)
	_expect(map.revealed.size() == 5, "A fresh map has a root and four adjacent choices")
	_buy("damage")
	_buy("workshop")
	_expect(map.revealed.size() == 7 and map.revealed.has("capacity") and map.revealed.has("wheel"),
		"The workshop opens exactly two neighboring sockets")
	_buy("wheel")
	_expect(map.revealed.size() == 9, "The wheel opens one short segment per new choice")

	var anchor := map._point(Paths.position_of("wheel"))
	var cursor := map.position + anchor
	var original_zoom := map.zoom
	await process_frame
	_mouse_button(cursor, MOUSE_BUTTON_WHEEL_UP)
	_expect(map.zoom > original_zoom and map._point(Paths.position_of("wheel")).distance_to(anchor) < 1,
		"Scrolling over an icon zooms around that icon")
	_mouse_button(cursor, MOUSE_BUTTON_WHEEL_DOWN)
	_expect(is_equal_approx(map.zoom, original_zoom), "Reverse scrolling returns to the original scale")
	var before := map.pan
	var empty := map.position + Vector2(38, 83)
	_mouse_button(empty, MOUSE_BUTTON_MIDDLE)
	var movement := InputEventMouseMotion.new()
	movement.position = empty + Vector2(36, 23)
	movement.global_position = movement.position
	movement.relative = Vector2(36, 23)
	root.push_input(movement, true)
	_mouse_button(movement.position, MOUSE_BUTTON_MIDDLE, false)
	_expect(map.pan.distance_to(before + movement.relative) < 1, "Dragging pans the map")

	for i in segments.size():
		var a: Array = segments[i]
		_expect(offers.has(a[0]) and offers.has(a[1]), "Each line terminates on real upgrade buttons")
		for j in i:
			var b: Array = segments[j]
			if a[0] in b or a[1] in b:
				continue
			var crossing = Geometry2D.segment_intersects_segment(Paths.position_of(a[0]), Paths.position_of(a[1]),
				Paths.position_of(b[0]), Paths.position_of(b[1]))
			_expect(crossing == null, "Crossing outside a socket: %s and %s" % [a, b])
	if not failed:
		print("PASS: gradual shop branches, cursor-relative zoom, map panning and connected geometry.")
	quit(1 if failed else 0)

func _buy(id: String) -> void:
	offers[id].rank = 1
	map.update_socket(id, offers[id], false)
	map.sync_visibility()

func _mouse_button(point: Vector2, button: MouseButton, pressed := true) -> void:
	var event := InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = button
	event.pressed = pressed
	root.push_input(event, true)
