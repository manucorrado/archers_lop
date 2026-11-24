extends Node3D

const Run = preload("res://scripts/run.gd")
const Clearing = preload("res://scripts/clearing.gd")
const Archer = preload("res://scripts/archer.gd")
const Interface = preload("res://scripts/interface.gd")
const SaveData = preload("res://scripts/save_data.gd")
const BriznoDialogue := preload("res://scripts/brizno_dialogue.gd")
const FirstSteps = preload("res://scripts/first_steps.gd")
const RunLog = preload("res://scripts/run_log.gd")
const BOWS := ["branch", "recurve", "longbow"]
const VOLLEY_ANGLES := [0.0, -0.035, 0.035]
const RAIN_OFFSETS := [Vector2(-1.2, 2.0), Vector2(1.1, 2.6), Vector2(-0.3, 3.4)]
const SUPPLY_JUMP_REACH := 8.0

var run := Run.new()
var clearing := Clearing.new()
var archer := Archer.new()
var hud := Interface.new()
var dialogue := BriznoDialogue.new()
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
var trail_marker := FirstSteps.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_window().min_size = Vector2i(800, 450)
	clearing.process_mode = Node.PROCESS_MODE_PAUSABLE
	archer.process_mode = Node.PROCESS_MODE_PAUSABLE
	archer.position = Vector3(0, 0, 5)
	add_child(clearing)
	add_child(archer)
	add_child(hud)
	add_child(dialogue)
	dialogue.advance_requested.connect(_advance_dialogue)
	dialogue.leave_requested.connect(_leave_dialogue)
	trail_marker.camera = archer.camera
	hud.layer_root.add_child(trail_marker)
	archer.shot_requested.connect(func(): wants_shot = true)
	archer.branch_requested.connect(func(): wants_branch = true)
	hud.start_requested.connect(_start_campaign)
	hud.continue_requested.connect(_resume_campaign)
	hud.next_act_requested.connect(_continue_act)
	hud.save_requested.connect(_manual_save)
	hud.resume_requested.connect(_resume_play)
	hud.restart_requested.connect(_restart)
	hud.quit_requested.connect(_quit)
	hud.buy_requested.connect(_change_upgrade.bind(false))
	hud.refund_requested.connect(_change_upgrade.bind(true))
	hud.gift_requested.connect(_choose_gift)
	hud.equip_requested.connect(_equip)
	hud.settings_changed.connect(_apply_settings)
	hud.audio_preview_requested.connect(archer.preview_sound)
	get_tree().auto_accept_quit = false
	get_window().close_requested.connect(_quit)
	get_window().focus_exited.connect(_focus_lost)
	get_window().focus_entered.connect(_focus_returned)
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
	if run.at_act_summary():
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
	archer.set_active(view == "play", view != "dialogue")
	_sync()
	hud.set_view(view)
	if view == "dialogue":
		dialogue.display(hud.language, hud.preferences.binding_name("shop"), hud.preferences.binding_name("pause"))
	else:
		dialogue.hide()
	if view == "end" and run.at_act_summary():
		if not SaveData.update_best_times(RunLog.splits(run.observations)):
			hud.notify("No se pudo guardar el récord local.", "Could not save the local best time.")


func _focus_lost() -> void:
	if campaign_started:
		run.set_session_focus(false, Time.get_ticks_usec())
	if view == "play":
		_set_view("pause")


func _focus_returned() -> void:
	if campaign_started:
		run.set_session_focus(true, Time.get_ticks_usec())


func _input(event: InputEvent) -> void:
	if event.is_echo() or not hud.is_node_ready() or hud.is_submenu_open():
		return
	if view == "play" and event.is_action_pressed("shop") and clearing.sentinel.is_within_reach(archer.position):
		get_viewport().set_input_as_handled()
		_load_sentinel()
		return
	if view == "dialogue":
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and get_viewport().gui_get_hovered_control() is Button:
			return
		if event.is_action_pressed("pause"):
			get_viewport().set_input_as_handled()
			_leave_dialogue()
		elif event.is_action_pressed("shop"):
			get_viewport().set_input_as_handled()
			_advance_dialogue()
		return
	if event.is_action_pressed("pause") and view in ["play", "shop", "gift", "pause"]:
		get_viewport().set_input_as_handled()
		if view == "play" or view == "gift":
			_set_view("pause")
		else:
			_resume_play()
	elif event.is_action_pressed("shop") and view in ["play", "shop"]:
		get_viewport().set_input_as_handled()
		if view == "shop":
			_set_view("play")
		elif clearing.is_near_dog(archer.position):
			_set_view("shop")
		elif clearing.is_near_brizno(archer.position):
			if dialogue.begin(run.stage, run.workshop, run.split):
				_set_view("dialogue")
				_save_campaign()
		else:
			hud.notify("Acercate a Pipo, bajo el pino de la izquierda.", "Walk up to Pipo under the pine on the left.")
	elif view == "play":
		if event.is_action_pressed("pet_dog") and run.rank_of("pet") > 0 and clearing.is_near_dog(archer.position):
			get_viewport().set_input_as_handled()
			clearing.pet_dog()
			return
		var selected := ""
		if event.is_action_pressed("bow_1"):
			selected = "branch"
		elif event.is_action_pressed("bow_2"):
			selected = "recurve"
		elif event.is_action_pressed("bow_3"):
			selected = "longbow"
		elif event.is_action_pressed("bow_previous") or event.is_action_pressed("bow_next"):
			var step := 1 if event.is_action_pressed("bow_next") else -1
			for distance in range(1, BOWS.size() + 1):
				var candidate: String = BOWS[posmod(BOWS.find(run.bow) + step * distance, BOWS.size())]
				if candidate == "branch" or run.rank_of(candidate) > 0:
					selected = candidate
					break
		if not selected.is_empty():
			get_viewport().set_input_as_handled()
			_equip(selected)


func _equip(id: String) -> void:
	if view in ["shop", "play"] and run.equip(id):
		archer.set_bow(run.bow)
		_sync()


func _advance_dialogue() -> void:
	if view != "dialogue":
		return
	if dialogue.advance():
		dialogue.display(hud.language, hud.preferences.binding_name("shop"), hud.preferences.binding_name("pause"))
		_save_campaign()
	else:
		_leave_dialogue()


func _leave_dialogue() -> void:
	if view == "dialogue":
		_resume_play()
		_save_campaign()


func _physics_process(delta: float) -> void:
	if view != "play":
		return
	archer.set_supply_jump_destination(_supply_jump_target() if run.rank_of("leap") > 0 else null)
	run.sample_session(Time.get_ticks_usec())
	var old_target := run.target_serial
	var old_rain := run.event_serial
	var old_stock := run.workshop_stock
	run.tick(delta)
	shot_wait = maxf(0.0, shot_wait - delta)
	branch_wait = maxf(0.0, branch_wait - delta)
	recovery_wait = maxf(0.0, recovery_wait - delta)
	_tick_flights(delta)
	_tick_sentinel(delta)
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
	run.begin_volley()
	var count := mini(run.arrows, run.volley_size())
	for index in count:
		run.note_shot()
		var angle: float = VOLLEY_ANGLES[index]
		var ray := archer.aim_hit(50.0, angle)
		var endpoint: Vector3 = ray.get("position", archer.camera.global_position + archer.shot_direction(angle) * 50.0)
		var id := clearing.target_id(ray.get("collider"), endpoint)
		var duration := archer.flight_duration(endpoint)
		var arrow := {"stage": run.stage, "id": id, "origin": archer.arrow_origin(),
			"end": endpoint, "duration": duration, "remaining": duration, "damage": run.volley_damage(),
			"weak_damage": run.volley_damage(true), "critical": run.volley_critical,
			"serial": run.event_serial if id.begins_with("seed_") else run.target_serial}
		in_flight.append(arrow)
		if run.rank_of("rain") > 0:
			_call_arrow_rain(arrow)
		if index == 0:
			archer.play_shot(endpoint)
		else:
			archer.play_extra_arrow(endpoint)
	_sync()


func _call_arrow_rain(arrow: Dictionary) -> void:
	var start: Vector3 = arrow.origin.lerp(arrow.end, 0.55)
	for i in RAIN_OFFSETS.size():
		var offset: Vector2 = RAIN_OFFSETS[i]
		var origin := start + archer.camera.global_basis.x * offset.x + Vector3.UP * offset.y
		var duration := clampf(origin.distance_to(arrow.end) / 36.0, 0.13, 0.4)
		in_flight.append({"source": "rain", "stage": arrow.stage, "id": arrow.id, "origin": origin,
			"end": arrow.end, "damage": arrow.damage, "duration": duration,
			"remaining": duration + float(arrow.duration) + i * 0.055})


func _tick_flights(delta: float) -> void:
	var pending := []
	var rain_hits: Array[Dictionary] = []
	for flight: Dictionary in in_flight:
		flight.remaining -= delta
		if flight.remaining > 0:
			pending.append(flight)
		elif flight.stage == run.stage and run.hp > 0:
			if flight.get("source") == "rain":
				rain_hits.append(flight)
			else:
				_land_shot(flight)
	in_flight = pending
	archer.draw_arrow_rain(in_flight)
	if not rain_hits.is_empty() and run.hp > 0:
		_land_arrow_rain(rain_hits)


func _land_arrow_rain(hits: Array[Dictionary]) -> void:
	var milestone := _boss_milestone()
	var balance := run.sap
	var damage := 0
	for hit in hits:
		# Wood damage only. Collecting a bullseye and unlocking a hollow require the player's arrow.
		damage += run.damage_part(hit.damage, hit.id, false, "bow")
		if run.hp == 0:
			break
	if damage > 0:
		hud.show_damage(damage)
		hud.show_sap_earned(run.sap - balance)
		if run.hp == 0 or milestone != _boss_milestone():
			_after_damage(milestone, false)


func _land_shot(flight: Dictionary) -> void:
	var milestone := _boss_milestone()
	var balance := run.sap
	if flight.get("source", "") == "sentinel":
		var effective := run.damage_part(flight.damage, flight.id, false, "sentinel")
		if effective > 0:
			hud.show_sap_earned(run.sap - balance)
			hud.show_damage(effective, "sentinel")
			clearing.hit_feedback(flight.end)
			_after_damage(milestone, false)
		return
	var outcome := run.manual_impact(flight.id, flight.damage, flight.weak_damage, flight.serial)
	if not outcome.hit:
		archer.play_cue("miss")
		return
	hud.hit_marker()
	hud.show_sap_earned(run.sap - balance)
	clearing.hit_feedback(flight.end)
	if outcome.direct > 0:
		var source := "critical" if flight.get("critical", false) else ("weak" if outcome.weak_spot else "manual")
		hud.show_damage(outcome.direct, source)
	if outcome.spark > 0:
		clearing.play_spark(clearing.target_center(outcome.spark_target))
		hud.show_damage(outcome.spark, "spark")
	if outcome.arrows_returned > 0:
		hud.notify("Diana · +%d al carcaj" % outcome.arrows_returned, "Bullseye · +%d to quiver" % outcome.arrows_returned)
	archer.play_cue("hit" if flight.id.begins_with("seed_") else "arrow_impact")
	_after_damage(milestone, false)


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
	var balance := run.sap
	var damage := run.strike_part(roundi(4 * Run.POWER[run.stage - 1]), id)
	hud.show_sap_earned(run.sap - balance)
	hud.show_damage(damage, "branch")
	clearing.hit_feedback(point)
	hud.hit_marker()
	_after_damage(milestone)


func _boss_milestone() -> int:
	if run.stage == 10:
		return run.core_phase * 3 + (1 if run.core_hit else 2 if run.core_needs_hit() else 0)
	if not run.split:
		return 0
	return 2 if run.left_hp == 0 or run.right_hp == 0 else 1


func _after_damage(previous_milestone: int, personal_hit := true) -> void:
	var milestone := _boss_milestone()
	if run.hp == 0:
		break_wait = 0.65
		archer.play_cue("break")
		clearing.break_feedback()
	else:
		if personal_hit:
			archer.play_cue("hit")
		if run.core_needs_hit() and milestone != previous_milestone:
			hud.notify("¡Falta el punto encendido! Disparale o golpeá su raíz con la rama.",
				"Hit the glowing hollow, or strike its root with your branch.")
		elif run.stage == 10 and floori(milestone / 3.0) != floori(previous_milestone / 3.0):
			clearing.play_encounter_cue("core_%d" % run.core_phase)
			hud.notify("El punto débil cambió de lugar. Buscá el hueco encendido.",
				"The weak spot moved. Look for the glowing hollow.")
		elif run.stage == 5 and milestone == 1 and previous_milestone == 0:
			hud.notify("¡Se partió! Disparale a cada mitad hasta romper las dos.",
				"It split! Shoot each side until both break.")
		elif run.stage == 5 and milestone == 2 and previous_milestone == 1:
			hud.notify("Una mitad cayó. Apuntá a la que sigue en pie.",
				"One half fell. Aim at the one still standing.")
	_sync_piles()
	if run.hp == 0 or previous_milestone != milestone:
		# Record the complete step including the other arrows landing on this tick.
		checkpoint_due = true


func _next_knot() -> void:
	if run.stage == Run.HEALTH.size():
		archer.play_cue("win")
		_set_view("end")
		checkpoint_due = true
		return
	if run.stage in Run.GIFT_STAGES:
		run.prepare_gifts()
		archer.play_cue("win")
		_set_view("gift")
		checkpoint_due = true
		return
	if not run.next_knot():
		return
	clearing.set_stage(run.stage)
	match run.stage:
		2: hud.notify("Apuntá al punto débil para hacer más daño y ganar más savia.",
			"Aim for the weak spot to deal more damage and earn more sap.")
		5: hud.notify("Quinto blanco · Tronco partido", "Fifth target · Twin Fork")
		10: hud.notify("Décimo blanco · Apuntá al hueco encendido. El punto débil cambia de lugar.",
			"Tenth target · Aim at the glowing hollow. The weak spot moves.")
		15: hud.notify("Blanco 15 · Al romperlo, elegís otra carta.", "Target 15 · Break it to choose another card.")
		20: hud.notify("Último blanco del claro", "Final target in the clearing")
	_sync_piles()
	checkpoint_due = true


func _continue_act() -> void:
	if view != "end" or run.stage >= Run.HEALTH.size() or not run.at_act_summary():
		return
	run.sample_session(Time.get_ticks_usec())
	var previous := run.save_state()
	if not run.next_knot():
		return
	if not _save_campaign():
		run.restore_state(previous)
		return
	_redraw_world()
	_set_view("play")
	match run.stage:
		6: hud.notify("Segundo acto · Acertale a la diana temporal con el arco para recuperar hasta 3 flechas.",
			"Second act · Hit a timed bullseye with your bow to recover up to 3 arrows.")
		11: hud.notify("Tercer acto · Blanco 11", "Third act · Target 11")
		16: hud.notify("Cuarto acto · Blanco 16", "Fourth act · Target 16")


func _collect_nearby() -> bool:
	var pos := Vector2(archer.position.x, archer.position.z)
	var radius := run.pickup_radius()
	var total := 0
	var landed_nearby: Array[int] = []
	for slot in run.workshop_piles.size():
		var landing: Vector3 = Clearing.WORKSHOP_LANDINGS[slot]
		if pos.distance_to(Vector2(landing.x, landing.z)) <= radius:
			landed_nearby.append(slot)
	run.observe_workshop_visit(not landed_nearby.is_empty())
	for slot in landed_nearby:
		total += run.collect(true, slot)
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


func _ground_supplies() -> Dictionary:
	var piles := {}
	for index in run.workshop_piles.size():
		if run.workshop_piles[index] > 0:
			piles[str(index)] = Clearing.WORKSHOP_LANDINGS[index]
	if run.knot_stock > 0:
		piles["knot"] = Clearing.KNOT_PICKUP
	for id: String in run.seed_drops:
		if run.seed_drops[id] > 0:
			piles[id] = clearing.seed_drop_position(id)
	return piles


func _supply_jump_target() -> Variant:
	var eye := archer.camera.global_position
	var forward := -archer.camera.global_basis.z
	var bearing := Vector2(forward.x, forward.z).angle()
	var pitch := asin(clampf(forward.y, -1, 1))
	var best_score := INF
	var destination: Variant = null
	for point: Vector3 in _ground_supplies().values():
		var offset := point + Vector3.UP * 0.3 - eye
		var horizontal := Vector2(offset.x, offset.z)
		var distance := horizontal.length()
		if distance <= 0.6 or distance > SUPPLY_JUMP_REACH:
			continue
		var turn := absf(angle_difference(bearing, horizontal.angle()))
		var elevation := atan2(offset.y, distance)
		if turn > deg_to_rad(18.0) or pitch > deg_to_rad(15.0) or pitch < elevation - deg_to_rad(18.0):
			continue
		var score := turn + 0.25 * absf(pitch - elevation)
		if score < best_score:
			var sight := PhysicsRayQueryParameters3D.create(eye, eye + offset)
			sight.exclude = [archer.get_rid()]
			if archer.get_world_3d().direct_space_state.intersect_ray(sight).is_empty():
				best_score = score
				destination = point
	return destination


func _change_upgrade(id: String, refund: bool) -> void:
	if view != "shop":
		return
	run.sample_session(Time.get_ticks_usec())
	var previous := run.save_state()
	var changed := run.refund(id) if refund else run.buy(id)
	if not changed:
		return
	if not _save_campaign():
		run.restore_state(previous)
		run.sample_session(Time.get_ticks_usec())
		_sync()
		return
	if id == "workshop":
		clearing.set_workshop(run.workshop)
	if id == Run.Paths.SENTINEL_NODE and refund:
		clearing.set_piles(0, run.knot_stock)
	archer.set_bow(run.bow)
	archer.play_cue("buy")
	_sync()
	if not refund:
		match id:
			"combo":
				hud.notify("Combo desbloqueado · Encadená aciertos para ganar savia extra.",
					"Combo unlocked · Chain hits to earn extra sap.")
			"rain":
				hud.notify("Lluvia de flechas desbloqueada · Cada flecha llama tres más desde arriba.",
					"Arrow rain unlocked · Each arrow calls three more from above.")
			"damage":
				if run.volley_size() == 3:
					hud.notify("Disparo triple desbloqueado · Soltá hasta tres flechas del carcaj por tiro.",
						"Triple shot unlocked · Release up to three quiver arrows per shot.")


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
	clearing.set_piles(0, run.knot_stock)
	_sync()


func _sync() -> void:
	hud_wait = 0.1
	archer.set_has_arrows(run.arrows > 0)
	archer.set_speed_multiplier(run.speed_multiplier())
	var state := run.snapshot()
	state.rain_falling = in_flight.any(func(arrow: Dictionary) -> bool: return arrow.get("source") == "rain")
	state.near_dog = clearing.is_near_dog(archer.position)
	state.near_brizno = clearing.is_near_brizno(archer.position)
	state.has_save = has_save
	var target := run.sentinel_target()
	clearing.sentinel.sync_state(state.sentinel_owned, run.sentinel_ammo, not target.is_empty(), clearing.target_center(target))
	state.near_sentinel = clearing.sentinel.is_within_reach(archer.position)
	state.learning_supplies = run.elapsed < run.supply_hints.LEARNING_TIME
	state.early_pickup_glow = hud.options.first_steps and not run.fired_after_collect and state.learning_supplies
	clearing.sync_encounter(state)
	hud.refresh(state)
	var piles := _ground_supplies()
	var needs_supply := run.arrows < run.capacity()
	if state.learning_supplies and run.collected > 0:
		needs_supply = run.arrows <= run.capacity() * 0.5
	var pile := run.supply_hints.choose(piles, archer.position, run.elapsed,
			view == "play" and hud.options.first_steps, needs_supply)
	var supply: Variant = null if pile.is_empty() else piles[pile] + Vector3.UP * 0.35
	trail_marker.update_targets(view == "play", supply, state.near_dog, hud.language,
			hud.preferences.binding_name("shop"), hud.preferences.binding_name("pet_dog") if run.rank_of("pet") > 0 else "")


func _save_campaign() -> bool:
	if not campaign_started:
		return false
	run.sample_session(Time.get_ticks_usec())
	var data := {"run": run.save_state(), "pose": archer.save_pose(), "brizno": dialogue.bookmark(),
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
	var story: Variant = data.get("brizno", {})
	dialogue.restore(story)
	for flight: Dictionary in in_flight:
		if flight.get("source") != "rain":
			archer.restore_flight(flight.origin, flight.end, flight.duration, flight.remaining)
	archer.draw_arrow_rain(in_flight)
	_redraw_world()
	if not run.gift_offer.is_empty() or run.at_act_summary():
		_resume_play()
	elif story is Dictionary and story.get("open") == true and not dialogue.topic.is_empty() and clearing.is_near_brizno(archer.position):
		_set_view("dialogue")
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


func _load_sentinel() -> void:
	if run.sentinel_load_size() == 0:
		if run.sentinel_ammo == Run.SENTINEL_CAPACITY:
			hud.notify("El depósito de la ballesta está lleno.", "The crossbow magazine is full.")
		else:
			hud.notify("Reservás cuatro flechas. Recogé más para cargar la ballesta.", "You keep four arrows. Gather more to load the crossbow.")
		return
	var previous := run.save_state()
	var amount := run.load_sentinel()
	if not _save_campaign():
		run.restore_state(previous)
		return
	clearing.sentinel.receive()
	_sync()
	hud.notify("Cargaste %d flechas en la ballesta." % amount if amount != 1 else "Cargaste una flecha en la ballesta.",
		"Loaded %d arrows into the crossbow." % amount if amount != 1 else "Loaded one arrow into the crossbow.")


func _tick_sentinel(delta: float) -> void:
	var id := run.tick_sentinel(delta)
	if id.is_empty():
		return
	var endpoint := clearing.target_center(id)
	var origin := clearing.sentinel.release(endpoint, run.sentinel_ammo == 0)
	var duration := maxf(0.07, origin.distance_to(endpoint) / 28.0)
	in_flight.append({"source": "sentinel", "stage": run.stage, "id": id, "origin": origin,
		"end": endpoint, "duration": duration, "remaining": duration, "damage": roundi(8.0 * Run.POWER[run.stage - 1])})
	archer.restore_flight(origin, endpoint, duration, duration)
	_sync()
