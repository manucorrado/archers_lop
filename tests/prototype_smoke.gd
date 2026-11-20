extends SceneTree
## tests/run-tests.ps1 supplies a fresh player profile.

const Game := preload("res://scripts/game.gd")
const Clearing := preload("res://scripts/clearing.gd")
var game: Game


func _initialize() -> void:
	var qa := OS.get_environment("ARCHER_QA_DIR").replace("\\", "/")
	if qa.is_empty() or not OS.get_user_data_dir().begins_with(qa + "/"):
		printerr("Use tests/run-tests.ps1 to isolate the campaign under test.")
		quit(1)
		return
	create_timer(1100.0, true).timeout.connect(func(): _expect(false, "Timed out during the first act"))
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
	if not _expect(game.run.shots == 6 and game.run.hp == 100 and game.run.sap == 4 and game.run.arrows == 18,
			"Six 10-damage arrows yield four sap"):
		return
	await _tap(KEY_TAB)
	if not _expect(game.view == "shop", "Tab opens upgrades"):
		return
	await _click(game.hud.offer_controls.damage.button)
	if not _expect(game.run.damage() == 12 and game.run.sap == 0, "First damage purchase spends exactly four sap"):
		return
	await _tap(KEY_TAB)
	_mouse_left(true)
	if not await _until(func(): return game.run.hits == 7, 65, "Shooting resumes after the shop"):
		return
	if not _expect(game.run.hp == 88, "The next hit actually deals twelve damage"):
		return
	if not await _until(func(): return game.run.stage == 2 and game.run.sap >= 17, 1100, "N2 workshop affordable through real hits"):
		return
	_mouse_left(false)
	await _tap(KEY_TAB)
	var sap_before := game.run.sap
	await _click(game.hud.offer_controls.workshop.button)
	if not _expect(game.run.workshop and game.run.sap == sap_before - 17, "Workshop costs seventeen sap"):
		return
	var time_before := game.run.elapsed
	await _frames(100)
	if not _expect(game.run.workshop_stock == 0 and game.run.elapsed == time_before, "An open shop freezes production and time"):
		return
	await _tap(KEY_TAB)
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

	if not await _until(func(): return game.run.workshop_stock >= 32, 1350, "Workshop accumulates while the player is away"):
		return
	await _tap(KEY_ESCAPE)
	var stock_before := game.run.workshop_stock
	time_before = game.run.elapsed
	await _frames(120)
	if not _expect(game.view == "pause" and game.run.workshop_stock == stock_before and game.run.elapsed == time_before,
			"Escape freezes an operating workshop"):
		return
	await _tap(KEY_ESCAPE)
	var arrows_before := game.run.arrows
	var fraction_before := game.run.workshop_fraction
	time_before = game.run.elapsed
	if not await _walk_to(Vector2(Clearing.WORKSHOP_PICKUP.x, Clearing.WORKSHOP_PICKUP.z)):
		return
	var made_during_walk := (game.run.elapsed - time_before) * game.run.WORKSHOP_RATE
	var accounted := game.run.workshop_stock + game.run.collected + game.run.workshop_fraction
	if not _expect(game.run.arrows == game.run.capacity() and game.run.workshop_stock > 0
			and game.run.collected == game.run.capacity() - arrows_before
			and absf(accounted - stock_before - fraction_before - made_during_walk) < 0.0001,
			"A partial workshop pickup fills the quiver and conserves the remaining pile"):
		return

	# Headless has no captured mouse. Orient the camera at real geometry; all
	# damage, pickups, shop purchases and phase changes use normal game input.
	_aim_at("body")
	_mouse_left(true)
	if not await _until(func(): return game.run.stage == 3 and game.run.offers().spark.available,
			7000, "The third target unlocks the spark"):
		return
	_mouse_left(false)
	await _tap(KEY_TAB)
	await _click(game.hud.offer_controls.spark.button)
	await _tap(KEY_TAB)
	_mouse_left(true)
	if not await _until(func(): return game.run.stage == 4 and game.run.offers().recurve.available,
			10000, "The fast bow is affordable in the fourth encounter"):
		return
	_mouse_left(false)
	await _tap(KEY_TAB)
	await _click(game.hud.offer_controls.recurve.button)
	await _tap(KEY_TAB)
	if not _expect(game.run.bow == "recurve" and game.run.rank_of("spark") == 1,
			"The purchased bow is equipped and the spark is owned"):
		return
	_mouse_left(true)
	if not await _until(func(): return game.run.split, 22000, "At half health the fifth target splits"):
		return
	_mouse_left(false)
	await _frames(40)
	_aim_at("left")
	_mouse_left(true)
	if not await _until(func(): return game.run.left_hp == 0, 11000, "Shots can destroy the left half"):
		return
	_mouse_left(false)
	var remaining := game.run.right_hp
	await _reopen()
	if not _expect(game.view == "pause" and game.run.split and game.run.left_hp == 0 and game.run.right_hp == remaining,
			"The automatic checkpoint preserves the surviving half"):
		return
	await _tap(KEY_ESCAPE)
	_aim_at("right")
	_mouse_left(true)
	if not await _until(func(): return game.view == "gift", 11000, "Destroying the right half opens the three choices"):
		return
	_mouse_left(false)
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
	await _click(root.gui_get_focus_owner() as Button)
	await _click(_button_named("Empezar de nuevo"))
	await _frames(6)
	game = current_scene
	if not _expect(game.view == "play" and game.run.stage == 1 and game.run.hp == 160
			and game.run.sap == 0 and game.run.arrows == 24 and not game.run.workshop and game.run.shots == 0,
			"Replay resets position in the campaign, currency, arrows and purchases"):
		return
	print("PASS: N1–5, purchases, paused shot on disk, workshop stock, both boss halves, offer, final result and replay.")
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
	var pose := game.archer.save_pose()
	var direction := game.archer.camera.global_position.direction_to(game.clearing.target_center(target_id))
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


func _click(button: Button) -> void:
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
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		event.position = center
		event.global_position = center
		root.push_input(event, true)
		await _frames(1)
	await _frames(3)


func _walk_to(target: Vector2) -> bool:
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
