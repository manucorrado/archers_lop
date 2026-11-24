extends RefCounted
## Reglas y estado de los dos primeros actos.

const HEALTH := [160, 821, 2079, 5057, 19430, 20446, 41932, 74796, 144178, 357311]
const DAMAGE_PER_SAP := 8
const POWER := [1.0, 1.52, 2.3104, 3.511808, 5.33794816, 8.1136812032, 12.332795428864,
	18.74584905187328, 28.49369055884739, 43.31040964944803]
const SHOT_INTERVAL := 1.0
const PICKUP_RADIUS := 1.5
const WORKSHOP_RATE := 1.25
const WORKSHOP_BATCH := 3
const WORKSHOP_FLIGHT := 0.8
const LANDING_COUNT := 4
const SENTINEL_CAPACITY := 12
const SENTINEL_INTERVAL := 2.0
const SENTINEL_RESERVE := 4
const Paths = preload("res://scripts/upgrade_paths.gd")
static var TREE := Paths.build_tree()
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
var sap_remainder := 0
var arrows := 24
var ranks: Dictionary = {}
var paid_prices: Dictionary = {}
var bow := "branch"
var last_volley := -10.0
var steady_count := 0
var volley_critical := false
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
var supply_hints := preload("res://scripts/supply_hints.gd").new()
var workshop_buffer := 0
var workshop_flights: Array = []
var batches_launched := 0
var sentinel_ammo := 0
var sentinel_wait := SENTINEL_INTERVAL
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
var experience_us := 0
var damage_by_source := {"bow": 0, "sentinel": 0, "branch": 0, "spark": 0, "other": 0}
var damage_history_complete := true
var tenth_entry: Dictionary = {}
var _previous_sample_us := -1
var _session_focused := true
var _at_workshop := false


func sample_session(monotonic_us: int) -> void:
	# The monotonic origin belongs to this process. Only its accumulated intervals
	# go on disk. Earlier checkpoints without this clock have no observed total.
	if _session_focused and _previous_sample_us >= 0:
		var interval := maxi(0, monotonic_us - _previous_sample_us)
		if session_elapsed_us >= 0 and not at_act_summary():
			session_elapsed_us += interval
		if experience_us >= 0 and not (stage == 10 and at_act_summary()):
			experience_us += interval
	_previous_sample_us = monotonic_us


func set_session_focus(focused: bool, monotonic_us: int) -> void:
	sample_session(monotonic_us)
	_session_focused = focused


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


func _arrow_power(weak_spot: bool) -> float:
	var base := 10.0
	if bow == "longbow":
		base = 22.0
	elif bow == "recurve":
		base = 11.0
	base *= 1.0 + 0.2 * damage_rank
	base += _family_ranks("damage_step")
	base *= pow(1.2, rank_of("damage_mult")) * POWER[stage - 1]
	if has_gift("D04"):
		base *= 1.2
	if weak_spot:
		base *= 1.5 + 0.5 * rank_of("weak")
	return base


func damage(weak_spot := false) -> int:
	return roundi(_arrow_power(weak_spot))


func volley_size() -> int:
	return 3 if damage_rank == TREE.damage.costs.size() else 1


func begin_volley() -> void:
	var continuous := elapsed - last_volley <= maxf(0.35, shot_interval() * 1.55)
	steady_count = mini(4, steady_count + 1) if continuous else 1
	last_volley = elapsed
	volley_critical = rank_of("crit") > 0 and _draw(0.0, 1.0) < 0.1


func volley_damage(weak_spot := false) -> int:
	var base := _arrow_power(weak_spot)
	if volley_critical:
		base *= 2.0
	if steady_count >= 4 and rank_of("steady") > 0:
		base *= 1.2
	return roundi(base)


func shot_interval() -> float:
	var rate := 1.0
	if bow == "recurve":
		rate = 2.5
	elif bow == "longbow":
		rate = 2.0
	rate *= 1.0 + 0.12 * rank_of("rate") + 0.02 * _family_ranks("rate_step")
	rate += rank_of("rate_flat")
	if has_gift("D01"):
		rate *= 1.5
	return 1.0 / rate


func capacity() -> int:
	return 24 + 16 * capacity_rank + (24 if has_gift("D08") else 0)


func pickup_radius() -> float:
	return PICKUP_RADIUS + 0.75 * rank_of("pickup") + (2.0 if has_gift("D09") else 0.0)


func production_rate() -> float:
	var gears := _family_ranks("wheel_step") + rank_of(Paths.SENTINEL_NODE)
	var base := WORKSHOP_RATE * (1.0 + 0.2 * rank_of("wheel")) + 0.025 * gears
	return base * (1.3 if has_gift("D03") else 1.0)


func _family_ranks(family: String) -> int:
	var total := 0
	for id: String in ranks:
		if Paths.family(id) == family:
			total += rank_of(id)
	return total


func speed_multiplier() -> float:
	return 1.0 + (0.06 * rank_of("pace") if arrows >= 4 else 0.0)


func combo_delay() -> float:
	return (4.5 if has_gift("D14") else 2.5) + rank_of("combo")


func _rank_value(id: String, rank: int) -> float:
	match Paths.family(id):
		"damage": return 10.0 * (1.0 + 0.2 * rank)
		"rate": return 12 * rank
		"damage_mult": return pow(1.2, rank)
		"rate_flat", "damage_step": return rank
		"rate_step": return 2 * rank
		"wheel_step": return 0.025 * rank
		"sentinel": return SENTINEL_CAPACITY * rank
		"weak": return 1.5 + 0.5 * rank
		"recurve": return 1.0 if rank == 0 else 2.5
		"workshop": return WORKSHOP_RATE * rank * (1.0 + 0.2 * rank_of("wheel"))
		"capacity": return 24 + 16 * rank
		"wheel": return WORKSHOP_RATE * (1.0 + 0.2 * rank)
		"pickup": return PICKUP_RADIUS + 0.75 * rank
		"pace": return 6 * rank
		"spark": return 20 * rank
		"longbow": return 22 * rank
		"combo": return 2.5 + rank
		"crit": return 10 * rank
		"steady": return 20 * rank
		"refund", "pet", "leap": return rank
	return 0.0


func offers() -> Dictionary:
	var result := {}
	for id: String in TREE:
		var rule: Dictionary = TREE[id]
		var costs: Array = rule.costs
		var rank := rank_of(id)
		var maxed := rank >= costs.size()
		var cost: int = costs[mini(rank, costs.size() - 1)]
		var req: String = rule.parent
		var extra: String = rule.get("extra_parent", "")
		var extra_rank: int = rule.get("extra_rank", 0)
		var allowed := (req.is_empty() or rank_of(req) > 0) and rank_of(extra) >= extra_rank
		var refundable := rank > 0 and id != "refund" and rank_of("refund") > 0
		result[id] = {"stage": 1, "cost": cost, "rank": rank, "max_rank": costs.size(),
			"requires": req, "rank_required": 1, "extra_requires": extra, "extra_rank_required": extra_rank,
			"requirement_met": allowed, "maxed": maxed, "owned": rank > 0, "refundable": refundable,
			"refund_cost": _price_paid(id, rank - 1) if rank > 0 else 0,
			"available": not maxed and allowed and sap >= cost,
			"current": _rank_value(id, rank), "next": _rank_value(id, mini(rank + 1, costs.size()))}
	return result


func _price_paid(id: String, index: int) -> int:
	var history: Array = paid_prices.get(id, [])
	return history[index] if index < history.size() else TREE[id].costs[index]


func _paid_history(id: String) -> Array:
	var prices := []
	for i in rank_of(id):
		prices.append(_price_paid(id, i))
	return prices


func buy(id: String) -> bool:
	var options := offers()
	if not options.has(id) or not options[id].available:
		return false
	var history := _paid_history(id)
	history.append(int(options[id].cost))
	paid_prices[id] = history
	sap -= int(options[id].cost)
	ranks[id] = rank_of(id) + 1
	mark("first_purchase")
	if int(options[id].cost) > 0:
		mark("first_paid_purchase")
	mark("buy_" + id)
	if id in ["recurve", "longbow"]:
		equip(id)
	return true


func refund(id: String) -> bool:
	if not TREE.has(id) or rank_of("refund") == 0 or id == "refund" or rank_of(id) == 0:
		return false
	var history := _paid_history(id)
	sap += int(history.pop_back())
	if history.is_empty():
		ranks.erase(id)
		paid_prices.erase(id)
	else:
		ranks[id] = history.size()
		paid_prices[id] = history
	if bow == id and rank_of(id) == 0:
		equip("longbow" if rank_of("longbow") > 0 else ("recurve" if rank_of("recurve") > 0 else "branch"))
	if id == "combo":
		combo = 1.0
		combo_grace = 0.0
	if id == Paths.SENTINEL_NODE:
		var carried := mini(sentinel_ammo, maxi(0, capacity() - arrows))
		arrows += carried
		knot_stock += sentinel_ammo - carried
		sentinel_ammo = 0
		sentinel_wait = SENTINEL_INTERVAL
	return true


func sentinel_load_size() -> int:
	if rank_of(Paths.SENTINEL_NODE) == 0:
		return 0
	return mini(8, mini(SENTINEL_CAPACITY - sentinel_ammo, maxi(0, arrows - SENTINEL_RESERVE)))


func load_sentinel() -> int:
	var amount := sentinel_load_size()
	if amount > 0:
		arrows -= amount
		sentinel_ammo += amount
		mark("first_sentinel_load")
	return amount


func sentinel_target() -> String:
	if hp <= 0 or core_needs_hit():
		return ""
	if split:
		return "right" if right_hp > 0 else "left"
	return "body"


func tick_sentinel(delta: float) -> String:
	if sentinel_ammo == 0 or rank_of(Paths.SENTINEL_NODE) == 0:
		return ""
	var target := sentinel_target()
	if target.is_empty():
		return ""
	sentinel_wait = maxf(0.0, sentinel_wait - delta)
	if sentinel_wait > 0:
		return ""
	sentinel_wait = SENTINEL_INTERVAL
	sentinel_ammo -= 1
	mark("first_sentinel_shot")
	return target


func equip(id: String) -> bool:
	if id != "branch" and (id not in ["recurve", "longbow"] or rank_of(id) == 0):
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
	return damage_part(amount, id, false, "branch")


func _add_combo(opportunity: bool) -> void:
	if rank_of("combo") == 0:
		return
	combo = minf(6.0, combo + (0.25 * (1 + rank_of("combo")) if opportunity else 0.05))
	max_combo = maxf(max_combo, combo)
	combo_grace = combo_delay()


func damage_part(amount: int, id: String, manual := false, source := "other") -> int:
	var remaining := vulnerability(id)
	if stage == 10 and not core_hit:
		# Any wood can be damaged. Each layer keeps one point until its hollow was
		# hit with an arrow, or the player struck the matching root with the branch.
		remaining = maxi(0, remaining - 1)
	var effective := mini(amount, remaining)
	if effective <= 0:
		return 0
	# Keep the unpaid damage across hits, targets and sessions.
	sap_remainder += effective
	@warning_ignore("integer_division")
	sap += sap_remainder / DAMAGE_PER_SAP
	sap_remainder %= DAMAGE_PER_SAP
	hp -= effective
	damage_by_source[source] += effective
	if split:
		if id == "left":
			left_hp -= effective
		else:
			right_hp -= effective
		if hp > 0 and (left_hp == 0 or right_hp == 0):
			mark("first_lobe_broken")
	if manual and rank_of("combo") > 0:
		bonus_fraction += float(effective) / DAMAGE_PER_SAP * 0.1 * (combo - 1.0)
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
		knot_stock += 8
		mark("broke_" + str(stage))
	return effective


func apply_damage(amount: int) -> void:
	damage_part(amount, "body")


func manual_impact(id: String, shot_damage: int, weak_damage: int, serial: int) -> Dictionary:
	var result := {"hit": false, "weak_spot": false, "direct": 0, "spark": 0,
		"spark_target": "", "arrows_returned": 0}
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
		if stage >= 6:
			var recovered := mini(3, maxi(0, capacity() - arrows))
			arrows += recovered
			result.arrows_returned = recovered
	_add_combo(weak_spot or seed_hit)
	hits += 1
	mark("first_hit")
	result.hit = true
	result.weak_spot = weak_spot
	if not seed_hit:
		result.direct = damage_part(weak_damage if weak_spot else shot_damage, id, true, "bow")
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
			result.spark = damage_part(roundi(20.0 * POWER[stage - 1]), spark_target, false, "spark")
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
	if stage == 10:
		tenth_entry = {"ranks": ranks.duplicate(), "paid_prices": paid_prices.duplicate(true),
			"sap": sap, "bow": bow, "gift": first_gift}
	target_active = false
	if stage == 6:
		_offer_target()
	else:
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
	if workshop or not workshop_flights.is_empty():
		_tick_workshop(delta)
	if hp > 0:
		var decay_delta := maxf(0.0, delta - combo_grace)
		combo_grace = maxf(0.0, combo_grace - delta)
		combo = maxf(1.0, combo - decay_delta * 0.5)
		_opportunities(delta)


func _tick_workshop(delta: float) -> void:
	var rate := production_rate()
	var ready_at_start := workshop_buffer + workshop_fraction
	var made := ready_at_start + (delta * rate if workshop else 0.0)
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
	var transfer := mini(maxi(0, capacity() - arrows), stock)
	arrows += transfer
	if from_workshop:
		workshop_piles[slot] -= transfer
		if transfer > 0:
			supply_hints.picked_up(str(slot), workshop_piles[slot], elapsed)
			collected += transfer
			mark("first_production_pickup")
	else:
		knot_stock -= transfer
		if transfer > 0:
			supply_hints.picked_up("knot", knot_stock, elapsed)
	return transfer


func collect_seeds(id: String) -> int:
	var stock := int(seed_drops.get(id, 0))
	var transfer := mini(maxi(0, capacity() - arrows), stock)
	arrows += transfer
	if stock == transfer:
		seed_drops.erase(id)
	else:
		seed_drops[id] = stock - transfer
	if transfer > 0:
		supply_hints.picked_up(id, stock - transfer, elapsed)
	return transfer


func prepare_gifts() -> void:
	if stage not in [5, 10] or hp > 0 or not gift_offer.is_empty() or not chosen_gift.is_empty():
		return
	var pool := FIRST_GIFTS.duplicate()
	if stage == 10:
		pool.append_array(LATER_GIFTS)
		if rank_of("combo") == 0:
			pool.erase("D14")
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
	var data := {"session_elapsed_us": session_elapsed_us, "sap_remainder": sap_remainder,
		"experience_us": experience_us, "damage_by_source": damage_by_source,
		"damage_history_complete": damage_history_complete, "tenth_entry": tenth_entry,
		"sentinel_ammo": sentinel_ammo, "sentinel_wait": sentinel_wait,
		"paid_prices": paid_prices, "steady_count": steady_count, "last_volley": last_volley,
		"session_observations": session_observations, "at_workshop": _at_workshop,
		"workshop_piles": workshop_piles, "workshop_flights": workshop_flights, "workshop_buffer": workshop_buffer,
		"batches_launched": batches_launched, "core_phase": core_phase, "core_hit": core_hit, "first_gift": first_gift,
		"supply_hints": supply_hints.checkpoint()}
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


func _had_paid_root(data: Dictionary) -> bool:
	if not data.has("workshop_piles"):
		return true
	# Profiles begun in the five-target build can already contain the newer workshop fields.
	# A later paid purchase preceding the new spending clock dates the root to that build.
	var marks: Dictionary = data.observations
	var first_spend := float(marks.get("first_paid_purchase", INF))
	var got_damage := float(marks.get("buy_damage", INF))
	for id: String in ["rate", "weak", "recurve", "workshop", "capacity", "wheel", "pickup", "pace", "spark"]:
		var got_other := float(marks.get("buy_" + id, INF))
		if got_damage <= got_other and got_other < first_spend:
			return true
	return false


func _valid_holdings(owned: Dictionary, history: Dictionary) -> bool:
	for id in owned:
		var rank = owned[id]
		if not TREE.has(id) or not rank is int or rank < 0 or rank > TREE[id].costs.size():
			return false
	for id in history:
		var prices = history[id]
		if not owned.has(id) or not prices is Array or prices.size() != owned[id]:
			return false
		for price in prices:
			if not price is int or price < 0:
				return false
	return true


func _valid_observed_run(data: Dictionary) -> bool:
	var duration = data.get("experience_us", -1)
	var totals = data.get("damage_by_source", {})
	if not duration is int or duration < -1 or not totals is Dictionary or not data.get("damage_history_complete", false) is bool:
		return false
	for source in totals:
		if not damage_by_source.has(source) or not totals[source] is int or totals[source] < 0:
			return false
	var entry = data.get("tenth_entry", {})
	if not entry is Dictionary:
		return false
	if entry.is_empty():
		return true
	if data.stage != 10 or not entry.has_all(["sap", "ranks", "paid_prices", "bow", "gift"]):
		return false
	if not entry.sap is int or entry.sap < 0 or entry.bow not in ["branch", "recurve", "longbow"] or not entry.gift is String:
		return false
	return entry.ranks is Dictionary and entry.paid_prices is Dictionary and _valid_holdings(entry.ranks, entry.paid_prices)


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
	var history = data.get("paid_prices", {})
	var saved_ammo = data.get("sentinel_ammo", 0)
	var saved_wait = data.get("sentinel_wait", SENTINEL_INTERVAL)
	if not saved_ammo is int or saved_ammo < 0 or saved_ammo > SENTINEL_CAPACITY:
		return false
	if saved_ammo > 0 and data.ranks.get(Paths.SENTINEL_NODE, 0) == 0:
		return false
	if not saved_wait is float or not is_finite(saved_wait) or saved_wait < 0 or saved_wait > SENTINEL_INTERVAL:
		return false
	var saved_remainder = data.get("sap_remainder", 0)
	if not saved_remainder is int or saved_remainder < 0 or saved_remainder >= DAMAGE_PER_SAP:
		return false
	var saved_streak = data.get("steady_count", 0)
	var saved_last_volley = data.get("last_volley", -10.0)
	if not history is Dictionary or not saved_streak is int or saved_streak < 0 or saved_streak > 4:
		return false
	if not saved_last_volley is float or not is_finite(saved_last_volley):
		return false
	if not _valid_holdings(data.ranks, history) or not _valid_observed_run(data):
		return false
	for field: String in SAVE_FIELDS:
		set(field, data[field])
	sap_remainder = saved_remainder
	sentinel_ammo = saved_ammo
	sentinel_wait = saved_wait
	if rank_of("combo") == 0:
		combo = 1.0
		combo_grace = 0.0
	paid_prices = history.duplicate(true)
	# The five-target build charged four sap for the root; the following build made it free.
	if not data.has("paid_prices") and damage_rank > 0 and _had_paid_root(data):
		var damage_prices := _paid_history("damage")
		damage_prices[0] = 4
		paid_prices.damage = damage_prices
	last_volley = saved_last_volley
	steady_count = saved_streak
	volley_critical = false
	workshop_piles = data.get("workshop_piles", [workshop_stock, 0, 0, 0]).duplicate()
	supply_hints.restore(data.get("supply_hints"), elapsed)
	workshop_flights = data.get("workshop_flights", []).duplicate(true)
	workshop_buffer = data.get("workshop_buffer", 0)
	batches_launched = data.get("batches_launched", 0)
	first_gift = data.get("first_gift", "")
	core_phase = data.get("core_phase", 0)
	core_hit = data.get("core_hit", false)
	session_elapsed_us = int(data.get("session_elapsed_us", -1))
	experience_us = data.get("experience_us", -1)
	for source: String in damage_by_source:
		damage_by_source[source] = data.get("damage_by_source", {}).get(source, 0)
	damage_history_complete = data.has("damage_by_source") and data.get("damage_history_complete", false)
	tenth_entry = data.get("tenth_entry", {}).duplicate(true)
	session_observations = data.get("session_observations", {})
	_previous_sample_us = -1
	_at_workshop = bool(data.get("at_workshop", true))
	return true


func snapshot() -> Dictionary:
	return {"stage": stage, "hp": hp, "max_hp": max_hp(), "sap": sap, "arrows": arrows,
		"sentinel_owned": rank_of(Paths.SENTINEL_NODE) > 0, "sentinel_ammo": sentinel_ammo,
		"sentinel_capacity": SENTINEL_CAPACITY, "sentinel_load_size": sentinel_load_size(),
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
		"session_observations": session_observations, "experience_us": experience_us,
		"damage_by_source": damage_by_source, "damage_history_complete": damage_history_complete,
		"tenth_entry": tenth_entry}
