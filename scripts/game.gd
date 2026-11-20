extends Node3D

const Run = preload("res://scripts/run.gd")
const Clearing = preload("res://scripts/clearing.gd")
const Archer = preload("res://scripts/archer.gd")
const Interface = preload("res://scripts/interface.gd")
const SaveData = preload("res://scripts/save_data.gd")

var run := Run.new()
var clearing := Clearing.new()
var archer := Archer.new()
var hud := Interface.new()
var view := "start"
var shot_wait := 0.0
var branch_wait := 0.0
var recovery_wait := 0.0
var break_wait := 0.0
var wants_shot := false
var wants_branch := false
var in_flight: Array = []
var campaign_started := false
var has_save := false
var hud_wait := 0.0
var checkpoint_due := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_window().min_size = Vector2i(800, 450)
	clearing.process_mode = Node.PROCESS_MODE_PAUSABLE
	archer.process_mode = Node.PROCESS_MODE_PAUSABLE
	archer.position = Vector3(0, 0, 5)
	add_child(clearing)
	add_child(archer)
	add_child(hud)
	archer.shot_requested.connect(func(): wants_shot = true)
	archer.branch_requested.connect(func(): wants_branch = true)
	hud.start_requested.connect(_start_campaign)
	hud.continue_requested.connect(_resume_campaign)
	hud.save_requested.connect(_manual_save)
	hud.resume_requested.connect(_resume_play)
	hud.shop_requested.connect(_set_view.bind("shop"))
	hud.restart_requested.connect(_restart)
	hud.quit_requested.connect(_quit)
	hud.buy_requested.connect(_buy)
	hud.gift_requested.connect(_choose_gift)
	hud.equip_requested.connect(_equip)
	hud.settings_changed.connect(_apply_settings)
	get_tree().auto_accept_quit = false
	get_window().close_requested.connect(_quit)
	get_window().focus_exited.connect(_focus_lost)
	_apply_settings(hud.options)
	has_save = SaveData.has_campaign()
	hud.set_can_continue(has_save)
	_redraw_world()
	var replay := get_tree().has_meta("archer_replay")
	if replay:
		get_tree().remove_meta("archer_replay")
		_start_campaign()
	else:
		_set_view("start")


func _apply_settings(options: Dictionary) -> void:
	archer.apply_settings(options)
	clearing.apply_settings(options)


func _start_campaign() -> void:
	if campaign_started:
		_restart()
		return
	campaign_started = true
	run.sample_session(Time.get_ticks_usec())
	_set_view("play")
	_save_campaign()


func _resume_play() -> void:
	if not run.chosen_gift.is_empty():
		_set_view("end")
	elif not run.gift_offer.is_empty():
		_set_view("gift")
	else:
		_set_view("play")


func _set_view(next: String) -> void:
	if next in ["play", "shop"] and not run.gift_offer.is_empty():
		next = "gift"
	view = next
	wants_shot = false
	wants_branch = false
	get_tree().paused = view != "play"
	archer.set_active(view == "play")
	_sync()
	hud.set_view(view)


func _focus_lost() -> void:
	if view == "play":
		_set_view("pause")


func _input(event: InputEvent) -> void:
	if event.is_echo() or not hud.is_node_ready() or hud.is_submenu_open():
		return
	if event.is_action_pressed("pause") and view in ["play", "shop", "gift", "pause"]:
		get_viewport().set_input_as_handled()
		if view == "play" or view == "gift":
			_set_view("pause")
		else:
			_resume_play()
	elif event.is_action_pressed("shop") and view in ["play", "shop"]:
		get_viewport().set_input_as_handled()
		_set_view("shop" if view == "play" else "play")
	elif view == "play":
		var selected := ""
		if event.is_action_pressed("bow_1"):
			selected = "branch"
		elif event.is_action_pressed("bow_2"):
			selected = "recurve"
		elif event.is_action_pressed("bow_previous") or event.is_action_pressed("bow_next"):
			selected = "recurve" if run.bow == "branch" else "branch"
		if not selected.is_empty():
			get_viewport().set_input_as_handled()
			_equip(selected)


func _equip(id: String) -> void:
	if view in ["shop", "play"] and run.equip(id):
		archer.set_bow(run.bow)
		_sync()


func _physics_process(delta: float) -> void:
	if view != "play":
		return
	run.sample_session(Time.get_ticks_usec())
	var old_target := run.target_serial
	var old_rain := run.event_serial
	var old_stock := run.workshop_stock
	run.tick(delta)
	shot_wait = maxf(0.0, shot_wait - delta)
	branch_wait = maxf(0.0, branch_wait - delta)
	recovery_wait = maxf(0.0, recovery_wait - delta)
	_tick_flights(delta)
	if old_target != run.target_serial or old_rain != run.event_serial:
		_sync()
		clearing.play_encounter_cue("target" if old_target != run.target_serial else "event")
	if break_wait > 0:
		break_wait = maxf(0.0, break_wait - delta)
		if break_wait <= 0:
			_next_knot()
	elif wants_branch and branch_wait <= 0:
		_strike()
	elif wants_shot and shot_wait <= 0:
		_shoot()
	wants_branch = false
	wants_shot = false
	if view != "play":
		_flush_checkpoint()
		return
	var collected := _collect_nearby()
	hud_wait -= delta
	if collected or old_stock != run.workshop_stock:
		_sync_piles()
	elif hud_wait <= 0:
		_sync()
	_flush_checkpoint()


func _flush_checkpoint() -> void:
	if checkpoint_due:
		checkpoint_due = false
		_save_campaign()


func _shoot() -> void:
	if run.arrows == 0:
		shot_wait = 0.5
		archer.play_cue("empty")
		if run.fired_after_collect:
			hud.notify("Carcaj vacío", "Empty quiver")
		else:
			hud.notify("Sin flechas · Recogé un haz o golpeá el tronco con la rama.",
				"Out of arrows · Pick up a bundle or strike the trunk with your branch.")
		return
	shot_wait = run.shot_interval()
	run.note_shot()
	var ray: Dictionary = archer.aim_hit()
	var endpoint: Vector3 = ray.get("position", archer.camera.global_position - archer.camera.global_basis.z * 50.0)
	var id := clearing.target_id(ray.get("collider"), endpoint)
	var duration := archer.flight_duration(endpoint)
	in_flight.append({"stage": run.stage, "id": id, "origin": archer.arrow_origin(),
		"end": endpoint, "duration": duration, "remaining": duration, "damage": run.damage(),
		"weak_damage": run.damage(true), "serial": run.event_serial if id.begins_with("seed_") else run.target_serial})
	archer.play_shot(endpoint)
	_sync()


func _tick_flights(delta: float) -> void:
	# El mismo reloj gobierna el impacto al reabrir una partida con la flecha en vuelo.
	for flight: Dictionary in in_flight.duplicate():
		flight.remaining -= delta
		if flight.remaining > 0:
			continue
		in_flight.erase(flight)
		if flight.stage == run.stage and run.hp > 0:
			_land_shot(flight)


func _land_shot(flight: Dictionary) -> void:
	var milestone := _boss_milestone()
	var outcome := run.manual_impact(flight.id, flight.damage, flight.weak_damage, flight.serial)
	if not outcome.hit:
		archer.play_cue("miss")
		return
	hud.hit_marker()
	clearing.hit_feedback(flight.end)
	if outcome.direct > 0:
		hud.show_damage(outcome.direct, "manual")
	if outcome.spark > 0:
		clearing.play_spark(clearing.target_center(outcome.spark_target))
		hud.show_damage(outcome.spark, "spark")
	_after_damage(milestone)


func _strike() -> void:
	branch_wait = 1.0
	archer.play_branch()
	var ray: Dictionary = archer.aim_hit(3.0)
	var point: Vector3 = ray.get("position", Vector3.ZERO)
	var id := clearing.target_id(ray.get("collider"), point)
	if run.vulnerability(id) <= 0:
		hud.notify("Acercate a la madera para golpearla.", "Move closer to strike the wood.")
		return
	if run.arrows == 0 and recovery_wait <= 0:
		run.knot_stock += 4
		recovery_wait = 4.0
		hud.notify("Cayeron cuatro flechas al pie del tronco.", "Four arrows dropped at the foot of the trunk.")
	var milestone := _boss_milestone()
	var damage := run.damage_part(roundi(4 * Run.POWER[run.stage - 1]), id)
	hud.show_damage(damage, "branch")
	clearing.hit_feedback(point)
	hud.hit_marker()
	_after_damage(milestone)


func _boss_milestone() -> int:
	if not run.split:
		return 0
	return 2 if run.left_hp == 0 or run.right_hp == 0 else 1


func _after_damage(previous_milestone: int) -> void:
	var milestone := _boss_milestone()
	if run.hp == 0:
		break_wait = 0.65
		archer.play_cue("break")
		clearing.break_feedback()
	else:
		archer.play_cue("hit")
		if milestone == 1 and previous_milestone == 0:
			hud.notify("El tronco se abrió. Cada mitad tiene su propia resistencia.",
				"The trunk split. Each half has its own health.")
		elif milestone == 2 and previous_milestone == 1:
			hud.notify("Una mitad cayó. Apuntá a la que sigue en pie.",
				"One half fell. Aim at the one still standing.")
	_sync_piles()
	if run.hp == 0 or previous_milestone != milestone:
		# Record the complete step including the other arrows landing on this tick.
		checkpoint_due = true


func _next_knot() -> void:
	if run.stage == 5:
		run.prepare_gifts()
		archer.play_cue("win")
		_set_view("gift")
		checkpoint_due = true
		return
	if not run.next_knot():
		return
	clearing.set_stage(run.stage)
	match run.stage:
		2: hud.notify("Ya podés comprar el taller de flechas.", "You can now buy the arrow workshop.")
		3: hud.notify("Chispa de copa · Una descarga cada ocho aciertos.", "Canopy spark · A discharge every eight hits.")
		4: hud.notify("Ya podés comprar el arco rápido (recurvo).", "You can now buy the recurve bow.")
		5: hud.notify("Último blanco · Tronco partido", "Final target · Twin Fork")
	_sync_piles()
	checkpoint_due = true


func _collect_nearby() -> bool:
	var pos := Vector2(archer.position.x, archer.position.z)
	var radius := run.pickup_radius()
	var total := 0
	var at_workshop := pos.distance_to(Vector2(Clearing.WORKSHOP_PICKUP.x, Clearing.WORKSHOP_PICKUP.z)) <= radius
	run.observe_workshop_visit(at_workshop)
	if run.workshop_stock > 0 and at_workshop:
		total += run.collect(true)
	if run.knot_stock > 0 and pos.distance_to(Vector2(Clearing.KNOT_PICKUP.x, Clearing.KNOT_PICKUP.z)) <= radius:
		total += run.collect(false)
	for id: String in run.seed_drops.keys():
		var drop := clearing.seed_drop_position(id)
		if pos.distance_to(Vector2(drop.x, drop.z)) <= radius:
			total += run.collect_seeds(id)
	if total <= 0:
		return false
	archer.play_cue("pickup")
	hud.notify("+%d flechas" % total, "+%d arrows" % total)
	return true


func _buy(id: String) -> void:
	if view != "shop":
		return
	run.sample_session(Time.get_ticks_usec())
	var previous := run.save_state()
	if not run.buy(id):
		return
	if not _save_campaign():
		run.restore_state(previous)
		run.sample_session(Time.get_ticks_usec())
		_sync()
		return
	if id == "workshop":
		clearing.set_workshop(true)
	archer.set_bow(run.bow)
	archer.play_cue("buy")
	_sync()


func _choose_gift(id: String) -> void:
	if view != "gift":
		return
	run.sample_session(Time.get_ticks_usec())
	var previous := run.save_state()
	if not run.choose_gift(id):
		return
	if not _save_campaign():
		run.restore_state(previous)
		run.sample_session(Time.get_ticks_usec())
		_sync()
		return
	archer.play_cue("buy")
	_set_view("end")


func _redraw_world() -> void:
	clearing.set_stage(run.stage)
	clearing.set_workshop(run.workshop)
	archer.set_bow(run.bow)
	_sync_piles()


func _sync_piles() -> void:
	clearing.set_piles(run.workshop_stock, run.knot_stock)
	_sync()


func _sync() -> void:
	hud_wait = 0.1
	archer.set_has_arrows(run.arrows > 0)
	archer.set_speed_multiplier(run.speed_multiplier())
	var state := run.snapshot()
	state.has_save = has_save
	clearing.sync_encounter(state)
	hud.refresh(state)


func _save_campaign() -> bool:
	if not campaign_started:
		return false
	run.sample_session(Time.get_ticks_usec())
	var data := {"run": run.save_state(), "pose": archer.save_pose(),
		"shot_wait": shot_wait, "branch_wait": branch_wait, "recovery_wait": recovery_wait,
		"break_wait": break_wait, "in_flight": in_flight.duplicate(true)}
	if not SaveData.store_campaign(data):
		hud.notify("No se pudo guardar. Probá de nuevo desde pausa.", "Could not save. Try again from pause.")
		return false
	if not has_save:
		has_save = true
		hud.set_can_continue(true)
	return true


func _manual_save() -> void:
	if _save_campaign():
		hud.notify("Partida guardada", "Game saved")


func _resume_campaign() -> void:
	var data := SaveData.load_campaign()
	var restored := Run.new()
	if not data.has_all(["run", "pose", "shot_wait", "branch_wait", "recovery_wait", "break_wait", "in_flight"]) or not restored.restore_state(data.run):
		hud.notify("No se pudo leer la partida.", "Could not read the saved game.")
		return
	run = restored
	campaign_started = true
	run.sample_session(Time.get_ticks_usec())
	shot_wait = data.shot_wait
	branch_wait = data.branch_wait
	recovery_wait = data.recovery_wait
	break_wait = data.break_wait
	in_flight = data.in_flight
	archer.restore_pose(data.pose)
	for flight: Dictionary in in_flight:
		archer.restore_flight(flight.origin, flight.end, flight.duration, flight.remaining)
	_redraw_world()
	if not run.gift_offer.is_empty() or not run.chosen_gift.is_empty():
		_resume_play()
	else:
		_set_view("pause")


func _restart() -> void:
	get_tree().set_meta("archer_replay", true)
	get_tree().paused = false
	get_tree().call_deferred("reload_current_scene")


func _quit() -> void:
	if campaign_started and not _save_campaign():
		return
	get_tree().quit()
