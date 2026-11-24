extends RefCounted
## Printed alongside the act results. All splits are measured at the breaking hit.

const Journal = preload("res://scripts/field_journal.gd")
const Save = preload("res://scripts/save_data.gd")
const Paths = preload("res://scripts/upgrade_paths.gd")


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


static func build(parent: Control, state: Dictionary, language: String, upgrades := {}, gifts := {}) -> void:
	var es := language == "es"
	var serif := Journal.serif()
	var sans := SystemFont.new()
	sans.font_names = PackedStringArray(["Source Sans 3", "Segoe UI", "Arial"])
	_line(parent, "Registro de la vuelta" if es else "Run log", serif, 34, Journal.INK)
	var tabs := TabContainer.new()
	tabs.use_hidden_tabs_for_min_size = true
	tabs.add_theme_stylebox_override("panel", Journal.box(Journal.PAPER, Journal.RULE, 14, 8))
	for style in ["tab_unselected", "tab_hovered", "tab_selected"]:
		tabs.add_theme_stylebox_override(style, Journal.box(Journal.PAPER if style == "tab_selected" else Journal.CANVAS, Journal.RULE, 14, 5))
	for color in ["font_selected_color", "font_unselected_color", "font_hovered_color"]:
		tabs.add_theme_color_override(color, Journal.INK)
	tabs.add_theme_font_override("font", sans)
	parent.add_child(tabs)
	var pages: Array[VBoxContainer] = []
	for title in (["Tiempos", "Daño", "Compras al blanco 10"] if es else ["Times", "Damage", "Upgrades at target 10"]):
		var page := VBoxContainer.new()
		page.name = title
		page.add_theme_constant_override("separation", 6)
		tabs.add_child(page)
		pages.append(page)
	_times(pages[0], state, es, sans, serif)
	_damage(pages[1], state, es, sans)
	_entry(pages[2], state, es, sans, upgrades, gifts)


static func _times(parent: Control, state: Dictionary, es: bool, sans: Font, serif: Font) -> void:
	var marks: Dictionary = state.get("observations", {})
	var total_us := int(state.get("experience_us", -1))
	var final_card := marks.has("second_gift")
	var total := _clock(total_us / 1000000.0) if final_card and total_us >= 0 else "—"
	var active := _clock(marks.get("second_gift", -1.0))
	_line(parent, ("Hasta confirmar la última carta     Total  %s     ·     En juego  %s" if es else
			"Through final card confirmation     Total  %s     ·     Active play  %s") % [total, active], sans, 18, Journal.INK)
	_line(parent, "El total incluye menús, charlas y pausas con el juego en primer plano." if es else
		"The total includes menus, conversations and pauses while the game is in focus.", sans, 16, Journal.MUTED)
	var times := splits(marks)
	var records := Save.best_times()
	var table := _table(parent, 3)
	for title in (["Tramo", "Esta vuelta", "Récord local"] if es else ["Section", "This run", "Local best"]):
		_line(table, title, sans, 16, Journal.MUTED)
	var ids := ["act1", "act2", "total"]
	var titles := ["Primer acto", "Segundo acto", "Hasta romper el blanco 10"] if es else ["First act", "Second act", "Through target 10 break"]
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


static func _damage(parent: Control, state: Dictionary, es: bool, sans: Font) -> void:
	_line(parent, "Vida que perdió el árbol por cada fuente de daño." if es else
		"Health removed from the tree by each damage source.", sans, 17, Journal.MUTED)
	if not state.get("damage_history_complete", false):
		_line(parent, "Partida anterior · Las cifras cubren desde la actualización." if es else
			"Older save · Figures cover play since the update.", sans, 16, Journal.ACCENT)
	var totals: Dictionary = state.get("damage_by_source", {})
	var total := 0
	for amount: int in totals.values():
		total += amount
	var table := _table(parent, 3)
	for title in (["Fuente", "Daño", "Porcentaje"] if es else ["Source", "Damage", "Share"]):
		_line(table, title, sans, 16, Journal.MUTED)
	var names := {"bow": ["Arco", "Bow"], "sentinel": ["Ballesta", "Crossbow"], "branch": ["Rama", "Branch"],
		"spark": ["Chispa", "Spark"], "other": ["Otras fuentes", "Other sources"]}
	for id: String in names:
		var amount := int(totals.get(id, 0))
		if id == "other" and amount == 0:
			continue
		_line(table, names[id][0 if es else 1], sans, 18, Journal.INK, true)
		_line(table, str(amount), sans, 18, Journal.INK)
		var share := "%.1f %%" % (100.0 * amount / total) if total > 0 else "—"
		_line(table, share.replace(".", ",") if es else share, sans, 18, Journal.ACCENT)
	_line(parent, ("Daño total  %d" if es else "Total damage  %d") % total, sans, 18, Journal.INK)


static func _entry(parent: Control, state: Dictionary, es: bool, sans: Font, upgrades: Dictionary, gifts: Dictionary) -> void:
	var entry: Dictionary = state.get("tenth_entry", {})
	if entry.is_empty():
		var missing := int(state.get("stage", 1)) == 10
		var message := ("Esta partida llegó al blanco 10 antes de la actualización." if es else
			"This save reached target 10 before the update.") if missing else (
			"Se registra cuando aparece el décimo árbol." if es else "Recorded when the tenth tree appears.")
		_line(parent, message, sans, 17, Journal.MUTED)
		return
	var levels := 0
	for rank: int in entry.ranks.values():
		levels += rank
	var index := 0 if es else 1
	var bow_names := {"branch": ["Arco de rama", "Branch bow"], "recurve": ["Arco rápido", "Recurve bow"],
		"longbow": ["Arco largo", "Longbow"]}
	var gift: Array = gifts.get(entry.gift, ["—", "—"])
	var header := ("Al aparecer el árbol     %d niveles comprados     ·     %d de savia" if es else
		"When the tree appeared     %d upgrade levels owned     ·     %d sap on hand") % [levels, entry.sap]
	_line(parent, header, sans, 18, Journal.INK)
	_line(parent, "%s     ·     %s" % [bow_names[entry.bow][index], gift[index]], sans, 17, Journal.MUTED)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size.y = 247
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(scroll)
	var table := _table(scroll, 3)
	for title in (["Mejora", "Nivel", "Savia invertida"] if es else ["Upgrade", "Rank", "Sap invested"]):
		_line(table, title, sans, 16, Journal.MUTED)
	for id: String in entry.ranks:
		if entry.ranks[id] == 0:
			continue
		var family := Paths.family(id)
		var labels: Array = upgrades.get(family, [id, id])
		var item_name: String = labels[index]
		if id != family and family != "sentinel":
			item_name += " " + str(int(id.get_slice("_step_", 1)))
		_line(table, item_name, sans, 17, Journal.INK, true)
		_line(table, str(entry.ranks[id]), sans, 17, Journal.INK)
		var prices: Array = entry.paid_prices.get(id, [])
		var invested := 0
		for cost: int in prices:
			invested += cost
		_line(table, str(invested) if prices.size() == entry.ranks[id] else "—", sans, 17, Journal.ACCENT)
