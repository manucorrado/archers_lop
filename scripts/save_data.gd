extends RefCounted
## Keep the two latest checkpoints. An interrupted write never touches the newer slot.

const SCHEMA := 1
const SLOTS := ["user://campaign-a.save", "user://campaign-b.save"]
const RECORD_SLOTS := ["user://run-records-a.save", "user://run-records-b.save"]
const MAGIC := "ARCHSAVE"
const DIGEST_SIZE := 32
const MAX_BYTES := 1024 * 1024


static func _digest(bytes: PackedByteArray) -> PackedByteArray:
	var hash := HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(bytes)
	return hash.finish()


static func _read_slot(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var size := file.get_length()
	var header_size := MAGIC.length() + DIGEST_SIZE
	if size <= header_size or size > MAX_BYTES + header_size:
		return {}
	if file.get_buffer(MAGIC.length()).get_string_from_ascii() != MAGIC:
		return {}
	var checksum := file.get_buffer(DIGEST_SIZE)
	var bytes := file.get_buffer(size - header_size)
	if _digest(bytes) != checksum:
		return {}
	var contents = bytes_to_var(bytes)
	if not contents is Array or contents.size() != 3:
		return {}
	if contents[0] != SCHEMA or not contents[1] is int or contents[1] < 1:
		return {}
	if not contents[2] is Dictionary or contents[2].is_empty():
		return {}
	return {"generation": contents[1], "campaign": contents[2]}


static func _latest(slots: Array = SLOTS) -> Dictionary:
	var latest := {}
	for slot: String in slots:
		var state := _read_slot(slot)
		if state.get("generation", 0) > latest.get("generation", 0):
			latest = state
			latest.slot = slot
	return latest


static func has_campaign() -> bool:
	return not _latest().is_empty()


static func load_campaign() -> Dictionary:
	return _latest().get("campaign", {})


static func store_campaign(data: Dictionary) -> bool:
	return _store(data, SLOTS)


static func best_times() -> Dictionary:
	return _latest(RECORD_SLOTS).get("campaign", {})


static func update_best_times(times: Dictionary) -> bool:
	var prior := best_times()
	var updated := prior.duplicate()
	for id: String in times:
		var seconds := float(times[id])
		if seconds > 0.0 and is_finite(seconds) and seconds < float(prior.get(id, INF)):
			updated[id] = seconds
	return updated == prior or _store(updated, RECORD_SLOTS)


static func _store(data: Dictionary, slots: Array) -> bool:
	if data.is_empty():
		return false
	var previous := _latest(slots)
	var slot: String = slots[1] if previous.get("slot", "") == slots[0] else slots[0]
	var bytes := var_to_bytes([SCHEMA, int(previous.get("generation", 0)) + 1, data])
	if bytes.is_empty() or bytes.size() > MAX_BYTES:
		return false
	var temporary := slot + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return false
	file.store_buffer(MAGIC.to_ascii_buffer())
	file.store_buffer(_digest(bytes))
	file.store_buffer(bytes)
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK or _read_slot(temporary).is_empty():
		return false
	return DirAccess.rename_absolute(temporary, slot) == OK
