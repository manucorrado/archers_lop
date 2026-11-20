extends RefCounted
## Reglas y estado de los dos primeros actos.

const HEALTH := [160, 821, 2079, 5057, 19430, 20446, 41932, 74796, 144178, 357311]
const SAP_BUDGET := [20, 30, 45, 67, 101, 151, 227, 341, 512, 768]
const POWER := [1.0, 1.52, 2.3104, 3.511808, 5.33794816, 8.1136812032, 12.332795428864,
	18.74584905187328, 28.49369055884739, 43.31040964944803]
const SHOT_INTERVAL := 1.0
const PICKUP_RADIUS := 1.5
const WORKSHOP_RATE := 1.25
const WORKSHOP_BATCH := 3
const WORKSHOP_FLIGHT := 0.8
const LANDING_COUNT := 4
const TREE := {
	"damage": [[1, 3, 3, 4, 5, 6, 7, 8, 9, 10], 20, ""],
	"rate": [[2, 3, 4, 5, 6, 7, 8, 9, 10, 10], 45, "damage"],
	"weak": [[2], 45, "damage"], "recurve": [[4], 55, "damage"],
	"workshop": [[2], 55, "damage"], "capacity": [[1, 4], 35, "damage"],
	"wheel": [[3], 45, "workshop"], "pickup": [[2], 35, "capacity"],
	"pace": [[4], 30, "capacity"], "spark": [[3], 40, "damage"],
}
const FIRST_GIFTS := ["D01", "D04", "D08"]
const LATER_GIFTS := ["D09", "D14"]
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
var workshop_stock: int:
	get:
		var total := 0
		for quantity: int in workshop_piles:
			total += quantity
		return total
	set(value):
		# H2 stored its entire workshop balance in one place.
		workshop_piles = [value, 0, 0, 0]
var workshop_piles := [0, 0, 0, 0]
var workshop_buffer := 0
var workshop_flights: Array = []
var batches_launched := 0
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
var first_gift := ""
var core_phase := 0
var core_hit := false
var observations: Dictionary = {}
var session_observations: Dictionary = {}
var session_elapsed_us := 0
var _previous_sample_us := -1
var _at_workshop := false


func sample_session(monotonic_us: int) -> void:
	# The monotonic origin belongs to this process. Only its accumulated intervals
	# go on disk. Earlier checkpoints without this clock have no observed total.
	if session_elapsed_us >= 0 and _previous_sample_us >= 0 and not at_act_summary():
		session_elapsed_us += maxi(0, monotonic_us - _previous_sample_us)
	_previous_sample_us = monotonic_us


func mark(event: String) -> void:
	if not observations.has(event):
		observations[event] = elapsed
		if session_elapsed_us >= 0 and _previous_sample_us >= 0:
			session_observations[event] = session_elapsed_us / 1000000.0


func rank_of(id: String) -> int:
	return int(ranks.get(id, 0))


func at_act_summary() -> bool:
	return hp == 0 and stage in [5, 10] and not chosen_gift.is_empty()


func has_gift(id: String) -> bool:
	return chosen_gift == id or first_gift == id


func max_hp() -> int:
	return HEALTH[stage - 1]


func damage(weak_spot := false) -> int:
	var base := 11.0 if bow == "recurve" else 10.0
	base *= (1.0 + 0.2 * damage_rank) * POWER[stage - 1]
	if has_gift("D04"):
		base *= 1.2
	if weak_spot:
		base *= 1.5 + 0.25 * rank_of("weak")
	return roundi(base)


func shot_interval() -> float:
	var rate := 2.5 if bow == "recurve" else 1.0
	rate *= 1.0 + 0.12 * rank_of("rate")
	if has_gift("D01"):
		rate *= 1.5
	return 1.0 / rate


func capacity() -> int:
	return 24 + 16 * capacity_rank + (24 if has_gift("D08") else 0)


func pickup_radius() -> float:
	return PICKUP_RADIUS + 0.75 * rank_of("pickup") + (2.0 if has_gift("D09") else 0.0)


func production_rate() -> float:
	return WORKSHOP_RATE * (1.0 + 0.2 * rank_of("wheel")) * (1.3 if has_gift("D03") else 1.0)


func speed_multiplier() -> float:
	return 1.0 + (0.06 * rank_of("pace") if arrows >= 4 else 0.0)


func combo_delay() -> float:
	return 4.5 if has_gift("D14") else 2.5


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
		if id == "damage" and rank == 0:
			cost = 0
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
	if int(options[id].cost) > 0:
		mark("first_paid_purchase")
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
	if stage == 10:
		if id not in ["body", "core_0", "core_1", "core_2", "root_0", "root_1", "root_2"]:
			return 0
		return hp - floori(max_hp() * (2 - core_phase) / 3.0)
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


func core_needs_hit() -> bool:
	return stage == 10 and hp > 0 and not core_hit and vulnerability("body") == 1


func strike_part(amount: int, id: String) -> int:
	if stage == 10 and (id == "core_%d" % core_phase or id == "root_%d" % core_phase):
		core_hit = true
	return damage_part(amount, id)


func _add_combo(opportunity: bool) -> void:
	combo = minf(6.0, combo + (0.25 if opportunity else 0.05))
	max_combo = maxf(max_combo, combo)
	combo_grace = combo_delay()


func damage_part(amount: int, id: String, manual := false) -> int:
	var remaining := vulnerability(id)
	if stage == 10 and not core_hit:
		# Any wood can be damaged. Each layer keeps one point until its hollow was
		# hit with an arrow, or the player struck the matching root with the branch.
		remaining = maxi(0, remaining - 1)
	var effective := mini(amount, remaining)
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
	if stage == 10 and core_phase < 2 and vulnerability("body") == 0:
		core_phase += 1
		core_hit = false
		mark("core_phase_" + str(core_phase))
	if hp == 0:
		sap += budget - hit_budget
		knot_stock += 8
		mark("broke_" + str(stage))
	return effective


func apply_damage(amount: int) -> void:
	damage_part(amount, "body")


func manual_impact(id: String, shot_damage: int, weak_damage: int, serial: int) -> Dictionary:
	var result := {"hit": false, "direct": 0, "spark": 0, "spark_target": ""}
	var diana := id == "target" and target_active and serial == target_serial
	var hollow := stage == 10 and id == "core_%d" % core_phase
	var weak_spot := diana or hollow
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
	elif vulnerability(id) <= 0 or (core_needs_hit() and not hollow):
		return result
	if hollow:
		core_hit = true
	if diana:
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
	if hp > 0 or stage >= HEALTH.size() or (stage == 5 and chosen_gift.is_empty()):
		return false
	if stage == 5:
		first_gift = chosen_gift
		chosen_gift = ""
		split = false
		left_hp = 0
		right_hp = 0
	stage += 1
	hp = max_hp()
	target_active = false
	target_clock = 1.5 if not seen_target else _draw(15.0, 25.0)
	if stage in [5, 10]:
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
	if stage < 2 or stage in [5, 10]:
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
		_tick_workshop(delta)
	if hp > 0:
		var decay_delta := maxf(0.0, delta - combo_grace)
		combo_grace = maxf(0.0, combo_grace - delta)
		combo = maxf(1.0, combo - decay_delta * 0.5)
		_opportunities(delta)


func _tick_workshop(delta: float) -> void:
	var rate := production_rate()
	var ready_at_start := workshop_buffer + workshop_fraction
	var made := ready_at_start + delta * rate
	var batches := floori(made / WORKSHOP_BATCH)
	var remainder := made - batches * WORKSHOP_BATCH
	workshop_buffer = floori(remainder)
	workshop_fraction = remainder - workshop_buffer
	for flight: Dictionary in workshop_flights:
		flight.remaining -= delta
	for batch in batches:
		var launch_offset := ((batch + 1) * WORKSHOP_BATCH - ready_at_start) / rate
		var lane := posmod(batches_launched + run_seed, LANDING_COUNT)
		batches_launched += 1
		workshop_flights.append({"slot": lane, "count": WORKSHOP_BATCH, "serial": batches_launched,
			"duration": WORKSHOP_FLIGHT, "remaining": WORKSHOP_FLIGHT - maxf(0.0, delta - launch_offset)})
	for i in range(workshop_flights.size() - 1, -1, -1):
		var flight: Dictionary = workshop_flights[i]
		if flight.remaining <= 0:
			workshop_piles[flight.slot] += int(flight.count)
			workshop_flights.remove_at(i)


func observe_workshop_visit(inside: bool) -> void:
	if inside and not _at_workshop and workshop and collected > 0 and arrows == 0:
		mark("returned_empty_to_workshop")
	_at_workshop = inside


func collect(from_workshop: bool, slot: int = 0) -> int:
	if from_workshop and (slot < 0 or slot >= workshop_piles.size()):
		return 0
	var stock: int = workshop_piles[slot] if from_workshop else knot_stock
	var transfer := mini(capacity() - arrows, stock)
	arrows += transfer
	if from_workshop:
		workshop_piles[slot] -= transfer
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
	if stage not in [5, 10] or hp > 0 or not gift_offer.is_empty() or not chosen_gift.is_empty():
		return
	var pool := FIRST_GIFTS.duplicate()
	if stage == 10:
		pool.append_array(LATER_GIFTS)
		if workshop:
			pool.append("D03")
		pool.erase(first_gift)
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed + stage
	while gift_offer.size() < 3:
		gift_offer.append(pool.pop_at(rng.randi_range(0, pool.size() - 1)))


func choose_gift(id: String) -> bool:
	if not chosen_gift.is_empty() or not gift_offer.has(id):
		return false
	chosen_gift = id
	gift_offer.clear()
	mark("chosen_gift" if stage == 5 else "second_gift")
	return true


func save_state() -> Dictionary:
	var data := {"session_elapsed_us": session_elapsed_us,
		"session_observations": session_observations, "at_workshop": _at_workshop,
		"workshop_piles": workshop_piles, "workshop_flights": workshop_flights, "workshop_buffer": workshop_buffer,
		"batches_launched": batches_launched, "core_phase": core_phase, "core_hit": core_hit, "first_gift": first_gift}
	for field: String in SAVE_FIELDS:
		data[field] = get(field)
	return data.duplicate(true)


func _valid_workshop_state(data: Dictionary) -> bool:
	var piles = data.get("workshop_piles", [data.workshop_stock, 0, 0, 0])
	var flights = data.get("workshop_flights", [])
	var buffer = data.get("workshop_buffer", 0)
	if not piles is Array or piles.size() != LANDING_COUNT or not flights is Array:
		return false
	if not buffer is int or buffer < 0 or buffer >= WORKSHOP_BATCH:
		return false
	var total := 0
	for amount in piles:
		if not amount is int or amount < 0:
			return false
		total += amount
	if total != data.workshop_stock:
		return false
	for flight in flights:
		if not flight is Dictionary or not flight.has_all(["slot", "count", "serial", "duration", "remaining"]):
			return false
		if not flight.slot is int or flight.slot < 0 or flight.slot >= LANDING_COUNT:
			return false
		if not flight.count is int or flight.count <= 0 or not flight.serial is int:
			return false
		if not flight.duration is float or not flight.remaining is float or not is_finite(flight.remaining) or not is_finite(flight.duration):
			return false
		if flight.duration <= 0.0 or flight.remaining <= 0.0 or flight.remaining > flight.duration:
			return false
	return true


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
	if data.get("core_phase", 0) not in [0, 1, 2] or not data.get("core_hit", false) is bool or not _valid_workshop_state(data):
		return false
	for field: String in SAVE_FIELDS:
		set(field, data[field])
	workshop_piles = data.get("workshop_piles", [workshop_stock, 0, 0, 0]).duplicate()
	workshop_flights = data.get("workshop_flights", []).duplicate(true)
	workshop_buffer = data.get("workshop_buffer", 0)
	batches_launched = data.get("batches_launched", 0)
	first_gift = data.get("first_gift", "")
	core_phase = data.get("core_phase", 0)
	core_hit = data.get("core_hit", false)
	session_elapsed_us = int(data.get("session_elapsed_us", -1))
	session_observations = data.get("session_observations", {})
	_previous_sample_us = -1
	_at_workshop = bool(data.get("at_workshop", true))
	return true


func snapshot() -> Dictionary:
	return {"stage": stage, "hp": hp, "max_hp": max_hp(), "sap": sap, "arrows": arrows,
		"can_continue_act": at_act_summary() and stage == 5, "first_gift": first_gift, "core_phase": core_phase,
		"core_needs_hit": core_needs_hit(), "core_hit": core_hit,
		"capacity": capacity(), "damage": damage(), "damage_rank": damage_rank,
		"shot_rate": 1.0 / shot_interval(), "production_rate": production_rate() if workshop else 0.0,
		"pickup_radius": pickup_radius(), "combo_delay": combo_delay(),
		"capacity_rank": capacity_rank, "workshop": workshop, "workshop_stock": workshop_stock,
		"workshop_piles": workshop_piles, "workshop_flights": workshop_flights,
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
