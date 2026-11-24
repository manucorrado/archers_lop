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
		map.update_socket(id, offers[id])
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
	var pointing := InputEventMouseMotion.new()
	pointing.position = cursor
	pointing.global_position = cursor
	root.push_input(pointing, true)
	_expect(map._inspected == "wheel", "Pointing inspects that upgrade")
	pointing.position = map.position + Vector2(40, 82)
	pointing.global_position = pointing.position
	root.push_input(pointing, true)
	_expect(map._inspected.is_empty(), "Leaving the socket removes its detail")
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
	for id: String in offers:
		offers[id].rank = offers[id].max_rank
		map.update_socket(id, offers[id])
	offers.damage.rank -= 1
	map.sync_visibility()
	_expect(not map._complete, "Owning each socket alone does not finish its ranks")
	offers.damage.rank += 1
	map.sync_visibility()
	_expect(map._show_drawing and map._collection.visible, "The final rank reveals the bow and quiver")
	await create_timer(0.8).timeout
	_expect(is_equal_approx(map._ink, 1.0) and not map.buttons.damage.visible, "The individual seals fade completely")
	map._collection.pressed.emit()
	_expect(map.buttons.damage.visible and map.buttons.damage.focus_mode == Control.FOCUS_ALL, "The finished collection can be inspected and refunded")
	offers.damage.rank -= 1
	map.sync_visibility()
	_expect(not map._complete and not map._collection.visible and map._legend.visible, "A refund restores the regular map")
	map.animate_completion = false
	offers.damage.rank += 1
	map.sync_visibility()
	_expect(is_equal_approx(map._ink, 1.0) and not map.buttons.damage.visible, "Reduced motion shows the completed drawing immediately")
	var loaded := Map.new()
	root.add_child(loaded)
	for id: String in offers:
		loaded.add_socket(id)
	loaded.arrange(offers)
	_expect(loaded._complete and is_equal_approx(loaded._ink, 1.0) and not loaded.buttons.damage.visible,
		"Opening a completed save restores the finished drawing directly")
	loaded.queue_free()
	if not failed:
		print("PASS: atlas neighbors, zoom, map panning, geometry, completion reveal, inspection and reduced motion.")
	quit(1 if failed else 0)

func _buy(id: String) -> void:
	offers[id].rank = 1
	map.update_socket(id, offers[id])
	map.sync_visibility()

func _mouse_button(point: Vector2, button: MouseButton, pressed := true) -> void:
	var event := InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = button
	event.pressed = pressed
	root.push_input(event, true)
