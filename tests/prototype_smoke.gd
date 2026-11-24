extends SceneTree
## tests/run-tests.ps1 supplies a fresh player profile.

const Game := preload("res://scripts/game.gd")
const Clearing := preload("res://scripts/clearing.gd")
const Save := preload("res://scripts/save_data.gd")
var game: Game


func _initialize() -> void:
	var qa := OS.get_environment("ARCHER_QA_DIR").replace("\\", "/")
	if qa.is_empty() or not OS.get_user_data_dir().begins_with(qa + "/"):
		printerr("Use tests/run-tests.ps1 to isolate the campaign under test.")
		quit(1)
		return
	create_timer(9500.0, true).timeout.connect(func(): _expect(false, "Timed out during the ten-target route"))
	_run.call_deferred()


func _run() -> void:
	change_scene_to_file("res://main.tscn")
	await scene_changed
	game = current_scene
	await _frames(3)
	if not _expect(game.view == "start", "Start menu is visible"):
		return
	await _click(_button_named("Ajustes"))
	var fov := game.hud.find_child("Fov", true, false) as HSlider
	if not _expect(is_instance_valid(fov), "Settings expose the camera field of view"):
		return
	fov.grab_focus()
	await _tap(KEY_RIGHT)
	var chosen_fov: float = fov.value
	if not _expect(chosen_fov > 70.0 and is_equal_approx(game.archer.camera.fov, chosen_fov),
			"The field of view changes through the settings slider"):
		return
	await _click(_button_named("Volver"))
	await _click(root.gui_get_focus_owner() as Button)
	if not _expect(game.view == "play", "The start button enters the clearing"):
		return
	if not _expect(game.trail_marker.visible and game.trail_marker.supply_position == null,
			"Pipo's bearing is available as soon as the player enters the clearing"):
		return
	await _frames(12)
	var floor_y := game.archer.position.y
	await _tap(KEY_SPACE)
	await _frames(7)
	if not _expect(game.archer.position.y > floor_y + 0.15, "Space makes the archer jump"):
		return
	await _frames(55)

	_mouse_left(true)
	if not await _until(func(): return game.run.shots == 1, 6, "The first arrow leaves the bow"):
		return
	_mouse_left(false)
	await _tap(KEY_ESCAPE)
	await _frames(30)
	if not _expect(game.run.hp == 160 and game.run.arrows == 23 and game.run.hits == 0,
			"An arrow in flight consumes ammunition and waits for unpause before impact"):
		return
	await _click(_button_named("Guardar partida"))
	await _reopen()
	if not _expect(game.view == "pause" and game.run.hp == 160 and game.run.arrows == 23
			and game.hud.options.fov == chosen_fov,
			"A saved arrow in flight waits for the player to resume"):
		return
	await _tap(KEY_ESCAPE)
	_mouse_left(true)
	if not await _until(func(): return game.run.hits == 6, 400, "Six held shots hit from spawn"):
		return
	_mouse_left(false)
	if not _expect(game.run.shots == 6 and game.run.hp == 100 and game.run.sap == 7 and game.run.arrows == 18
			and not game.hud.combo_panel.is_visible_in_tree(), "Six hits yield seven sap, with the combo still locked"):
		return
	await _tap(KEY_E)
	if not _expect(game.view == "play", "Interacting away from the dog keeps the player in the clearing"):
		return
	if not await _open_shop():
		return
	var first_nodes: Array = []
	for id: String in game.hud.offer_controls:
		if game.hud.offer_controls[id].is_visible_in_tree():
			first_nodes.append(id)
	first_nodes.sort()
	if not _expect(first_nodes == ["damage", "rate", "refund", "weak", "workshop"],
			"The new tree starts with the center and four neighboring nodes"):
		return
	var root_button: Button = game.hud.offer_controls.damage
	var anchor := root_button.get_global_rect().get_center()
	var initial_zoom: float = game.hud.upgrade_map.zoom
	await _click(root_button, MOUSE_BUTTON_WHEEL_UP)
	if not _expect(game.hud.upgrade_map.zoom > initial_zoom and root_button.get_global_rect().get_center().distance_to(anchor) < 2
			and game.run.damage_rank == 0, "Wheel zoom keeps the node under the pointer without buying it"):
		return
	await _click(root_button, MOUSE_BUTTON_WHEEL_DOWN)
	if not _expect(is_equal_approx(game.hud.upgrade_map.zoom, initial_zoom), "Scrolling down restores the original scale"):
		return
	if not _expect(not game.run.offers().workshop.requirement_met, "The workshop initially requires the damage root"):
		return
	await _click(game.hud.offer_controls["damage"])
	if not _expect(game.run.damage() == 12 and game.run.sap == 7, "The first damage purchase is free"):
		return
	await _tap(KEY_E)
	if not await _walk_to(Vector2(0.0, 5.0)):
		return
	_aim_at("body")
	_mouse_left(true)
	if not await _until(func(): return game.run.hits == 7, 65, "Shooting resumes after the shop"):
		return
	if not _expect(game.run.hp == 88, "The next hit actually deals twelve damage"):
		return
	if not await _until(func(): return game.run.stage == 2 and game.run.sap >= 17, 1100, "N2 workshop affordable through real hits"):
		return
	_mouse_left(false)
	if not await _open_shop():
		return
	var sap_before := game.run.sap
	await _click(game.hud.offer_controls["workshop"])
	if not _expect(game.run.workshop and game.run.sap == sap_before - 17
			and game.hud.offer_controls["wheel"].is_visible_in_tree(), "Workshop costs seventeen and reveals its production branch"):
		return
	var time_before := game.run.elapsed
	await _frames(100)
	if not _expect(game.run.workshop_stock == 0 and game.run.elapsed == time_before, "An open shop freezes production and time"):
		return
	await _tap(KEY_E)
	if not await _walk_to(Vector2(0.0, 5.0)):
		return
	_aim_at("body")
	_mouse_left(true)
	if not await _until(func(): return game.run.arrows == 0, 650, "Empty the quiver through ordinary shots"):
		return
	_mouse_left(false)

	# Approach the left side of the knot, outside automatic collection range.
	if not await _walk_to(Vector2(-0.95, -2.35)):
		return
	var wood_before := game.run.hp
	var pile_before := game.run.knot_stock
	await _tap(KEY_F)
	await _frames(3)
	if not _expect(game.run.hp < wood_before and game.run.knot_stock == pile_before + 4,
			"A branch strike with an empty quiver releases four physical arrows"):
		return
	if not await _walk_to(Vector2(0.45, -2.35)):
		return
	if not _expect(game.run.knot_stock == 0 and game.run.arrows == pile_before + 4,
			"Walking into the knot bundle transfers its full contents"):
		return

	if not await _until(func(): return game.run.workshop_stock >= 32, 2000, "Workshop accumulates while the player is away"):
		return
	await _tap(KEY_ESCAPE)
	var stock_before := game.run.workshop_stock
	time_before = game.run.elapsed
	await _frames(120)
	if not _expect(game.view == "pause" and game.run.workshop_stock == stock_before and game.run.elapsed == time_before,
			"Escape freezes an operating workshop"):
		return
	await _tap(KEY_ESCAPE)
	var carried := game.run.arrows
	if not await _walk_to(Vector2(Clearing.WORKSHOP_PICKUP.x, Clearing.WORKSHOP_PICKUP.z)):
		return
	await _frames(480)
	if not _expect(game.run.arrows == carried and game.run.workshop_stock > 32,
			"Standing at the workshop outlet does not collect launched bundles"):
		return
	var stock_and_carried := _workshop_inventory()
	time_before = game.run.elapsed
	await _refill()
	var produced := (game.run.elapsed - time_before) * game.run.production_rate()
	if not _expect(game.run.collected > 0 and absf(_workshop_inventory() - stock_and_carried - produced) < 0.0001,
			"Buffer, airborne bundles, landed stock and collected arrows reconcile"):
		return
	if not await _fight_until(func(): return game.run.stage >= 3 and game.run.sap >= 45):
		return
	await _buy("weak")
	await _buy("spark")
	if not await _fight_until(func(): return game.run.stage >= 4 and game.run.sap >= 65):
		return
	await _buy("rate")
	await _buy("recurve")
	await _buy("refund")
	if not await _open_shop():
		return
	var sap_before_refund := game.run.sap
	await _click(game.hud.offer_controls["rate"], MOUSE_BUTTON_RIGHT)
	if not _expect(game.run.rank_of("rate") == 0 and game.run.sap == sap_before_refund + 14 and game.run.bow == "recurve",
			"A right click returns exactly one paid level and preserves its purchased child"):
		return
	await _tap(KEY_E)
	if not _expect(game.run.bow == "recurve" and game.run.rank_of("spark") == 1, "New purchases work in combat"):
		return
	if not await _fight_until(func(): return game.run.split):
		return
	await _frames(30)
	if not await _fight_until(func(): return game.run.left_hp == 0, "left"):
		return
	var remaining := game.run.right_hp
	await _reopen()
	if not _expect(game.view == "pause" and game.run.split and game.run.left_hp == 0 and game.run.right_hp == remaining,
			"The automatic checkpoint preserves the surviving half"):
		return
	await _tap(KEY_ESCAPE)
	if not await _fight_until(func(): return game.view == "gift", "right"):
		return
	var offer := game.run.gift_offer.duplicate()
	await _reopen()
	if not _expect(game.view == "gift" and offer.size() == 3 and game.run.gift_offer == offer,
			"Relaunching preserves the exact three cards in order"):
		return
	await _tap(KEY_ESCAPE)
	if not _expect(game.view == "pause" and _button_named("Mejoras") == null,
			"Pausing the pending reward cannot open purchases after the boss"):
		return
	await _tap(KEY_ESCAPE)
	if not _expect(game.view == "gift" and game.run.gift_offer == offer,
			"Resuming the pending reward returns to the same three cards"):
		return
	await _click(_button_named("English"))
	if not _expect(game.hud.language == "en" and game.run.gift_offer == offer and game.hud.confirm_gift.text.contains("Confirm"),
			"Switching the card screen to English preserves its choices"):
		return
	await _click(_button_named("Español"))
	await _click(game.hud.gift_buttons[offer[0]])
	await _click(game.hud.confirm_gift)
	await _reopen()
	if not _expect(game.view == "end" and game.run.chosen_gift == offer[0] and game.run.bow == "recurve"
			and game.hud.end_stats.is_visible_in_tree(), "The result, purchases and chosen reward survive a relaunch"):
		return
	await _click(_button_named("Ver tiempos de la prueba"))
	if not _expect(game.hud.is_submenu_open() and game.run.observations.has("first_production_pickup"),
			"Playtest timings are available from the final result"):
		return
	await _click(_button_named("Volver al resumen"))
	await _click(_button_named("Registro de la vuelta"))
	if not _expect(game.hud.submenu == "run_log" and Save.best_times().has("act1"), "The journal records the first boss split"):
		return
	await _click(_button_named("English"))
	if not _expect(_button_named("Back to results") != null, "The run log switches language with the notebook"):
		return
	await _click(_button_named("Español"))
	await _tap(KEY_ESCAPE)
	await _click(_button_named("Continuar al blanco 6"))
	if not _expect(game.view == "play" and game.trail_marker.visible and game.run.stage == 6 and game.run.first_gift == offer[0],
			"Continuing enters the second act with the saved reward"):
		return
	for stage in range(6, 11):
		for upgrade in ["rate", "rate_step_01", "rate_step_02", "longbow", "capacity", "pickup", "leap", "wheel", "damage"]:
			if upgrade == "rate" and game.run.rank_of("rate") > 0:
				continue
			while game.run.offers()[upgrade].available:
				await _buy(upgrade)
				if upgrade == "rate":
					break
		if game.run.rank_of("longbow") > 0 and game.run.bow != "longbow":
			await _tap(KEY_3)
		if stage < 10:
			if not await _fight_until(func(): return game.run.stage > stage):
				return
	if not _expect(game.run.bow == "longbow" and game.run.rank_of("leap") == 1 and game.run.volley_size() == 3,
			"Purchases during the route unlock the third bow, directed jump and three-arrow volleys"):
		return
	if not await _check_supply_jump():
		return
	for upgrade in ["damage_step_13", "damage_step_14", "damage_step_15", "damage_step_16", "pet"]:
		await _buy(upgrade)
	await _tap(KEY_R)
	if not _expect(game.run.rank_of("pet") > 0 and game.view == "play", "Petting is available alongside the dog interaction"):
		return
	if game.run.arrows < 3:
		await _refill()
	elif not await _walk_to(Vector2(0.0, 5.0)):
		return
	_aim_at("core_0")
	var arrows_before := game.run.arrows
	_mouse_left(true)
	if not await _until(func(): return game.in_flight.size() == 12, 90, "Three paid arrows call a nine-arrow rain"):
		return
	_mouse_left(false)
	var paid := game.in_flight.filter(func(flight: Dictionary): return not flight.has("source"))
	if not _expect(game.run.arrows == arrows_before - 3 and paid.size() == 3 and paid[0].end != paid[1].end
			and paid[0].damage == paid[2].damage, "The fan spends three arrows with three trajectories and equal base damage"):
		return
	for phase in 3:
		if not await _fight_until(func(): return game.run.core_phase > phase or game.view == "gift", "core_%d" % phase):
			return
		if phase == 0:
			await _reopen()
			if not _expect(game.view == "pause" and game.run.core_phase == 1,
					"The moving weak spot survives the automatic phase checkpoint"):
				return
			await _tap(KEY_ESCAPE)
	if not _expect(game.view == "gift" and game.run.stage == 10 and game.run.gift_offer.size() == 3,
			"The second boss offers three rewards"):
		return
	await _click(game.hud.gift_buttons[game.run.gift_offer[0]])
	await _click(game.hud.confirm_gift)
	await _reopen()
	if not _expect(game.view == "end" and game.run.stage == 10 and _button_named("Continuar al blanco 6") == null,
			"The tenth target ends the demo on the saved result"):
		return
	print("Route timing, active seconds: target 10 entered at ", game.run.observations.broke_9,
			", finished at ", game.run.observations.broke_10)
	await _click(_button_named("Volver a jugar"))
	await _click(_button_named("Empezar de nuevo"))
	await _frames(6)
	game = current_scene
	if not _expect(game.view == "play" and game.run.stage == 1 and game.run.hp == 160
			and game.run.sap == 0 and game.run.arrows == 24 and not game.run.workshop and game.run.shots == 0,
			"Replay resets position in the campaign, currency, arrows and purchases"):
		return
	if not _expect(Save.best_times().has_all(["act1", "act2", "total"]), "Replay preserves the local records"):
		return
	if not await _walk_to(Vector2(10.6, 12.1)):
		return
	_key(KEY_D, true)
	_key(KEY_S, true)
	await _frames(100)
	_key(KEY_D, false)
	_key(KEY_S, false)
	var corner := game.archer.position
	if not _expect(corner.x > 10.6 and corner.z > 12.1 and corner.x < Clearing.ARENA_HALF_WIDTH
			and corner.z < Clearing.ARENA_HALF_LENGTH, "The larger clearing opens both old limits and stops at the new fences"):
		return
	print("PASS: ten targets, dog shop and refunds, directed jump, longbow, triple shots, supply, both bosses, rewards, save/resume and replay.")
	unload_current_scene()
	# The audio mixer runs on a wall clock even when simulation uses fixed FPS.
	# Let it retire queued voices from the replay transition before engine shutdown.
	for i in 3:
		await process_frame
		OS.delay_msec(30)
	quit()


func _frames(count: int) -> void:
	for i in count:
		await physics_frame


func _open_shop() -> bool:
	var dog := Clearing.DOG_POSITION
	if not game.clearing.is_near_dog(game.archer.position):
		# Approach from the path in front of the workshop rather than through its walls.
		if game.archer.position.z < 2.0 and not await _walk_to(Vector2(game.archer.position.x, 2.8)):
			return false
		if not await _walk_to(Vector2(dog.x + 0.95, dog.z + 0.65)):
			return false
	await _tap(KEY_E)
	return _expect(game.view == "shop", "E near the dog opens upgrades")


func _buy(id: String) -> void:
	if not await _open_shop():
		return
	await _click(game.hud.offer_controls[id])
	await _tap(KEY_E)


func _check_supply_jump() -> bool:
	var point := Clearing.WORKSHOP_LANDINGS[1]
	if not await _walk_to(Vector2(point.x + 3.4, point.z + 1.5)):
		return false
	if not await _until(func(): return game.run.workshop_piles[1] > 0, 1000, "A bundle lands at the jump destination"):
		return false
	_look_at(point + Vector3.UP * 0.2)
	await _tap(KEY_SPACE)
	await _frames(50)
	var position := game.archer.position
	return _expect(Vector2(position.x, position.z).distance_to(Vector2(point.x, point.z)) < 0.8,
			"Looking at a landed bundle and jumping reaches it without walking")


func _workshop_inventory() -> float:
	var total := game.run.workshop_stock + game.run.collected + game.run.workshop_buffer + game.run.workshop_fraction
	for bundle: Dictionary in game.run.workshop_flights:
		total += int(bundle.count)
	return total


func _refill() -> void:
	# Both destinations lie along a clear route from the shooting position.
	for slot in [1, 2]:
		var point: Vector3 = Clearing.WORKSHOP_LANDINGS[slot]
		if not await _walk_to(Vector2(point.x, point.z)):
			return
		if game.run.arrows >= game.run.capacity() / 2.0:
			break
	if game.run.arrows == 0:
		await _until(func(): return game.run.arrows > 0, 800, "Next bundle lands within reach")
	await _walk_to(Vector2(0.4, 3.8))


func _fight_until(done: Callable, target_id := "body") -> bool:
	if game.clearing.is_near_dog(game.archer.position) and not await _walk_to(Vector2(0, 5)):
		return false
	for trip in 600:
		if done.call():
			return true
		if game.run.arrows == 0:
			# The final release can empty the quiver while the killing shot is still in flight.
			await _until(func(): return game.in_flight.is_empty() or done.call(), 50, "Last arrows land")
			if game.run.hp == 0 and game.view == "play":
				await _until(func(): return game.run.hp > 0 or game.view != "play", 50, "Target break finishes")
			if done.call():
				return true
			await _refill()
		_aim_at(target_id)
		_mouse_left(true)
		if not await _until(func(): return done.call() or game.run.arrows == 0, 6500, "A volley reaches a milestone or empties the quiver"):
			return false
		_mouse_left(false)
		await _frames(10)
	return _expect(done.call(), "Campaign milestone reached")


func _button_named(caption: String) -> Button:
	for button in game.hud.find_children("*", "Button", true, false):
		if button.is_visible_in_tree() and button.text == caption:
			return button
	return null


func _reopen() -> void:
	change_scene_to_file("res://main.tscn")
	await scene_changed
	game = current_scene
	await _frames(4)
	await _click(_button_named("Continuar"))


func _aim_at(target_id: String) -> void:
	_look_at(game.clearing.target_center(target_id))


func _look_at(point: Vector3) -> void:
	var pose := game.archer.save_pose()
	var direction := game.archer.camera.global_position.direction_to(point)
	pose.yaw = atan2(-direction.x, -direction.z)
	pose.pitch = asin(direction.y)
	game.archer.restore_pose(pose)


func _expect(condition: bool, message: String) -> bool:
	if not condition:
		printerr("FAIL: ", message)
		if is_instance_valid(game):
			printerr("view=", game.view, " position=", game.archer.position, " state=", game.run.snapshot())
		quit(1)
	return condition


func _until(condition: Callable, frames: int, message: String) -> bool:
	for i in frames:
		if condition.call():
			return true
		await physics_frame
	return _expect(bool(condition.call()), message)


func _send(event: InputEvent) -> void:
	Input.parse_input_event(event)
	Input.flush_buffered_events()


func _key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	_send(event)


func _tap(code: Key) -> void:
	_key(code, true)
	await _frames(1)
	_key(code, false)
	await _frames(2)


func _mouse_left(pressed: bool, at: Vector2 = Vector2(640, 360)) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = at
	event.global_position = at
	_send(event)


func _click(button: Button, mouse_button := MOUSE_BUTTON_LEFT) -> void:
	if not _expect(is_instance_valid(button) and button.is_visible_in_tree() and not button.disabled,
			"The requested button is visible and enabled"):
		return
	var parent := button.get_parent()
	while parent != null:
		if parent is ScrollContainer:
			parent.ensure_control_visible(button)
			await _frames(3)
		parent = parent.get_parent()
	var center := button.get_global_rect().get_center()
	for down: bool in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = mouse_button
		event.pressed = down
		event.position = center
		event.global_position = center
		root.push_input(event, true)
		await _frames(1)
	await _frames(3)


func _walk_to(target: Vector2) -> bool:
	var pose := game.archer.save_pose()
	pose.yaw = 0.0
	pose.pitch = 0.0
	game.archer.restore_pose(pose)
	var keys := {KEY_A: false, KEY_D: false, KEY_W: false, KEY_S: false}
	for i in 240:
		var offset := target - Vector2(game.archer.position.x, game.archer.position.z)
		if offset.length() <= 0.14:
			break
		var next := {KEY_A: offset.x < -0.12, KEY_D: offset.x > 0.12, KEY_W: offset.y < -0.12, KEY_S: offset.y > 0.12}
		for code in keys:
			if keys[code] != next[code]:
				_key(code, next[code])
				keys[code] = next[code]
		await physics_frame
	for code in keys:
		if keys[code]:
			_key(code, false)
	await _frames(12)
	return _expect(Vector2(game.archer.position.x, game.archer.position.z).distance_to(target) < 0.60,
			"WASD reaches " + str(target))
