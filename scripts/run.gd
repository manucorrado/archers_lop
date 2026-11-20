extends RefCounted
## Reglas y estado del primer acto. Todos los relojes reciben solo tiempo jugado.

const HEALTH := [160, 821, 2079, 5057, 19430]
const SAP_BUDGET := [20, 30, 45, 67, 101]
const POWER := [1.0, 1.52, 2.3104, 3.511808, 5.33794816]
const SHOT_INTERVAL := 1.0
const PICKUP_RADIUS := 1.5
const WORKSHOP_RATE := 1.5
const TREE := {
	"damage": [[1, 3], 20, ""], "rate": [[2], 45, "damage"],
	"weak": [[2], 45, "damage"], "recurve": [[4], 55, "damage"],
	"workshop": [[2], 55, ""], "capacity": [[1, 4], 35, ""],
	"wheel": [[3], 45, "workshop"], "pickup": [[2], 35, "capacity"],
	"pace": [[4], 30, "capacity"], "spark": [[3], 40, "damage"],
}
# El corte usa un subconjunto de la bolsa que permite comparar carreras.
const FIRST_GIFTS := ["D01", "D04", "D08", "D09", "D14"]
const SAVE_FIELDS := [
	"stage", "hp", "sap", "arrows", "ranks", "bow", "elapsed", "shots", "hits",
	"collected", "workshop_stock", "workshop_fraction", "knot_stock", "seed_drops",
	"split", "left_hp", "right_hp", "combo", "max_combo", "combo_grace", "bonus_fraction",
	"spark_hits", "run_seed", "draw_counter", "target_active", "target_side",
	"target_serial", "target_clock", "seen_target", "event_clock", "event_remaining",
	"seeds", "event_serial", "gift_offer", "chosen_gift", "fired_after_collect", "observations",
]

var stage := 1
var hp := 160
var sap := 0
var arrows := 24
var ranks: Dictionary = {}
var bow := "branch"
var damage_rank: int:
	get: return rank_of("damage")
var capacity_rank: int:
	get: return rank_of("capacity")
var workshop: bool:
	get: return rank_of("workshop") > 0
var workshop_stock := 0
var knot_stock := 0
var workshop_fraction := 0.0
var elapsed := 0.0
var shots := 0
var hits := 0
var collected := 0
var fired_after_collect := false
var split := false
var left_hp := 0
var right_hp := 0
var combo := 1.0
var max_combo := 1.0
var combo_grace := 0.0
var bonus_fraction := 0.0
var spark_hits := 0
var run_seed: int = randi()
var draw_counter := 0
var target_active := false
var target_side := 0
var target_serial := 0
var target_clock := 1.5
var seen_target := false
var event_clock := 8.0
var event_remaining := 0.0
var event_serial := 0
var seeds: Array = []
var seed_drops: Dictionary = {}
var gift_offer: Array = []
var chosen_gift := ""
var observations: Dictionary = {}
var session_observations: Dictionary = {}
var session_elapsed_us := 0
var _previous_sample_us := -1
var _at_workshop := false


func sample_session(monotonic_us: int) -> void:
	# The monotonic origin belongs to this process. Only its accumulated intervals
	# go on disk. Earlier checkpoints without this clock have no observed total.
	if session_elapsed_us >= 0 and _previous_sample_us >= 0 and chosen_gift.is_empty():
		session_elapsed_us += maxi(0, monotonic_us - _previous_sample_us)
	_previous_sample_us = monotonic_us


func mark(event: String) -> void:
	if not observations.has(event):
		observations[event] = elapsed
		if session_elapsed_us >= 0 and _previous_sample_us >= 0:
			session_observations[event] = session_elapsed_us / 1000000.0


func rank_of(id: String) -> int:
	return int(ranks.get(id, 0))


func max_hp() -> int:
	return HEALTH[stage - 1]


func damage(weak_spot := false) -> int:
	var base := 11.0 if bow == "recurve" else 10.0
	base *= (1.0 + 0.2 * damage_rank) * POWER[stage - 1]
	if chosen_gift == "D04":
		base *= 1.2
	if weak_spot:
		base *= 1.5 + 0.25 * rank_of("weak")
	return roundi(base)


func shot_interval() -> float:
	var rate := 2.5 if bow == "recurve" else 1.0
	rate *= 1.0 + 0.12 * rank_of("rate")
	if chosen_gift == "D01":
		rate *= 1.5
	return 1.0 / rate


func capacity() -> int:
	return 24 + 16 * capacity_rank + (24 if chosen_gift == "D08" else 0)


func pickup_radius() -> float:
	return PICKUP_RADIUS + 0.75 * rank_of("pickup") + (2.0 if chosen_gift == "D09" else 0.0)


func production_rate() -> float:
	return WORKSHOP_RATE * (1.0 + 0.2 * rank_of("wheel")) * (1.3 if chosen_gift == "D03" else 1.0)


func speed_multiplier() -> float:
	return 1.0 + (0.06 * rank_of("pace") if arrows >= 4 else 0.0)


func combo_delay() -> float:
	return 4.5 if chosen_gift == "D14" else 2.5


func _rank_value(id: String, rank: int) -> float:
	match id:
		"damage": return 10 + 2 * rank
		"rate": return 12 * rank
		"weak": return 1.5 + 0.25 * rank
		"recurve": return 1.0 if rank == 0 else 2.5
		"workshop": return WORKSHOP_RATE * rank * (1.0 + 0.2 * rank_of("wheel"))
		"capacity": return 24 + 16 * rank
		"wheel": return WORKSHOP_RATE * (1.0 + 0.2 * rank)
		"pickup": return PICKUP_RADIUS + 0.75 * rank
		"pace": return 6 * rank
		"spark": return 20 * rank
	return 0.0


func offers() -> Dictionary:
	var result := {}
	for id: String in TREE:
		var rule: Array = TREE[id]
		var gates: Array = rule[0]
		var rank := rank_of(id)
		var maxed := rank >= gates.size()
		var gate: int = gates[mini(rank, gates.size() - 1)]
		var cost := ceili(SAP_BUDGET[gate - 1] * float(rule[1]) / 100.0)
		var req: String = rule[2]
		var allowed := req.is_empty() or rank_of(req) > 0
		result[id] = {"stage": gate, "cost": cost, "rank": rank, "max_rank": gates.size(),
			"requires": req, "requirement_met": allowed, "maxed": maxed, "owned": rank > 0,
			"available": not maxed and allowed and stage >= gate and sap >= cost,
			"current": _rank_value(id, rank), "next": _rank_value(id, mini(rank + 1, gates.size()))}
	return result


func buy(id: String) -> bool:
	var options := offers()
	if not options.has(id) or not options[id].available:
		return false
	sap -= int(options[id].cost)
	ranks[id] = rank_of(id) + 1
	mark("first_purchase")
	mark("buy_" + id)
	if id == "recurve":
		equip("recurve")
	return true


func equip(id: String) -> bool:
	if id != "branch" and (id != "recurve" or rank_of("recurve") == 0):
		return false
	bow = id
	return true


func note_shot() -> void:
	shots += 1
	arrows -= 1
	if collected > 0:
		fired_after_collect = true
		mark("fired_after_collection")


func lobe_limit(left: bool) -> int:
	var remainder := max_hp() - floori(max_hp() * 0.5)
	var left_share := floori(remainder * 0.5)
	return left_share if left else remainder - left_share


func _begin_split() -> void:
	split = true
	left_hp = lobe_limit(true)
	right_hp = lobe_limit(false)
	mark("boss_split")


func vulnerability(id: String) -> int:
	if split:
		match id:
			"left": return left_hp
			"right": return right_hp
		return 0
	if id not in ["body", "target"]:
		return 0
	if stage == 5:
		return hp - lobe_limit(true) - lobe_limit(false)
	return hp


func _add_combo(opportunity: bool) -> void:
	combo = minf(6.0, combo + (0.25 if opportunity else 0.05))
	max_combo = maxf(max_combo, combo)
	combo_grace = combo_delay()


func damage_part(amount: int, id: String, manual := false) -> int:
	var effective := mini(amount, vulnerability(id))
	if effective <= 0:
		return 0
	var budget: int = SAP_BUDGET[stage - 1]
	var hit_budget := floori(budget * 0.6)
	var before := floori(float(hit_budget * (max_hp() - hp)) / max_hp())
	hp -= effective
	if split:
		if id == "left":
			left_hp -= effective
		else:
			right_hp -= effective
		if hp > 0 and (left_hp == 0 or right_hp == 0):
			mark("first_lobe_broken")
	var after := floori(float(hit_budget * (max_hp() - hp)) / max_hp())
	sap += after - before
	if manual:
		bonus_fraction += float(hit_budget * effective) / max_hp() * 0.1 * (combo - 1.0)
		var whole := floori(bonus_fraction)
		sap += whole
		bonus_fraction -= whole
	if stage == 5 and not split and hp == lobe_limit(true) + lobe_limit(false):
		_begin_split()
	if hp == 0:
		sap += budget - hit_budget
		knot_stock += 8
		mark("broke_" + str(stage))
	return effective


func apply_damage(amount: int) -> void:
	damage_part(amount, "body")


func manual_impact(id: String, shot_damage: int, weak_damage: int, serial: int) -> Dictionary:
	var result := {"hit": false, "direct": 0, "spark": 0, "spark_target": ""}
	var weak_spot := id == "target" and target_active and serial == target_serial
	var seed_hit := false
	if id.begins_with("seed_"):
		if serial != event_serial:
			return result
		for i in seeds.size():
			if seeds[i].id == id:
				seeds.remove_at(i)
				seed_drops[id] = int(seed_drops.get(id, 0)) + 4
				seed_hit = true
				break
		if not seed_hit:
			return result
	elif vulnerability(id) <= 0:
		return result
	if weak_spot:
		target_active = false
		target_clock = _draw(15.0, 25.0)
		mark("first_target_hit")
	_add_combo(weak_spot or seed_hit)
	hits += 1
	mark("first_hit")
	result.hit = true
	if not seed_hit:
		result.direct = damage_part(weak_damage if weak_spot else shot_damage, id, true)
	if rank_of("spark") > 0:
		spark_hits += 1
		if spark_hits >= 8:
			spark_hits = 0
			var spark_target := "body"
			if split:
				if id in ["left", "right"] and vulnerability(id) > 0:
					spark_target = id
				else:
					spark_target = "left" if left_hp > 0 else "right"
			result.spark = damage_part(roundi(20.0 * POWER[stage - 1]), spark_target)
			if result.spark > 0:
				result.spark_target = spark_target
				mark("first_spark")
	return result


func next_knot() -> bool:
	if hp > 0 or stage >= 5:
		return false
	stage += 1
	hp = max_hp()
	target_active = false
	target_clock = 1.5 if not seen_target else _draw(15.0, 25.0)
	if stage == 5:
		seeds.clear()
		event_remaining = 0.0
	return true


func _draw(minimum: float, maximum: float) -> float:
	# A cada sorteo le corresponde un índice persistido, independiente del render.
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed + 2654435761 * draw_counter
	draw_counter += 1
	return rng.randf_range(minimum, maximum)


func _offer_target() -> void:
	seen_target = true
	target_serial += 1
	target_side = mini(2, floori(_draw(0.0, 3.0)))
	target_active = true
	target_clock = 7.0


func _start_rain() -> void:
	event_serial += 1
	event_remaining = 9.0
	seeds.clear()
	for i in 3:
		seeds.append({"id": "seed_%d" % i, "remaining": event_remaining})
	mark("first_seed_rain")


func _opportunities(delta: float) -> void:
	if stage < 2 or stage >= 5:
		return
	if event_remaining > 0:
		event_remaining = maxf(0.0, event_remaining - delta)
		for seed_info: Dictionary in seeds:
			seed_info.remaining = event_remaining
		if event_remaining <= 0 or seeds.is_empty():
			seeds.clear()
			event_remaining = 0.0
			event_clock = _draw(45.0, 75.0)
		return
	if target_active:
		target_clock -= delta
		if target_clock <= 0:
			target_active = false
			target_clock = _draw(15.0, 25.0)
		return
	if seen_target and not ranks.is_empty():
		event_clock -= delta
		if event_clock <= 0:
			_start_rain()
			return
	target_clock -= delta
	if target_clock <= 0:
		_offer_target()


func tick(delta: float) -> void:
	elapsed += delta
	if workshop:
		workshop_fraction += delta * production_rate()
		var produced := floori(workshop_fraction)
		workshop_stock += produced
		workshop_fraction -= produced
	if hp > 0:
		var decay_delta := maxf(0.0, delta - combo_grace)
		combo_grace = maxf(0.0, combo_grace - delta)
		combo = maxf(1.0, combo - decay_delta * 0.5)
		_opportunities(delta)


func observe_workshop_visit(inside: bool) -> void:
	if inside and not _at_workshop and workshop and collected > 0 and arrows == 0:
		mark("returned_empty_to_workshop")
	_at_workshop = inside


func collect(from_workshop: bool) -> int:
	var stock := workshop_stock if from_workshop else knot_stock
	var transfer := mini(capacity() - arrows, stock)
	arrows += transfer
	if from_workshop:
		workshop_stock -= transfer
		if transfer > 0:
			collected += transfer
			mark("first_production_pickup")
	else:
		knot_stock -= transfer
	return transfer


func collect_seeds(id: String) -> int:
	var stock := int(seed_drops.get(id, 0))
	var transfer := mini(capacity() - arrows, stock)
	arrows += transfer
	if stock == transfer:
		seed_drops.erase(id)
	else:
		seed_drops[id] = stock - transfer
	return transfer


func prepare_gifts() -> void:
	if stage != 5 or hp > 0 or not gift_offer.is_empty() or not chosen_gift.is_empty():
		return
	var pool := FIRST_GIFTS.duplicate()
	if workshop:
		pool.append("D03")
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed
	while gift_offer.size() < 3:
		gift_offer.append(pool.pop_at(rng.randi_range(0, pool.size() - 1)))


func choose_gift(id: String) -> bool:
	if not chosen_gift.is_empty() or not gift_offer.has(id):
		return false
	chosen_gift = id
	gift_offer.clear()
	mark("chosen_gift")
	return true


func save_state() -> Dictionary:
	var data := {"session_elapsed_us": session_elapsed_us,
		"session_observations": session_observations, "at_workshop": _at_workshop}
	for field: String in SAVE_FIELDS:
		data[field] = get(field)
	return data.duplicate(true)


func restore_state(data: Dictionary) -> bool:
	if not data.has_all(SAVE_FIELDS):
		return false
	for field: String in SAVE_FIELDS:
		if typeof(data[field]) != typeof(get(field)):
			return false
	if data.stage < 1 or data.stage > HEALTH.size():
		return false
	if data.hp < 0 or data.hp > HEALTH[int(data.stage) - 1]:
		return false
	for field: String in SAVE_FIELDS:
		set(field, data[field])
	session_elapsed_us = int(data.get("session_elapsed_us", -1))
	session_observations = data.get("session_observations", {})
	_previous_sample_us = -1
	_at_workshop = bool(data.get("at_workshop", true))
	return true


func snapshot() -> Dictionary:
	return {"stage": stage, "hp": hp, "max_hp": max_hp(), "sap": sap, "arrows": arrows,
		"capacity": capacity(), "damage": damage(), "damage_rank": damage_rank,
		"shot_rate": 1.0 / shot_interval(), "production_rate": production_rate() if workshop else 0.0,
		"pickup_radius": pickup_radius(), "combo_delay": combo_delay(),
		"capacity_rank": capacity_rank, "workshop": workshop, "workshop_stock": workshop_stock,
		"knot_stock": knot_stock, "elapsed": elapsed, "shots": shots, "hits": hits,
		"collected": collected, "offers": offers(), "ranks": ranks, "bow": bow,
		"split": split, "left_hp": left_hp, "right_hp": right_hp,
		"left_max": lobe_limit(true), "right_max": lobe_limit(false),
		"combo": combo, "max_combo": max_combo, "combo_grace": combo_grace,
		"spark_hits": spark_hits, "target_active": target_active, "target_side": target_side,
		"seeds": seeds, "seed_drops": seed_drops, "event": "seed_rain" if event_remaining > 0 else "",
		"event_remaining": event_remaining, "gift_offer": gift_offer, "chosen_gift": chosen_gift,
		"fired_after_collect": fired_after_collect, "observations": observations,
		"session_observations": session_observations}
