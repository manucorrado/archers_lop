extends RefCounted
## Active play time of the first untouched arrows at each landing.

const LEARNING_TIME := 600.0
const STALE_TIME := 90.0
const REMINDER_DURATION := 8.0
const ALREADY_SHOWN := -1.0

var since := {}
var reminder := ""
var last_reminder := -STALE_TIME


func picked_up(id: String, remaining: int, elapsed: float) -> void:
	if remaining == 0:
		since.erase(id)
	else:
		since[id] = elapsed
	if reminder == id:
		reminder = ""


func choose(piles: Dictionary, player: Vector3, elapsed: float, enabled: bool, needs_supply: bool) -> String:
	for id: String in since.keys():
		if not piles.has(id):
			since.erase(id)
	for id: String in piles:
		if not since.has(id):
			since[id] = elapsed
	if not enabled or not needs_supply:
		return ""
	var learning := elapsed < LEARNING_TIME
	if not learning and elapsed - last_reminder < STALE_TIME:
		return reminder if elapsed - last_reminder < REMINDER_DURATION and piles.has(reminder) else ""
	var nearest := ""
	var best := INF
	for id: String in piles:
		if not learning and (since[id] == ALREADY_SHOWN or elapsed - since[id] < STALE_TIME):
			continue
		var point: Vector3 = piles[id]
		var distance := player.distance_squared_to(point)
		if distance < best:
			nearest = id
			best = distance
	if not learning and not nearest.is_empty():
		reminder = nearest
		last_reminder = elapsed
		since[nearest] = ALREADY_SHOWN
	return nearest


func checkpoint() -> Dictionary:
	return {"since": since.duplicate(), "reminder": reminder, "last_reminder": last_reminder}


func restore(data: Variant, elapsed: float) -> void:
	since.clear()
	reminder = ""
	last_reminder = -STALE_TIME
	if not data is Dictionary or not data.get("since") is Dictionary:
		return
	for id in data.since:
		var stamp = data.since[id]
		if id is String and stamp is float and is_finite(stamp) and (stamp == ALREADY_SHOWN or (stamp >= 0 and stamp <= elapsed)):
			since[id] = stamp
	var started = data.get("last_reminder")
	if started is float and is_finite(started) and started >= -STALE_TIME and started <= elapsed:
		last_reminder = started
		var previous = data.get("reminder")
		if previous is String and since.get(previous, 0.0) == ALREADY_SHOWN:
			reminder = previous
