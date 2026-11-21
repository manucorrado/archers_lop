extends RefCounted
## Printed alongside the act results. All splits are measured at the breaking hit.

const Journal = preload("res://scripts/field_journal.gd")
const Save = preload("res://scripts/save_data.gd")


static func splits(marks: Dictionary) -> Dictionary:
	var result := {}
	var first := float(marks.get("broke_5", -1.0))
	var last := float(marks.get("broke_10", -1.0))
	if first > 0:
		result["act1"] = first
	if last > 0:
		result["total"] = last
		if first > 0 and last > first:
			result["act2"] = last - first
	return result


static func _clock(seconds: float) -> String:
	if seconds < 0:
		return "—"
	var ticks := roundi(seconds)
	return "%d:%02d" % [floori(ticks / 60.0), ticks % 60]


static func _line(parent: Control, text: String, font: Font, px: int, color: Color, expand := false) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", px)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if expand:
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(label)
	return label


static func _table(parent: Control, columns: int) -> GridContainer:
	var table := GridContainer.new()
	table.columns = columns
	table.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	table.add_theme_constant_override("h_separation", 22)
	table.add_theme_constant_override("v_separation", 1)
	parent.add_child(table)
	return table


static func build(parent: Control, state: Dictionary, language: String) -> void:
	var es := language == "es"
	var serif := Journal.serif()
	var sans := SystemFont.new()
	sans.font_names = PackedStringArray(["Source Sans 3", "Segoe UI", "Arial"])
	_line(parent, "Registro de la vuelta" if es else "Run log", serif, 34, Journal.INK)
	_line(parent, "Tiempo de juego hasta romper cada blanco." if es else "Active play time up to each target break.", sans, 17, Journal.MUTED)
	var marks: Dictionary = state.get("observations", {})
	var times := splits(marks)
	var records := Save.best_times()
	var table := _table(parent, 3)
	for title in (["Tramo", "Esta vuelta", "Récord local"] if es else ["Section", "This run", "Local best"]):
		_line(table, title, sans, 16, Journal.MUTED)
	var ids := ["act1", "act2", "total"]
	var titles := ["Primer acto", "Segundo acto", "Demo completa"] if es else ["First act", "Second act", "Full demo"]
	for i in ids.size():
		var id: String = ids[i]
		_line(table, titles[i], serif, 20, Journal.INK, true)
		_line(table, _clock(times.get(id, -1.0)), sans, 18, Journal.INK)
		_line(table, _clock(records.get(id, -1.0)), sans, 18, Journal.ACCENT)
	parent.add_child(HSeparator.new())
	var targets := _table(parent, 4)
	for target in range(1, 6):
		for number: int in [target, target + 5]:
			_line(targets, ("Blanco %d" if es else "Target %d") % number, sans, 16, Journal.MUTED, true)
			var finish := float(marks.get("broke_%d" % number, -1.0))
			var start := 0.0 if number == 1 else float(marks.get("broke_%d" % (number - 1), -1.0))
			var duration := finish - start if start >= 0 and finish >= start else -1.0
			_line(targets, _clock(duration), sans, 17, Journal.INK)
	parent.add_child(HSeparator.new())
	var levels := 0
	var possible := 0
	for offer: Dictionary in state.get("offers", {}).values():
		levels += int(offer.rank)
		possible += int(offer.max_rank)
	var balance := ("Niveles comprados  %d / %d     ·     Savia disponible  %d" if es else
			"Upgrade levels owned  %d / %d     ·     Sap on hand  %d") % [levels, possible, state.get("sap", 0)]
	_line(parent, balance, sans, 17, Journal.INK)
