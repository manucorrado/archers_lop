extends Node3D

const Run = preload("res://scripts/run.gd")
const Clearing = preload("res://scripts/clearing.gd")
const Archer = preload("res://scripts/archer.gd")
const Interface = preload("res://scripts/interface.gd")

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
var last_clock := -1


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
	hud.start_requested.connect(_set_view.bind("play"))
	hud.resume_requested.connect(_set_view.bind("play"))
	hud.shop_requested.connect(_set_view.bind("shop"))
	hud.restart_requested.connect(_restart)
	hud.quit_requested.connect(get_tree().quit)
	hud.buy_requested.connect(_buy)
	get_window().focus_exited.connect(_focus_lost)
	clearing.set_stage(1)
	clearing.set_workshop(false)
	clearing.set_piles(0, 0)
	_sync()
	var replay := get_tree().has_meta("archer_replay")
	if replay:
		get_tree().remove_meta("archer_replay")
	_set_view("play" if replay else "start")


func _set_view(next: String) -> void:
	view = next
	wants_shot = false
	wants_branch = false
	get_tree().paused = view != "play"
	archer.set_active(view == "play")
	hud.set_view(view)
	_sync()


func _focus_lost() -> void:
	if view == "play":
		_set_view("pause")


func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_TAB:
			if view == "play" or view == "shop":
				get_viewport().set_input_as_handled()
				_set_view("shop" if view == "play" else "play")
		KEY_ESCAPE:
			if view in ["play", "shop", "pause"]:
				get_viewport().set_input_as_handled()
				_set_view("pause" if view == "play" else "play")


func _physics_process(delta: float) -> void:
	if view != "play":
		return
	var old_stock := run.workshop_stock
	run.tick(delta)
	shot_wait = maxf(0.0, shot_wait - delta)
	branch_wait = maxf(0.0, branch_wait - delta)
	recovery_wait = maxf(0.0, recovery_wait - delta)
	if break_wait > 0:
		break_wait -= delta
		if break_wait <= 0:
			_next_knot()
	elif wants_branch and branch_wait <= 0:
		_strike()
	elif wants_shot and shot_wait <= 0:
		_shoot()
	wants_branch = false
	wants_shot = false
	if view != "play":
		return
	var collected := _collect_nearby()
	if collected or old_stock != run.workshop_stock:
		_sync_piles()
	elif last_clock != floori(run.elapsed):
		_sync()


func _shoot() -> void:
	if run.arrows == 0:
		shot_wait = 0.5
		archer.play_cue("empty")
		hud.notify("Sin flechas · Acercate a un haz o usá F junto al nudo.",
			"Out of arrows · Walk to a bundle or press F near the knot.")
		return
	shot_wait = Run.SHOT_INTERVAL
	run.arrows -= 1
	run.shots += 1
	var ray: Dictionary = archer.aim_hit()
	var end: Vector3 = ray.get("position", archer.camera.global_position - archer.camera.global_basis.z * 50.0)
	archer.play_shot(end, _land_shot.bind(run.stage, _is_knot(ray), run.damage(), end))
	_sync()


func _land_shot(stage_at_release: int, on_knot: bool, damage: int, point: Vector3) -> void:
	if run.stage != stage_at_release or run.hp <= 0:
		return
	if on_knot:
		run.hits += 1
		_hit(damage, point)
	else:
		archer.play_cue("miss")
	_sync()


func _is_knot(ray: Dictionary) -> bool:
	return not ray.is_empty() and ray.collider.is_in_group("knot")


func _strike() -> void:
	branch_wait = 1.0
	archer.play_branch()
	var ray: Dictionary = archer.aim_hit(3.0)
	if not _is_knot(ray):
		hud.notify("Acercate al nudo para golpearlo.", "Move closer to strike the knot.")
		return
	if run.arrows == 0 and recovery_wait <= 0:
		run.knot_stock += 4
		recovery_wait = 4.0
		hud.notify("Hay cuatro flechas al pie del nudo.", "Four arrows dropped at the foot of the knot.")
	_hit(roundi(4 * Run.POWER[run.stage - 1]), ray.position)
	_sync_piles()


func _hit(amount: int, point: Vector3) -> void:
	run.apply_damage(amount)
	clearing.hit_feedback(point)
	hud.hit_marker()
	if run.hp > 0:
		archer.play_cue("hit")
	else:
		break_wait = 0.65
		archer.play_cue("break")
		clearing.break_feedback()
		_sync_piles()


func _next_knot() -> void:
	if run.stage >= Run.HEALTH.size():
		archer.play_cue("win")
		_set_view("end")
		return
	run.stage += 1
	run.hp = run.max_hp()
	clearing.set_stage(run.stage)
	if run.stage == 2:
		hud.notify("Plano descubierto · Taller de flechas [Tab]", "Blueprint unlocked · Arrow workshop [Tab]")
	else:
		hud.notify("Último nudo · Nuevo rango de daño [Tab]", "Final knot · New damage rank [Tab]")
	_sync()


func _collect_nearby() -> bool:
	var pos := Vector2(archer.position.x, archer.position.z)
	var from_workshop := 0
	var from_knot := 0
	if run.workshop_stock > 0 and pos.distance_to(Vector2(Clearing.WORKSHOP_PICKUP.x, Clearing.WORKSHOP_PICKUP.z)) <= Run.PICKUP_RADIUS:
		from_workshop = run.collect(true)
	if run.knot_stock > 0 and pos.distance_to(Vector2(Clearing.KNOT_PICKUP.x, Clearing.KNOT_PICKUP.z)) <= Run.PICKUP_RADIUS:
		from_knot = run.collect(false)
	if from_workshop + from_knot == 0:
		return false
	archer.play_cue("pickup")
	var n := from_workshop + from_knot
	hud.notify("+%d flechas" % n, "+%d arrows" % n)
	return true


func _buy(id: String) -> void:
	if view != "shop" or not run.buy(id):
		return
	if id == "workshop":
		clearing.set_workshop(true)
	archer.play_cue("buy")
	_sync()


func _sync_piles() -> void:
	clearing.set_piles(run.workshop_stock, run.knot_stock)
	_sync()


func _sync() -> void:
	last_clock = floori(run.elapsed)
	archer.set_has_arrows(run.arrows > 0)
	hud.refresh(run.snapshot())


func _restart() -> void:
	get_tree().set_meta("archer_replay", true)
	get_tree().paused = false
	get_tree().call_deferred("reload_current_scene")
