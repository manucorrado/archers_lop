extends CanvasLayer

signal start_requested
signal resume_requested
signal restart_requested
signal quit_requested
signal buy_requested(id: String)
signal shop_requested
signal continue_requested
signal next_act_requested
signal save_requested
signal gift_requested(id: String)
signal equip_requested(id: String)
signal settings_changed(options: Dictionary)

const Preferences := preload("res://scripts/play_preferences.gd")
const UpgradeMap := preload("res://scripts/upgrade_map.gd")
const UPGRADES := {
	"damage": ["Daño por flecha", "Arrow damage", "Daño base del arco de rama", "Branch bow base damage"],
	"workshop": ["Taller de flechas", "Arrow workshop", "Producción del taller", "Workshop output"],
	"capacity": ["Carcaj de viaje", "Travel quiver", "Capacidad del carcaj", "Quiver capacity"],
	"rate": ["Velocidad de ataque", "Attack speed", "Cadencia de todos los arcos", "Firing rate for every bow"],
	"weak": ["Ojo de veta", "Grain eye", "Daño al acertar en el punto débil", "Grain target damage"],
	"recurve": ["Arco rápido", "Recurve bow", "Cadencia base del arco", "Bow's base firing rate"],
	"wheel": ["Rueda de savia", "Sap wheel", "Producción por taller", "Production per workshop"],
	"pickup": ["Recogida de hojas", "Leaf gathering", "Radio de recogida", "Pickup radius"],
	"pace": ["Paso del porteador", "Carrier's stride", "Velocidad con 4 o más flechas", "Speed with 4 or more arrows"],
	"spark": ["Chispa de copa", "Canopy spark", "Daño base cada 8 aciertos", "Base damage every 8 hits"],
}
const GIFTS := {
	"D01": ["Pulso de liebre", "Hare's pulse", "Todos tus arcos disparan un 50% más rápido.", "Every bow fires 50% faster."],
	"D03": ["Manantial", "Wellspring", "Cada taller produce un 30% más de flechas.", "Each workshop produces 30% more arrows."],
	"D04": ["Corteza viva", "Living bark", "Tus flechas hacen un 20% más de daño directo.", "Your arrows deal 20% more direct damage."],
	"D08": ["Carcaj profundo", "Deep quiver", "Tenés lugar para 24 flechas más en el carcaj.", "Your quiver holds 24 more arrows."],
	"D09": ["Hojas imantadas", "Magnetic leaves", "Recogés haces desde 2 metros más lejos.", "Collect bundles from 2 metres farther away."],
	"D14": ["Aliento largo", "Long breath", "Tu combo tarda 2 segundos más en empezar a caer.", "Your combo waits 2 more seconds before it starts to fall."],
}

const PAPER := Color("#fff4dc")
const LINEN := Color("#d7d5bb")
const AMBER := Color("#f2bb67")
const INK := Color("#172c27")
const PANEL := Color("#192d28f7")
const EDGE := Color("#627365")

class Sight extends Control:
	var flash := 0.0
	var radius_scale := 1.0

	func _draw() -> void:
		var center := size * 0.5
		for axis in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
			var a: Vector2 = center + axis * 4.0 * radius_scale
			var b: Vector2 = center + axis * 9.0 * radius_scale
			draw_line(a, b, Color("#162921eb"), 3.0, true)
			draw_line(a, b, Color("#fff7dc"), 1.35, true)
		draw_circle(center, 1.35, Color("#fff9dc"))
		if flash > 0.0:
			for diagonal in [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]:
				draw_line(center + diagonal * 6.0, center + diagonal * 11.0,
					Color(1.0, 0.78, 0.39, flash), 2.0, true)

class Cover extends Control:
	var side_only := false

	func _draw() -> void:
		if not side_only:
			draw_rect(Rect2(Vector2.ZERO, size), Color("#101e1bae"))
			return
		var corners := PackedVector2Array([
			Vector2.ZERO, Vector2(size.x, 0), size, Vector2(0, size.y)
		])
		draw_polygon(corners, PackedColorArray([
			Color("#0c1e1af8"), Color("#11221d22"), Color("#11221d22"), Color("#0c1e1af8")
		]))

class Pictogram extends Control:
	var kind: String
	var ink: Color

	func _init(symbol: String, color: Color) -> void:
		kind = symbol
		ink = color
		custom_minimum_size = Vector2(24, 24)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var o := (size - Vector2(24, 24)) * 0.5
		if kind == "sap":
			var points := PackedVector2Array([
				o + Vector2(13, 2), o + Vector2(18, 11), o + Vector2(18, 16),
				o + Vector2(14, 20), o + Vector2(9, 20), o + Vector2(6, 17),
				o + Vector2(6, 12)
			])
			draw_colored_polygon(points, ink)
			draw_line(o + Vector2(9, 13), o + Vector2(11, 10), Color("#fff0bb"), 1.5, true)
		else:
			draw_line(o + Vector2(4, 20), o + Vector2(18, 6), ink, 2.0, true)
			draw_colored_polygon(PackedVector2Array([
				o + Vector2(21, 3), o + Vector2(18, 11), o + Vector2(13, 6)
			]), ink)
			draw_line(o + Vector2(6, 18), o + Vector2(3, 18), ink, 2.0)
			draw_line(o + Vector2(7, 17), o + Vector2(7, 21), ink, 2.0)

var language := "es"
var current_view := "start"
var values: Dictionary = {}
var layer_root: Control
var hud: Control
var overlay: Control
var sight: Sight
var sap_text: Label
var hp_bar: ProgressBar
var hp_text: Label
var stage_text: Label
var ammo_text: Label
var guide_text: Label
var guide_panel: PanelContainer
var toast: Label
var toast_panel: PanelContainer
var shop_sap: Label
var shop_notice: Label
var end_stats: Label
var preferences := Preferences.new()
var options: Dictionary
var combo_text: Label
var combo_hint: Label
var lobes_text: Label
var bow_text: Label
var event_text: Label
var damage_text: Label
var damage_remaining := 0.0
var damage_total := 0
var last_source := ""
var can_continue := false
var submenu := ""
var settings_tab := "comfort"
var settings_notice := ""
var listening := ""
var binding_buttons: Dictionary = {}
var gift_buttons: Dictionary = {}
var selected_gift := ""
var confirm_gift: Button
var start_continue: Button
var start_new: Button
var overlay_notice: Label
var offer_controls: Dictionary = {}
var upgrade_map: UpgradeMap
var selected_upgrade := "damage"
var selected_title: Label
var selected_effect: Label
var selected_requirement: Label
var purchase_upgrade: Button
var ui_font := SystemFont.new()
var title_font := SystemFont.new()
var mono_font := SystemFont.new()
var toast_remaining := 0.0
var hit_remaining := 0.0
var notice_es := ""
var notice_en := ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	ui_font.font_names = PackedStringArray(["Source Sans 3", "Segoe UI", "Arial"])
	title_font.font_names = PackedStringArray(["Gloock", "Georgia", "Times New Roman"])
	mono_font.font_names = PackedStringArray(["IBM Plex Mono", "Consolas", "Courier New"])
	preferences.load_settings()
	language = preferences.language
	TranslationServer.set_locale("es_AR" if language == "es" else "en")
	options = preferences.options
	layer_root = Control.new()
	add_child(layer_root)
	layer_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_hud()
	set_view(current_view)

func _t(es: String, en: String) -> String:
	return es if language == "es" else en

func _box(color: Color, border: Color, margin_x: int, margin_y: int, roundness := 4) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(roundness)
	style.content_margin_left = margin_x
	style.content_margin_right = margin_x
	style.content_margin_top = margin_y
	style.content_margin_bottom = margin_y
	return style

func _panel(parent: Control, background: Color, border: Color, mx: int, my: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _box(background, border, mx, my))
	parent.add_child(panel)
	return panel

func _stack(parent: Control, gap: int) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", gap)
	parent.add_child(box)
	return box

func _row(parent: Control, gap: int) -> HBoxContainer:
	var box := HBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", gap)
	parent.add_child(box)
	return box

func _label(parent: Control, caption: String, pixels: int, color: Color, font: Font = null) -> Label:
	var label := Label.new()
	label.text = caption
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", font if font != null else ui_font)
	label.add_theme_font_size_override("font_size", pixels)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _button(parent: Control, caption: String, primary: bool, action: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.custom_minimum_size.y = 40
	button.add_theme_font_override("font", ui_font)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", INK if primary else PAPER)
	button.add_theme_color_override("font_hover_color", INK if primary else Color.WHITE)
	button.add_theme_color_override("font_pressed_color", INK if primary else AMBER)
	button.add_theme_color_override("font_focus_color", INK if primary else PAPER)
	button.add_theme_stylebox_override("normal", _box(AMBER if primary else Color("#243731"), AMBER if primary else EDGE, 18, 6))
	button.add_theme_stylebox_override("hover", _box(Color("#ffd891") if primary else Color("#354a40"), AMBER, 18, 6))
	button.add_theme_stylebox_override("pressed", _box(Color("#d9a75d") if primary else INK, AMBER, 18, 6))
	var focus := _box(Color.TRANSPARENT, PAPER, 0, 0)
	focus.set_border_width_all(2)
	button.add_theme_stylebox_override("focus", focus)
	parent.add_child(button)
	button.pressed.connect(action)
	return button

func _place(item: Control, anchor_x: float, anchor_y: float, left: float, top: float, right: float, bottom: float) -> void:
	item.set_anchor(SIDE_LEFT, anchor_x)
	item.set_anchor(SIDE_RIGHT, anchor_x)
	item.set_anchor(SIDE_TOP, anchor_y)
	item.set_anchor(SIDE_BOTTOM, anchor_y)
	item.offset_left = left
	item.offset_right = right
	item.offset_top = top
	item.offset_bottom = bottom

func _build_hud() -> void:
	hud = Control.new()
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer_root.add_child(hud)
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var wallet := _panel(hud, Color("#162720e8"), Color("#73807495"), 14, 5)
	_place(wallet, 0, 0, 24, 22, 143, 70)
	var wallet_row := _row(wallet, 8)
	wallet_row.add_child(Pictogram.new("sap", AMBER))
	var wallet_values := _stack(wallet_row, -3)
	_label(wallet_values, _t("SAVIA", "SAP"), 11, LINEN, mono_font)
	sap_text = _label(wallet_values, "", 20, AMBER, mono_font)
	var combo_panel := _panel(hud, Color("#162720e8"), Color("#73807495"), 12, 5)
	_place(combo_panel, 1, 0, -180, 22, -24, 75)
	var combo_col := _stack(combo_panel, 0)
	combo_text = _label(combo_col, "", 18, AMBER, mono_font)
	combo_hint = _label(combo_col, "", 12, LINEN)

	var target := _panel(hud, Color("#14251de3"), Color("#73807495"), 13, 6)
	_place(target, 0.5, 0, -154, 22, 154, 75)
	var target_col := _stack(target, 4)
	var target_row := _row(target_col, 8)
	stage_text = _label(target_row, "", 16, PAPER, mono_font)
	stage_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hp_text = _label(target_row, "", 14, LINEN, mono_font)
	hp_bar = ProgressBar.new()
	hp_bar.show_percentage = false
	hp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_bar.custom_minimum_size.y = 5
	hp_bar.add_theme_stylebox_override("background", _box(Color("#35463b"), Color.TRANSPARENT, 0, 0, 1))
	hp_bar.add_theme_stylebox_override("fill", _box(AMBER, Color.TRANSPARENT, 0, 0, 1))
	target_col.add_child(hp_bar)
	lobes_text = _label(target_col, "", 14, PAPER, mono_font)
	lobes_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sight = Sight.new()
	sight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(sight)
	_place(sight, 0.5, 0.5, -16, -16, 16, 16)
	sight.radius_scale = options.reticle_size
	damage_text = _label(hud, "", 20, AMBER, mono_font)
	damage_text.add_theme_constant_override("outline_size", 5)
	damage_text.add_theme_color_override("font_outline_color", INK)
	_place(damage_text, 0.5, 0.5, 24, -36, 240, -8)
	damage_text.hide()
	event_text = _label(hud, "", 16, PAPER, mono_font)
	event_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	event_text.add_theme_constant_override("outline_size", 5)
	event_text.add_theme_color_override("font_outline_color", INK)
	_place(event_text, 1, 0, -330, 86, -24, 125)

	var quiver := _panel(hud, Color("#182820e8"), Color("#73807495"), 14, 5)
	_place(quiver, 0.0, 1.0, 24, -85, 205, -24)
	var quiver_row := _row(quiver, 8)
	quiver_row.add_child(Pictogram.new("arrow", PAPER))
	var quiver_values := _stack(quiver_row, -3)
	bow_text = _label(quiver_values, "", 12, LINEN)
	ammo_text = _label(quiver_values, "", 20, PAPER, mono_font)

	guide_panel = _panel(hud, Color("#182820e8"), Color("#73807495"), 13, 7)
	_place(guide_panel, 0.5, 1.0, -225, -65, 225, -24)
	guide_text = _label(guide_panel, "", 16, PAPER)
	guide_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	guide_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	toast_panel = _panel(hud, Color("#20372ff2"), Color("#b19363"), 12, 5)
	_place(toast_panel, 0.5, 0.0, -235, 109, 235, 146)
	toast = _label(toast_panel, "", 16, PAPER)
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_panel.hide()

func set_view(view: String) -> void:
	current_view = view
	submenu = ""
	listening = ""
	selected_gift = ""
	if is_instance_valid(layer_root):
		_render_view()

func is_submenu_open() -> bool:
	return not submenu.is_empty()

func set_can_continue(enabled: bool) -> void:
	if can_continue == enabled:
		return
	can_continue = enabled
	if current_view == "start" and not is_submenu_open() and is_instance_valid(overlay):
		_render_view()

func _open_submenu(name_: String) -> void:
	submenu = name_
	listening = ""
	settings_notice = ""
	_render_view()

func _render_view() -> void:
	if is_instance_valid(overlay):
		overlay.hide()
		layer_root.remove_child(overlay)
		overlay.queue_free()
	overlay = null
	shop_sap = null
	shop_notice = null
	overlay_notice = null
	end_stats = null
	start_new = null
	start_continue = null
	confirm_gift = null
	offer_controls.clear()
	gift_buttons.clear()
	binding_buttons.clear()
	hud.visible = current_view == "play" and submenu.is_empty()
	if not hud.visible:
		_build_overlay()
	_update_values()

func _build_overlay() -> void:
	var cover := Cover.new()
	cover.side_only = current_view == "start" and submenu.is_empty()
	cover.mouse_filter = Control.MOUSE_FILTER_STOP
	layer_root.add_child(cover)
	cover.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay = cover
	var language_btn := _button(cover, _t("English", "Español"), false, _switch_language)
	_place(language_btn, 1, 0, -145, 15, -20, 54)
	if cover.side_only:
		_build_start(cover)
		return
	var holder := CenterContainer.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cover.add_child(holder)
	holder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var card := _panel(holder, PANEL, EDGE, 23, 17)
	var wide := submenu in ["settings", "test_times"] or (submenu.is_empty() and current_view in ["gift", "shop"])
	card.custom_minimum_size.x = 880 if wide else 500
	var content := _stack(card, 10)
	if submenu == "settings":
		_build_settings(content)
	elif submenu == "test_times":
		_build_test_times(content)
	elif submenu == "confirm_new":
		_build_confirmation(content)
	elif current_view == "shop":
		_build_shop(content)
	elif current_view == "gift":
		_build_gifts(content)
	elif current_view == "end":
		_build_end(content)
	else:
		_label(content, _t("Pausa", "Paused"), 41, PAPER, title_font)
		var back := _button(content, _t("Volver al claro", "Resume"), true, resume_requested.emit)
		_button(content, _t("Guardar partida", "Save game"), false, save_requested.emit)
		if values.get("gift_offer", []).is_empty():
			_button(content, _t("Mejoras", "Upgrades"), false, shop_requested.emit)
		_button(content, _t("Ajustes", "Settings"), false, _open_submenu.bind("settings"))
		_button(content, _t("Nueva partida", "New game"), false, _open_submenu.bind("confirm_new"))
		_button(content, _t("Guardar y salir", "Save and quit"), false, quit_requested.emit)
		back.grab_focus()
	overlay_notice = _label(content, "", 16, AMBER)
	overlay_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay_notice.hide()
	language_btn.move_to_front()

func _build_start(parent: Control) -> void:
	var content := _stack(parent, 15)
	_place(content, 0.075, 0.5, 0, -176, 535, 176)
	var title := _label(content, _t("El arquero\ndel claro", "Archer of\nthe Clearing"), 65, PAPER, title_font)
	title.add_theme_constant_override("line_spacing", -9)
	var description := _label(content, _t(
		"Rompé diez blancos de madera. Elegí cómo mejorar tu arco y buscá los puntos débiles de los dos jefes.",
		"Break ten wooden targets. Upgrade your bow and find the weak points on both bosses."
	), 20, LINEN)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var actions := _row(content, 9)
	if can_continue:
		start_continue = _button(actions, _t("Continuar", "Continue"), true, continue_requested.emit)
		start_new = _button(actions, _t("Nueva partida", "New game"), false, _open_submenu.bind("confirm_new"))
		start_continue.grab_focus()
	else:
		start_new = _button(actions, _t("Entrar al claro", "Enter the clearing"), true, start_requested.emit)
		start_new.grab_focus()
	_button(actions, _t("Ajustes", "Settings"), false, _open_submenu.bind("settings"))
	_button(actions, _t("Salir", "Quit"), false, quit_requested.emit)
	overlay_notice = _label(content, "", 16, AMBER)
	overlay_notice.hide()

func _build_confirmation(content: Control) -> void:
	_label(content, _t("¿Empezar de nuevo?", "Start a new game?"), 33, PAPER, title_font)
	var explanation := _label(content, _t(
		"Se reemplazará la partida del claro, incluidas tus compras y la recompensa que elegiste. Tus ajustes se conservan.",
		"This will replace your clearing, upgrades and gift. Your settings will carry over."
	), 18, LINEN)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_button(content, _t("Conservar partida", "Keep this run"), true, _open_submenu.bind("")).grab_focus()
	_button(content, _t("Empezar de nuevo", "Start over"), false, restart_requested.emit)

func _scroll_column(parent: Control, height: int) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size.y = height
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	parent.add_child(scroll)
	var column := _stack(scroll, 7)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return column

func _build_shop(content: Control) -> void:
	var heading := _row(content, 20)
	var title := _label(heading, _t("Árbol de mejoras", "Upgrade tree"), 36, PAPER, title_font)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_sap = _label(heading, "", 17, AMBER, mono_font)
	var layout := _row(content, 14)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(548, 382)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.follow_focus = true
	layout.add_child(scroll)
	upgrade_map = UpgradeMap.new()
	scroll.add_child(upgrade_map)
	var available: Dictionary = values.get("offers", {})
	for id: String in UPGRADES:
		if available.has(id):
			var node := _button(upgrade_map, "", false, _select_upgrade.bind(id))
			node.add_theme_font_size_override("font_size", 14)
			node.add_theme_stylebox_override("hover", _box(Color("#354a40"), AMBER, 4, 2))
			node.clip_text = true
			upgrade_map.buttons[id] = node
			offer_controls[id] = node
	upgrade_map.arrange(available)
	var details_panel := _panel(layout, Color("#263b32"), EDGE, 14, 12)
	details_panel.custom_minimum_size.x = 244
	var details := _stack(details_panel, 10)
	selected_title = _label(details, "", 25, PAPER, title_font)
	selected_effect = _label(details, "", 17, LINEN)
	selected_requirement = _label(details, "", 15, LINEN)
	for caption in [selected_title, selected_effect, selected_requirement]:
		caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selected_requirement.size_flags_vertical = Control.SIZE_EXPAND_FILL
	purchase_upgrade = _button(details, "", true, func(): buy_requested.emit(selected_upgrade))
	purchase_upgrade.add_theme_font_size_override("font_size", 16)
	purchase_upgrade.add_theme_stylebox_override("disabled", _box(INK, EDGE, 8, 6))
	var equipment := _row(content, 10)
	var branch := _button(equipment, _t("Equipar arco de rama", "Equip branch bow"), false, equip_requested.emit.bind("branch"))
	branch.disabled = values.get("bow", "branch") == "branch"
	var recurve := _button(equipment, _t("Equipar arco rápido", "Equip recurve"), false, equip_requested.emit.bind("recurve"))
	recurve.disabled = not bool(available.get("recurve", {}).get("rank", 0)) or not branch.disabled
	branch.name = "EquipBranch"
	recurve.name = "EquipRecurve"
	shop_notice = _label(content, "", 16, AMBER)
	shop_notice.hide()
	_button(content, _t("Volver al claro", "Return to the clearing"), false, resume_requested.emit)
	if offer_controls.has(selected_upgrade):
		offer_controls[selected_upgrade].grab_focus()

func _select_upgrade(id: String) -> void:
	selected_upgrade = id
	shop_notice.hide()
	_update_values()

func _upgrade_name(id: String) -> String:
	var item: Array = UPGRADES[id]
	return _t(item[0], item[1])

func _build_gifts(content: Control) -> void:
	_label(content, _t("Elegí una mejora", "Choose a reward"), 37, PAPER, title_font)
	var first_boss := int(values.get("stage", 5)) == 5
	_label(content, _t("Rompiste los dos lados del tronco. Elegí qué mejora llevarte.", "You broke both sides of the split trunk. Choose an upgrade to keep.") if first_boss else _t("Venciste al segundo jefe. Elegí tu recompensa final.", "You defeated the second boss. Choose your final reward."), 18, LINEN)
	var cards := _row(content, 10)
	for id in values.get("gift_offer", []):
		if not GIFTS.has(id):
			continue
		var data: Array = GIFTS[id]
		var card := _panel(cards, Color("#283d33"), EDGE, 12, 12)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.custom_minimum_size = Vector2(245, 172)
		var col := _stack(card, 10)
		_label(col, _t(data[0], data[1]), 23, PAPER, title_font)
		var effect := _label(col, _t(data[2], data[3]), 17, LINEN)
		effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		effect.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var pick := _button(col, "", false, _select_gift.bind(id))
		pick.accessibility_name = _t(data[0], data[1]) + ". " + effect.text
		gift_buttons[id] = pick
	confirm_gift = _button(content, _t("Confirmar mejora", "Confirm reward"), true, _commit_gift)
	_select_gift(selected_gift)
	var actions := _row(content, 9)
	_button(actions, _t("Guardar", "Save"), false, save_requested.emit)
	_button(actions, _t("Ajustes", "Settings"), false, _open_submenu.bind("settings"))
	_button(actions, _t("Guardar y salir", "Save and quit"), false, quit_requested.emit)
	if not gift_buttons.is_empty():
		gift_buttons.values()[0].grab_focus()

func _select_gift(id: String) -> void:
	selected_gift = id if gift_buttons.has(id) else ""
	for key in gift_buttons:
		gift_buttons[key].text = _t("Seleccionado", "Selected") if key == selected_gift else _t("Seleccionar", "Select")
	confirm_gift.disabled = selected_gift.is_empty()

func _commit_gift() -> void:
	if selected_gift.is_empty() or confirm_gift.disabled:
		return
	confirm_gift.disabled = true
	gift_requested.emit(selected_gift)

func _build_end(content: Control) -> void:
	var first_act := int(values.get("stage", 5)) == 5
	_label(content, _t("Primer acto completado", "First act complete") if first_act else _t("El claro es tuyo", "The clearing is yours"), 38, PAPER, title_font)
	_label(content, _t("Cinco blancos rotos", "Five targets broken") if first_act else _t("Diez blancos rotos", "Ten targets broken"), 18, LINEN)
	end_stats = _label(content, "", 16, PAPER)
	end_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	end_stats.add_theme_constant_override("line_spacing", 5)
	_button(content, _t("Ver tiempos de la prueba", "View playtest times"), false, _open_submenu.bind("test_times"))
	var replay := _button(content, _t("Volver a jugar", "Play again"), not first_act, _open_submenu.bind("confirm_new"))
	if first_act:
		var proceed := _button(content, _t("Continuar al blanco 6", "Continue to target 6"), true, next_act_requested.emit)
		content.move_child(proceed, 3)
		proceed.grab_focus()
	else:
		replay.grab_focus()
	_button(content, _t("Ajustes", "Settings"), false, _open_submenu.bind("settings"))
	_button(content, _t("Salir", "Quit"), false, quit_requested.emit)

func _build_test_times(content: Control) -> void:
	_label(content, _t("Tiempos de la prueba", "Playtest times"), 33, PAPER, title_font)
	var explanation := _label(content, _t(
		"El tiempo observado cuenta desde que empezaste a jugar e incluye los menús y las pausas. Ambos relojes se detienen al cerrar el juego.",
		"Observed time starts when you enter the clearing and includes menus and pauses. Both clocks stop when you close the game."
	), 17, LINEN)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var table := GridContainer.new()
	table.columns = 3
	table.add_theme_constant_override("h_separation", 22)
	table.add_theme_constant_override("v_separation", 8)
	content.add_child(table)
	_label(table, _t("Momento", "Milestone"), 16, LINEN).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label(table, _t("Tiempo observado", "Observed time"), 16, LINEN)
	_label(table, _t("Juego activo", "Active play"), 16, LINEN)
	var session_marks: Dictionary = values.get("session_observations", {})
	var active_marks: Dictionary = values.get("observations", {})
	var milestones := {
		"first_hit": _t("Primer acierto", "First hit"),
		"first_purchase": _t("Primera compra", "First purchase"),
		"first_paid_purchase": _t("Primera compra con savia", "First paid purchase"),
		"first_production_pickup": _t("Primera recogida del taller", "First workshop pickup"),
		"returned_empty_to_workshop": _t("Volviste al taller sin flechas", "Returned to the workshop empty"),
		"fired_after_collection": _t("Disparaste tras recoger flechas", "Fired after collecting arrows"),
	}
	for id in milestones:
		_label(table, milestones[id], 17, PAPER)
		_label(table, _mark_time(session_marks, id), 16, AMBER)
		_label(table, _mark_time(active_marks, id), 16, PAPER)
	_button(content, _t("Volver al resumen", "Back to results"), true, _open_submenu.bind("")).grab_focus()

func _mark_time(marks: Dictionary, id: String) -> String:
	if marks.has(id):
		return _number(marks[id], 1) + " s"
	return _t("Sin registrar", "Not recorded")

func _switch_language() -> void:
	language = "en" if language == "es" else "es"
	TranslationServer.set_locale("es_AR" if language == "es" else "en")
	preferences.language = language
	_save_options()
	layer_root.remove_child(hud)
	hud.queue_free()
	_build_hud()
	settings_notice = ""
	listening = ""
	_render_view()

func refresh(state: Dictionary) -> void:
	var old := values
	values = state
	if state.has("has_save"):
		set_can_continue(bool(state.has_save))
	if not is_instance_valid(layer_root):
		return
	if current_view == "gift" and submenu.is_empty() and old.get("gift_offer", []) != state.get("gift_offer", []):
		_render_view()
		return
	if current_view == "shop" and is_instance_valid(shop_notice):
		var offers: Dictionary = state.get("offers", {})
		for id in offers:
			var before: int = old.get("offers", {}).get(id, {}).get("rank", 0)
			if int(offers[id].get("rank", 0)) > before:
				shop_notice.text = _t("Compraste %s.", "Purchased %s.") % _upgrade_name(id)
				shop_notice.show()
				break
	_update_values()

func _update_values() -> void:
	if not submenu.is_empty():
		return
	if current_view == "play":
		_update_hud()
	elif current_view == "shop" and is_instance_valid(shop_sap):
		var ranks := 0
		var maximum := 0
		for id in offer_controls:
			var offer: Dictionary = values.get("offers", {}).get(id, {})
			ranks += int(offer.get("rank", 0))
			maximum += int(offer.get("max_rank", 0))
			_update_offer(id, offer)
		upgrade_map.queue_redraw()
		shop_sap.text = _t("%d savia  ·  %d/%d niveles", "%d sap  ·  %d/%d levels") % [values.get("sap", 0), ranks, maximum]
		var branch: Button = overlay.find_child("EquipBranch", true, false)
		var recurve: Button = overlay.find_child("EquipRecurve", true, false)
		branch.disabled = values.get("bow", "branch") == "branch"
		recurve.disabled = int(values.get("offers", {}).get("recurve", {}).get("rank", 0)) < 1 or not branch.disabled
	elif current_view == "end" and is_instance_valid(end_stats):
		var elapsed := int(values.get("elapsed", 0))
		var gift: Array = GIFTS.get(str(values.get("chosen_gift", "")), ["—", "—", "", ""])
		end_stats.text = _t("Tiempo activo     %d:%02d\nAciertos     %d / %d\nFlechas recogidas del taller     %d\nMejor combo     ×%s\nRecompensa     %s\n%s",
			"Active time     %d:%02d\nHits     %d / %d\nArrows collected from the workshop     %d\nBest combo     ×%s\nReward     %s\n%s") % [
			floori(elapsed / 60.0), elapsed % 60, values.get("hits", 0), values.get("shots", 0),
			values.get("collected", 0), _number(values.get("max_combo", 1.0), 2), _t(gift[0], gift[1]), _t(gift[2], gift[3])]
		end_stats.text += "\n" + _reward_result(str(values.get("chosen_gift", "")))

func _reward_result(id: String) -> String:
	match id:
		"D01": return _t("Cadencia actual · %s flechas/s", "Current firing rate · %s arrows/s") % _number(values.shot_rate, 2)
		"D03": return _t("Producción actual · %s flechas/s", "Current production · %s arrows/s") % _number(values.production_rate, 2)
		"D04": return _t("Daño por flecha al tronco · %d", "Arrow damage to the trunk · %d") % values.damage
		"D08": return _t("Capacidad actual · %d flechas", "Current capacity · %d arrows") % values.capacity
		"D09": return _t("Distancia de recogida · %s m", "Pickup distance · %s m") % _number(values.pickup_radius, 2)
		"D14": return _t("El combo empieza a caer tras %s s", "Combo starts falling after %s s") % _number(values.combo_delay, 1)
	return ""

func _update_hud() -> void:
	var stage := int(values.get("stage", 1))
	var ammo := int(values.get("arrows", 24))
	sap_text.text = str(values.get("sap", 0))
	stage_text.text = _t("BLANCO %d DE 10", "TARGET %d OF 10") % stage
	hp_text.text = "%d / %d" % [values.get("hp", 160), values.get("max_hp", 160)]
	hp_bar.max_value = maxi(1, int(values.get("max_hp", 160)))
	hp_bar.value = values.get("hp", 160)
	lobes_text.visible = values.get("split", false)
	if lobes_text.visible:
		lobes_text.text = _t("Izq. %d  ·  Der. %d", "Left %d  ·  Right %d") % [values.get("left_hp", 0), values.get("right_hp", 0)]
	bow_text.text = _t("ARCO RÁPIDO", "RECURVE BOW") if values.get("bow", "branch") == "recurve" else _t("ARCO DE RAMA", "BRANCH BOW")
	ammo_text.text = "%d / %d" % [ammo, values.get("capacity", 24)]
	ammo_text.modulate = AMBER if ammo == 0 else Color.WHITE
	var combo := float(values.get("combo", 1.0))
	combo_text.text = "Combo  ×" + _number(combo, 2)
	combo_hint.visible = combo > 1.001
	combo_hint.text = _t("En descenso", "Falling") if float(values.get("combo_grace", 0.0)) <= 0 else _t("En racha", "Streak active")
	event_text.visible = str(values.get("event", "")) == "seed_rain"
	if event_text.visible:
		event_text.text = _t("Lluvia de semillas · %d s", "Seed rain · %d s") % ceili(values.get("event_remaining", 0.0))
	var guide := _guide()
	guide_panel.visible = not guide.is_empty()
	guide_text.text = guide

func _guide() -> String:
	if values.get("split", false) and int(values.get("hp", 0)) > 0:
		if int(values.get("left_hp", 0)) == 0:
			return _t("Rompé la mitad derecha.", "Break the right half.")
		if int(values.get("right_hp", 0)) == 0:
			return _t("Rompé la mitad izquierda.", "Break the left half.")
		return _t("¡Se partió! Disparale a cada mitad del tronco.", "It split! Shoot both halves of the trunk.")
	if int(values.get("stage", 1)) == 10:
		if values.get("core_needs_hit", false):
			if int(values.get("arrows", 0)) == 0:
				return _t("%s · Golpeá la raíz del hueco encendido.", "%s · Strike the root below the glowing hollow.") % preferences.binding_name("strike")
			return _t("¡Ahí! Pegale al hueco encendido para romper esta parte.", "Hit the glowing hollow to break this section.")
		return _t("Seguí la marca encendida. Cambia de lugar con los impactos.", "Follow the glowing mark. It moves as you damage the trunk.")
	if values.get("fired_after_collect", false):
		return ""
	var shoot := preferences.binding_name("shoot")
	var shop := preferences.binding_name("shop")
	if int(values.get("collected", 0)) > 0:
		return _t("%s · Volvé a disparar con las flechas del taller.", "%s · Fire again with the workshop arrows.") % shoot
	if int(values.get("arrows", 24)) == 0:
		if int(values.get("workshop_stock", 0)) > 0:
			return _t("Buscá en el suelo las flechas que lanzó el taller.", "Look on the ground for the arrows launched by the workshop.")
		if int(values.get("knot_stock", 0)) > 0:
			return _t("Recogé las flechas al pie del tronco.", "Collect the arrows at the foot of the trunk.")
		return _t("%s · Acercate al tronco y golpeá con la rama.", "%s · Get close to the trunk and strike it.") % preferences.binding_name("strike")
	if values.get("workshop", false):
		if int(values.get("arrows", 0)) >= int(values.get("capacity", 24)):
			return _t("%s · Dispará para hacer lugar en el carcaj.", "%s · Shoot to make room in your quiver.") % shoot
		return _t("Seguí el atado que lanza el taller y recogelo donde caiga.", "Follow a bundle from the workshop and collect it where it lands.")
	if values.get("offers", {}).get("workshop", {}).get("available", false):
		return _t("%s · Construí tu taller de flechas.", "%s · Build your arrow workshop.") % shop
	if int(values.get("damage_rank", 0)) == 0 and values.get("offers", {}).get("damage", {}).get("available", false):
		return _t("%s · Obtené gratis tu primer nivel de daño.", "%s · Claim your first damage level for free.") % shop
	if int(values.get("shots", 0)) < 1:
		return _t("%s · Apuntá al tronco y dispará.", "%s · Aim at the trunk and shoot.") % shoot
	return ""

func _number(number: float, precision: int = 1) -> String:
	if is_equal_approx(number, roundf(number)):
		return str(roundi(number))
	var result := String.num(number, precision)
	return result.replace(".", ",") if language == "es" else result

func _effect(id: String, offer: Dictionary) -> String:
	var words: Array = UPGRADES[id]
	var current := float(offer.get("current", 0))
	var next := float(offer.get("next", current))
	var suffix := ""
	var prefix := ""
	match id:
		"recurve", "workshop", "wheel":
			suffix = _t(" flechas/s", " arrows/s")
		"capacity":
			suffix = _t(" flechas", " arrows")
		"rate", "pace":
			prefix = "+"
			suffix = "%"
		"weak":
			prefix = "×"
		"pickup":
			suffix = " m"
	var first := (prefix if current != 0 else "") + _number(current, 2)
	var second := prefix + _number(next, 2)
	var change := second if bool(offer.get("maxed", false)) else first + " → " + second
	return _t(words[2], words[3]) + "  " + change + suffix

func _update_offer(id: String, offer: Dictionary) -> void:
	var node: Button = offer_controls[id]
	var rank := int(offer.get("rank", 0))
	var max_rank := int(offer.get("max_rank", 1))
	var cost := int(offer.get("cost", 0))
	var gate := int(offer.get("stage", 1))
	var met := bool(offer.get("requirement_met", true))
	var stage_met := int(values.get("stage", 1)) >= gate
	var name_tag := _upgrade_name(id)
	var level := _t("Nivel %d/%d", "Level %d/%d") % [rank, max_rank]
	var status := level
	if rank == 0:
		if not met:
			status = _t("Bloqueada", "Locked")
		elif not stage_met:
			status = _t("Blanco %d", "Target %d") % gate
		elif cost == 0:
			status = _t("Gratis", "Free")
	node.text = name_tag + "\n" + status
	var parent := str(offer.get("requires", ""))
	upgrade_map.unlocked_edges[id] = met
	var fill := Color("#314c3c") if rank > 0 or bool(offer.available) else Color("#20312b")
	var edge := AMBER if id == selected_upgrade or bool(offer.available) else EDGE
	node.add_theme_stylebox_override("normal", _box(fill, edge, 3, 2))
	node.add_theme_color_override("font_color", PAPER if met and stage_met else LINEN)
	node.accessibility_name = name_tag + ". " + status
	if id != selected_upgrade:
		return
	selected_title.text = name_tag
	selected_effect.text = _effect(id, offer)
	var lines: PackedStringArray = [level]
	if UPGRADES.has(parent):
		lines.append(_t("Requiere %s", "Requires %s") % _upgrade_name(parent))
	if not stage_met:
		lines.append(_t("Se habilita en el blanco %d", "Unlocks at target %d") % gate)
	if not bool(offer.maxed) and cost > 0:
		var balance := int(values.get("sap", 0)) - cost
		lines.append(_t("Te quedarían %d de savia", "%d sap after purchase") % balance if balance >= 0 else _t("Te faltan %d de savia", "Need %d more sap") % -balance)
	selected_requirement.text = "\n".join(lines)
	purchase_upgrade.disabled = not bool(offer.get("available", false))
	if bool(offer.maxed):
		purchase_upgrade.text = _t("Completo", "Complete")
	elif cost == 0:
		purchase_upgrade.text = _t("Obtener gratis", "Claim for free")
	else:
		purchase_upgrade.text = _t("Comprar · %d savia", "Buy · %d sap") % cost


func _build_settings(content: Control) -> void:
	_label(content, _t("Ajustes", "Settings"), 35, PAPER, title_font)
	var tabs := _row(content, 8)
	var tab_names := {
		"comfort": _t("Vista y lectura", "View and readability"),
		"controls": _t("Controles", "Controls"),
		"audio": _t("Sonido", "Audio"),
	}
	for tab in tab_names:
		var button := _button(tabs, tab_names[tab], tab == settings_tab, _change_tab.bind(tab))
		if settings_tab == tab:
			button.grab_focus()
	var column := _scroll_column(content, 328)
	if settings_tab == "comfort":
		_slider(column, "fov", _t("Campo de visión", "Field of view"), 55, 105, 1, "°")
		_slider(column, "zoom", _t("Acercamiento al apuntar", "Aiming zoom"), 0, 1, 0.05, "%")
		_slider(column, "shake", _t("Balanceo y vibración", "Sway and shake"), 0, 1, 0.05, "%")
		_slider(column, "flashes", _t("Intensidad de los destellos", "Flash intensity"), 0, 1, 0.05, "%")
		_slider(column, "reticle_size", _t("Tamaño de la mira", "Crosshair size"), 0.5, 2, 0.1, "%")
		_slider(column, "damage_opacity", _t("Visibilidad de los números de daño", "Damage number opacity"), 0, 1, 0.05, "%")
		_toggle(column, "group_damage", _t("Agrupar el daño de impactos seguidos", "Group damage from successive hits"))
	elif settings_tab == "audio":
		_slider(column, "volume_bow", _t("Arco y rama", "Bow and branch"), 0, 1, 0.05, "%")
		_slider(column, "volume_world", _t("Claro, impactos y recogidas", "Clearing, hits and pickups"), 0, 1, 0.05, "%")
		_slider(column, "volume_ui", _t("Compras y menús", "Purchases and menus"), 0, 1, 0.05, "%")
	else:
		_slider(column, "sensitivity", _t("Sensibilidad del mouse", "Mouse sensitivity"), 0.2, 3, 0.1, "%")
		_toggle(column, "toggle_fire", _t("Un clic inicia o detiene el disparo repetido", "Click to start or stop repeated fire"))
		for action in preferences.bindings:
			var row := _row(column, 12)
			var labels: Array = Preferences.ACTION_NAMES[action]
			var name_label := _label(row, _t(labels[0], labels[1]), 17, PAPER)
			name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var key_button := _button(row, preferences.binding_name(action), false, _listen.bind(action))
			key_button.custom_minimum_size.x = 190
			binding_buttons[action] = key_button
		_button(column, _t("Restablecer teclas y botones", "Reset key and mouse bindings"), false, _reset_bindings)
	var status := _label(content, settings_notice, 15, AMBER)
	status.name = "PreferencesNotice"
	status.visible = not settings_notice.is_empty()
	_button(content, _t("Volver", "Back"), true, _open_submenu.bind(""))

func _change_tab(tab: String) -> void:
	settings_tab = tab
	listening = ""
	settings_notice = ""
	_render_view()

func _slider(parent: Control, id: String, title: String, minimum: float, maximum: float, step_size: float, unit: String) -> void:
	var row := _row(parent, 12)
	row.custom_minimum_size.y = 35
	var caption := _label(row, title, 17, PAPER)
	caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var slider := HSlider.new()
	slider.name = id.to_pascal_case()
	slider.accessibility_name = title
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = step_size
	slider.value = options[id]
	slider.custom_minimum_size.x = 220
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	row.add_child(slider)
	var value := _label(row, _setting_value(slider.value, unit), 16, AMBER, mono_font)
	value.custom_minimum_size.x = 70
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	slider.value_changed.connect(func(v: float):
		value.text = _setting_value(v, unit)
		options[id] = v
		_change_options()
	)

func _setting_value(value: float, unit: String) -> String:
	return str(roundi(value * 100 if unit == "%" else value)) + unit

func _toggle(parent: Control, id: String, caption: String) -> void:
	var check := CheckButton.new()
	check.text = caption
	check.accessibility_name = caption
	check.name = id.to_pascal_case()
	check.custom_minimum_size.y = 40
	check.button_pressed = options[id]
	check.add_theme_font_override("font", ui_font)
	check.add_theme_font_size_override("font_size", 17)
	check.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	parent.add_child(check)
	check.toggled.connect(func(on: bool):
		options[id] = on
		_change_options()
	)

func _change_options() -> void:
	sight.radius_scale = float(options.reticle_size)
	sight.queue_redraw()
	if float(options.damage_opacity) <= 0.0:
		damage_text.hide()
	settings_changed.emit(options)
	_save_options()

func _save_options() -> void:
	if preferences.persist() != OK:
		_settings_status(_t("No se pudieron guardar los ajustes en este equipo.", "Could not save settings on this computer."))

func _settings_status(message: String) -> void:
	settings_notice = message
	var label: Label = overlay.find_child("PreferencesNotice", true, false) if is_instance_valid(overlay) else null
	if is_instance_valid(label):
		label.text = message
		label.visible = not message.is_empty()

func _listen(action: String) -> void:
	listening = action
	binding_buttons[action].text = _t("Esperando…", "Listening…")
	_settings_status(_t("Pulsá una tecla o botón del mouse. Esc cancela.", "Press a key or mouse button. Esc cancels."))

func _input(event: InputEvent) -> void:
	if submenu.is_empty():
		return
	if not listening.is_empty():
		var code := 0
		if event is InputEventKey and event.pressed and not event.echo:
			code = event.physical_keycode if event.physical_keycode else event.keycode
		elif event is InputEventMouseButton and event.pressed:
			code = -event.button_index
		else:
			return
		get_viewport().set_input_as_handled()
		var action := listening
		if code == KEY_ESCAPE:
			listening = ""
			binding_buttons[action].text = preferences.binding_name(action)
			_settings_status("")
			return
		var conflict = preferences.bindings.find_key(code)
		if conflict != null and str(conflict) != action:
			var names: Array = Preferences.ACTION_NAMES[conflict]
			_settings_status(_t("Ya se usa para «%s». Elegí otra tecla o botón.", "Already used for “%s”. Choose another key or button.") % _t(names[0], names[1]))
			return
		if code < -9 or code == 0:
			return
		if code in [-MOUSE_BUTTON_WHEEL_DOWN, -MOUSE_BUTTON_WHEEL_UP, -MOUSE_BUTTON_WHEEL_LEFT, -MOUSE_BUTTON_WHEEL_RIGHT] and action in ["aim", "move_forward", "move_back", "move_left", "move_right"]:
			_settings_status(_t("Esta acción necesita una tecla o botón que puedas mantener pulsado.", "This action needs a key or button you can hold down."))
			return
		preferences.bindings[action] = code
		preferences.apply_bindings()
		_save_options()
		listening = ""
		binding_buttons[action].text = preferences.binding_name(action)
		_settings_status("")
		return
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		_open_submenu("")

func _reset_bindings() -> void:
	preferences.bindings = Preferences.DEFAULT_BINDINGS.duplicate()
	preferences.apply_bindings()
	_save_options()
	for action in binding_buttons:
		binding_buttons[action].text = preferences.binding_name(action)
	_settings_status(_t("Restableciste las teclas y botones originales.", "Default key and mouse bindings restored."))

func notify(es: String, en: String) -> void:
	notice_es = es
	notice_en = en
	toast_remaining = 2.4
	if is_instance_valid(overlay_notice) and current_view != "play":
		overlay_notice.text = _t(es, en)
		overlay_notice.show()
	elif is_instance_valid(toast):
		toast.text = _t(es, en)
		toast_panel.show()

func hit_marker() -> void:
	hit_remaining = 0.16

func show_damage(amount: int, source: String = "manual") -> void:
	if amount <= 0 or float(options.damage_opacity) <= 0:
		return
	if not bool(options.group_damage) or damage_remaining <= 0 or source != last_source:
		damage_total = 0
	damage_total += amount
	last_source = source
	damage_remaining = 0.58
	var kind := _t("Chispa", "Spark") + " " if source == "spark" else ""
	damage_text.text = kind + "−" + str(damage_total)
	damage_text.modulate.a = options.damage_opacity
	damage_text.show()

func _process(delta: float) -> void:
	if current_view != "play" or not is_instance_valid(sight):
		return
	if toast_remaining > 0.0:
		toast_remaining = maxf(0.0, toast_remaining - delta)
		toast.text = _t(notice_es, notice_en)
		toast_panel.visible = toast_remaining > 0.0
		toast_panel.modulate.a = clampf(toast_remaining * 4.0, 0.0, 1.0)
	if hit_remaining > 0.0:
		hit_remaining = maxf(0.0, hit_remaining - delta)
		sight.flash = (hit_remaining / 0.16) * float(options.flashes)
		sight.queue_redraw()
	if damage_remaining > 0:
		damage_remaining = maxf(0.0, damage_remaining - delta)
		damage_text.modulate.a = minf(1.0, damage_remaining * 6.0) * float(options.damage_opacity)
		damage_text.visible = damage_remaining > 0 and float(options.damage_opacity) > 0
