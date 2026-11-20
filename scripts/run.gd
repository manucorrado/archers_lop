extends RefCounted
## Short campaign. The controller supplies active play time and confirmed hits.

const HEALTH := [160, 821, 2079]
const SAP_BUDGET := [20, 30, 45]
const POWER := [1.0, 1.52, 2.3104]
const SHOT_INTERVAL := 1.0
const PICKUP_RADIUS := 1.5
const WORKSHOP_RATE := 1.5

var stage := 1
var hp := 160
var sap := 0
var arrows := 24
var damage_rank := 0
var capacity_rank := 0
var workshop := false
var workshop_stock := 0
var knot_stock := 0
var elapsed := 0.0
var shots := 0
var hits := 0
var collected := 0
var workshop_fraction := 0.0


func max_hp() -> int:
	return HEALTH[stage - 1]


func damage() -> int:
	return roundi((10.0 + 2.0 * damage_rank) * POWER[stage - 1])


func capacity() -> int:
	return 24 + 16 * capacity_rank


func offers() -> Dictionary:
	return {
		"damage": _offer(4 if damage_rank == 0 else 9, 1 if damage_rank == 0 else 3, damage_rank >= 2),
		"workshop": _offer(17, 2, workshop),
		"capacity": _offer(7, 1, capacity_rank >= 1),
	}


func _offer(cost: int, unlock: int, maxed: bool) -> Dictionary:
	return {"cost": cost, "stage": unlock, "maxed": maxed,
		"available": not maxed and stage >= unlock and sap >= cost}


func buy(id: String) -> bool:
	var options := offers()
	if not options.has(id) or not options[id].available:
		return false
	sap -= int(options[id].cost)
	match id:
		"damage": damage_rank += 1
		"capacity": capacity_rank += 1
		"workshop": workshop = true
	return true


func apply_damage(amount: int) -> void:
	if hp <= 0:
		return
	var budget: int = SAP_BUDGET[stage - 1]
	var hit_budget := floori(budget * 0.6)
	var before := floori(float(hit_budget * (max_hp() - hp)) / max_hp())
	hp = maxi(0, hp - amount)
	var after := floori(float(hit_budget * (max_hp() - hp)) / max_hp())
	sap += after - before
	if hp == 0:
		sap += budget - hit_budget
		knot_stock += 8


func tick(delta: float) -> void:
	elapsed += delta
	if workshop:
		workshop_fraction += delta * WORKSHOP_RATE
		var produced := floori(workshop_fraction)
		workshop_stock += produced
		workshop_fraction -= produced


func collect(from_workshop: bool) -> int:
	var stock := workshop_stock if from_workshop else knot_stock
	var transfer := mini(capacity() - arrows, stock)
	arrows += transfer
	if from_workshop:
		workshop_stock -= transfer
		collected += transfer
	else:
		knot_stock -= transfer
	return transfer


func snapshot() -> Dictionary:
	return {"stage": stage, "hp": hp, "max_hp": max_hp(), "sap": sap,
		"arrows": arrows, "capacity": capacity(), "damage": damage(),
		"damage_rank": damage_rank, "capacity_rank": capacity_rank, "workshop": workshop,
		"workshop_stock": workshop_stock, "knot_stock": knot_stock, "elapsed": elapsed,
		"shots": shots, "hits": hits, "collected": collected, "offers": offers()}
