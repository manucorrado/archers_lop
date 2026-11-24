extends CanvasLayer

signal start_requested
signal resume_requested
signal restart_requested
signal quit_requested
signal buy_requested(id: String)
signal refund_requested(id: String)
signal continue_requested
signal next_act_requested
signal save_requested
signal gift_requested(id: String)
signal equip_requested(id: String)
signal settings_changed(options: Dictionary)
signal audio_preview_requested(pattern: String)

const Journal := preload("res://scripts/field_journal.gd")
const Preferences := preload("res://scripts/play_preferences.gd")
const Timbres := preload("res://scripts/arrow_timbres.gd")
const UpgradeMap := preload("res://scripts/upgrade_map.gd")
const AtlasDetail := preload("res://scripts/atlas_detail.gd")
const Paths := preload("res://scripts/upgrade_paths.gd")
const UPGRADES := {
	"sentinel": ["Ballesta del claro", "Clearing crossbow", "Instalá una ballesta a la derecha del sendero y sumá 0,025 flechas/s al taller. Cargala de a ocho. Conservás cuatro flechas. Dispara al tronco y espera cuando tenés que acertar al punto débil.", "Build a crossbow to the right of the path and add 0.025 arrows/s to the workshop. Load up to eight arrows and keep four. It fires at the trunk and waits when you need to hit a weak spot."],
	"damage": ["Daño por flecha", "Arrow damage", "Cada nivel suma un 20 % del daño base del arco. En el nivel 10 salen hasta tres flechas por disparo.", "Each level adds 20% of your bow’s base damage. At level 10, release up to three arrows per shot."],
	"workshop": ["Taller de flechas", "Arrow workshop", "Construí un taller que lanza atados de tres flechas por el claro.", "Build a workshop that launches bundles of three arrows across the clearing."],
	"capacity": ["Carcaj de viaje", "Travel quiver", "Llevá 16 flechas más por cada nivel.", "Carry 16 extra arrows per level."],
	"rate": ["Velocidad de ataque", "Attack speed", "Cada nivel suma un 12 % de la cadencia base de tu arco.", "Each level adds 12% of your bow’s base firing rate."],
	"damage_step": ["Punta reforzada", "Reinforced tip", "Sumá 1 de daño base por flecha antes de aplicar los multiplicadores.", "Add 1 base damage per arrow before multipliers."],
	"rate_step": ["Suelta ágil", "Quick release", "Sumá un 2 % de la cadencia base de tu arco.", "Add 2% of your bow’s base firing rate."],
	"wheel_step": ["Engranaje del taller", "Workshop gearing", "El taller produce 0,025 flechas más por segundo.", "The workshop produces an extra 0.025 arrows per second."],
	"damage_mult": ["Potencia multiplicada", "Compound power", "Cada nivel multiplica por 1,2 el daño que ya tiene cada flecha.", "Each level multiplies your existing arrow damage by 1.2."],
	"rate_flat": ["Disparo adicional", "Extra shot", "Cada nivel agrega un disparo por segundo a cualquiera de tus arcos.", "Each level adds one shot per second to any bow."],
	"weak": ["Ojo de veta", "Grain eye", "Duplicá el daño de tus flechas al acertar en el punto débil.", "Deal double arrow damage when you hit a weak point."],
	"recurve": ["Arco rápido", "Recurve bow", "Desbloqueá un segundo arco de tiro rápido. Usa las flechas de tu carcaj.", "Unlock a second, faster-firing bow. It uses arrows from your quiver."],
	"wheel": ["Rueda de savia", "Sap wheel", "Acelerá la producción del taller para que lance atados más seguido.", "Speed up workshop production so bundles launch more often."],
	"pickup": ["Recogida de hojas", "Leaf gathering", "Juntá los atados desde más lejos al pasar cerca.", "Collect nearby bundles from farther away."],
	"pace": ["Paso del porteador", "Carrier’s stride", "Caminá un 6 % más rápido mientras llevás al menos cuatro flechas.", "Walk 6% faster while carrying at least four arrows."],
	"spark": ["Chispa de copa", "Canopy spark", "Cada ocho aciertos, una descarga le hace daño extra al blanco.", "Every eight hits, a spark deals extra damage to the target."],
	"refund": ["Recuperar savia", "Reclaim sap", "Con un clic derecho sobre una mejora comprada, devolvés un nivel y recuperás lo que pagaste.", "Right-click a purchased upgrade to return one level and recover the sap you spent."],
	"longbow": ["Arco largo", "Longbow", "Desbloqueá un tercer arco. Sus flechas pegan más fuerte que las del arco rápido.", "Unlock a third bow. Its arrows hit harder than the recurve bow’s."],
	"combo": ["Buena racha", "On a roll", "Desbloqueá el combo. Los aciertos seguidos dan savia extra y los puntos débiles hacen crecer la racha más rápido.", "Unlock the combo. Consecutive hits earn bonus sap and weak points build your streak faster."],
	"rain": ["Lluvia de flechas", "Arrow rain", "Por cada flecha que soltás, caen tres más sobre el mismo lugar. Solo la primera sale de tu carcaj.", "Every arrow you release calls three more down on the same spot. Only the original comes from your quiver."],
	"crit": ["Golpe crítico", "Critical hit", "Cada vez que disparás hay un 10 % de probabilidad de que todas las flechas de ese tiro hagan el doble de daño.", "Each shot has a 10% chance to deal double damage with every arrow in that volley."],
	"steady": ["Tiro sostenido", "Steady fire", "Encadená cuatro disparos sin parar para ganar un 20 % de daño.", "Fire four shots without a break to gain 20% damage."],
	"leap": ["Salto al atado", "Bundle leap", "Mirá un atado de flechas en el suelo y saltá para impulsarte hacia él.", "Look at a bundle of arrows on the ground and jump to spring toward it."],
	"pet": ["Una caricia", "Pet the dog", "Acercate a tu perro para darle una caricia.", "Walk over to your dog to give it a pat."],
}
const GIFTS := {
	"D01": ["Pulso de liebre", "Hare's pulse", "Todos tus arcos disparan un 50% más rápido.", "Every bow fires 50% faster."],
	"D03": ["Manantial", "Wellspring", "Cada taller produce un 30% más de flechas.", "Each workshop produces 30% more arrows."],
	"D04": ["Corteza viva", "Living bark", "Tus flechas hacen un 20% más de daño directo.", "Your arrows deal 20% more direct damage."],
	"D05": ["Ojo de búho", "Owl eye", "Los aciertos del arco en un punto débil suman 0,5 al multiplicador de daño.", "Bow hits on a weak spot add 0.5 to the damage multiplier."],
	"D08": ["Carcaj profundo", "Deep quiver", "Tenés lugar para 24 flechas más en el carcaj.", "Your quiver holds 24 more arrows."],
	"D09": ["Hojas imantadas", "Magnetic leaves", "Recogés haces desde 2 metros más lejos.", "Collect bundles from 2 metres farther away."],
	"D10": ["Paso ligero", "Light step", "Caminás un 15 % más rápido, incluso con el carcaj vacío.", "Walk 15% faster, even with an empty quiver."],
	"D12": ["Cosecha doble", "Double harvest", "Cada árbol que rompés deja 16 flechas al pie del tronco.", "Each tree you break drops 16 arrows at its base."],
	"D14": ["Aliento largo", "Long breath", "Tu combo tarda 2 segundos más en empezar a caer.", "Your combo waits 2 more seconds before it starts to fall."],
}

const INK := Journal.INK
const MUTED := Journal.MUTED
const ACCENT := Journal.ACCENT
const RULE := Journal.RULE
const PAPER := Journal.PAPER

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
			Color("#24382bae"), Color("#23352310"), Color("#23352310"), Color("#24382bae")
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
		if kind == "grain":
			for i in 3:
				var points := PackedVector2Array()
				for k in 49:
					var a := TAU * k / 48.0
					var r := 9.4 - i * 2.5 + 0.7 * sin(3*a+i)
					points.append(o + Vector2(12 + cos(a)*r, 12 + sin(a)*r*0.82))
				draw_polyline(points, ink, 1.5, true)
		elif kind == "sap":
			var points := PackedVector2Array([
				o + Vector2(13, 2), o + Vector2(18, 11), o + Vector2(18, 16),
				o + Vector2(14, 20), o + Vector2(9, 20), o + Vector2(6, 17),
				o + Vector2(6, 12)
			])
			points.append(points[0])
			draw_polyline(points, ink, 1.6, true)
			draw_line(o + Vector2(9, 15), o + Vector2(11, 11), ink, 1.2, true)
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
var sap_gain: Label
var gain_remaining := 0.0
var grouped_sap := 0
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
var combo_panel: PanelContainer
var combo_hint: Label
var triple_status: Label
var rain_status: Label
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
var selected_upgrade := ""
var upgrade_detail: AtlasDetail
var equipment_buttons: Dictionary = {}
var ui_font := Journal.sans()
var title_font := SystemFont.new()
var mono_font := SystemFont.new()
var toast_remaining := 0.0
var hit_remaining := 0.0
var notice_es := ""
var notice_en := ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	title_font = Journal.serif()
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

func _sheet(parent: Control, mx: int, my: int, kind := "note") -> PanelContainer:
	var page := Journal.sheet(mx, my, kind)
	parent.add_child(page)
	return page

func _rule(parent: Control) -> void:
	var rule := ColorRect.new()
	rule.color = Color("#9c9d836e")
	rule.custom_minimum_size.y = 1
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rule)

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
	_style_button(button, primary)
	parent.add_child(button)
	button.pressed.connect(action)
	return button

func _style_button(button: Button, primary: bool) -> void:
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.custom_minimum_size.y = 40
	button.add_theme_font_override("font", ui_font)
	button.add_theme_font_size_override("font_size", 18)
	var foreground := PAPER if primary else INK
	for state in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color", "font_hover_pressed_color"]:
		button.add_theme_color_override(state, foreground)
	button.add_theme_color_override("font_disabled_color", MUTED)
	button.add_theme_stylebox_override("normal", Journal.box(INK if primary else Journal.CANVAS, INK if primary else RULE, 16, 5))
	button.add_theme_stylebox_override("hover", Journal.box(Color("#415c45") if primary else Color("#f8f0da"), ACCENT, 16, 5))
	button.add_theme_stylebox_override("pressed", Journal.box(Color("#1e3527") if primary else Color("#d4c8ab"), ACCENT, 16, 5))
	button.add_theme_stylebox_override("disabled", Journal.box(Color("#ded9c3"), RULE, 16, 5))
	var focus := Journal.box(Color.TRANSPARENT, Color("#b1803c"), 0, 0)
	focus.set_border_width_all(2)
	button.add_theme_stylebox_override("focus", focus)

func _entry(parent: Control, caption: String, action: Callable, kind := "link") -> Button:
	var button := Journal.Entry.new()
	button.text = caption
	Journal.style_entry(button, title_font if kind in ["lead", "action"] else ui_font, kind)
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

	var target := _sheet(hud, 21, 12)
	_place(target, 0, 0, 34, 26, 285, 26)
	var target_col := _stack(target, 3)
	var tag := _row(target_col, 9)
	tag.add_child(Pictogram.new("grain", INK))
	_label(tag, _t("FICHA DE CAMPO", "FIELD RECORD"), 12, MUTED)
	stage_text = _label(target_col, "", 32, INK, title_font)
	hp_bar = ProgressBar.new()
	hp_bar.show_percentage = false
	hp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_bar.custom_minimum_size.y = 4
	hp_bar.add_theme_stylebox_override("background", Journal.box(Color("#cfccb3"), Color.TRANSPARENT, 0, 0, 0))
	hp_bar.add_theme_stylebox_override("fill", Journal.box(Color("#41614c"), Color.TRANSPARENT, 0, 0, 0))
	target_col.add_child(hp_bar)
	hp_text = _label(target_col, "", 14, MUTED, mono_font)
	lobes_text = _label(target_col, "", 14, INK)
	combo_panel = _sheet(target_col, 0, 0, "inline")
	combo_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	var combo_row := _row(combo_panel, 10)
	_power_icon(combo_row, "combo")
	combo_text = _label(combo_row, "", 16, INK, title_font)
	combo_hint = _label(combo_row, "", 13, MUTED)
	sight = Sight.new()
	sight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(sight)
	_place(sight, 0.5, 0.5, -16, -16, 16, 16)
	sight.radius_scale = options.reticle_size
	damage_text = _label(hud, "", 20, Color("#ffe2a3"), mono_font)
	damage_text.add_theme_constant_override("outline_size", 5)
	damage_text.add_theme_color_override("font_outline_color", INK)
	_place(damage_text, 0.5, 0.5, 24, -36, 240, -8)
	damage_text.hide()
	event_text = _label(hud, "", 16, PAPER, mono_font)
	event_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	event_text.add_theme_constant_override("outline_size", 5)
	event_text.add_theme_color_override("font_outline_color", INK)
	_place(event_text, 1, 0, -330, 22, -30, 58)

	var ledger := _sheet(hud, 21, 12)
	_place(ledger, 0, 1, 34, -145, 237, -34)
	ledger.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var entries := _stack(ledger, 4)
	var ammo_row := _row(entries, 10)
	ammo_row.add_child(Pictogram.new("arrow", INK))
	var quiver := _stack(ammo_row, -4)
	bow_text = _label(quiver, "", 12, MUTED)
	ammo_text = _label(quiver, "", 30, INK, title_font)
	triple_status = _power_line(entries, "multishot")
	rain_status = _power_line(entries, "rain")
	_rule(entries)
	var wallet := _row(entries, 7)
	wallet.add_child(Pictogram.new("sap", ACCENT))
	_label(wallet, _t("Savia", "Sap"), 17, INK, title_font)
	sap_text = _label(wallet, "", 20, INK, title_font)
	sap_gain = _label(wallet, "", 14, ACCENT, mono_font)
	sap_gain.hide()
	guide_panel = _sheet(hud, 14, 8, "inline")
	guide_panel.add_theme_stylebox_override("panel", Journal.box(INK, Color("#d4c8a0"), 14, 8))
	_place(guide_panel, 1, 1, -416, -72, -34, -34)
	guide_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	guide_text = _label(guide_panel, "", 17, PAPER, title_font)
	guide_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	guide_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	toast_panel = _sheet(hud, 15, 6)
	_place(toast_panel, 0.5, 0, -220, 22, 220, 60)
	toast = _label(toast_panel, "", 17, INK, title_font)
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_panel.hide()

func _power_icon(row: HBoxContainer, id: String) -> void:
	var icon := TextureRect.new()
	icon.texture = UpgradeMap.Icons.texture(id)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(19, 19)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(icon)

func _power_line(entries: VBoxContainer, id: String) -> Label:
	var line := _row(entries, 5)
	_power_icon(line, id)
	return _label(line, "", 14, INK)

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
	audio_preview_requested.emit("stop")
	if is_instance_valid(overlay):
		overlay.hide()
		layer_root.remove_child(overlay)
		overlay.queue_free()
	overlay = null
	shop_sap = null
	shop_notice = null
	upgrade_detail = null
	selected_upgrade = ""
	overlay_notice = null
	end_stats = null
	start_new = null
	start_continue = null
	confirm_gift = null
	offer_controls.clear()
	equipment_buttons.clear()
	gift_buttons.clear()
	binding_buttons.clear()
	hud.visible = current_view == "play" and submenu.is_empty()
	if not hud.visible and current_view != "dialogue":
		_build_overlay()
	_update_values()

func _build_overlay() -> void:
	var cover := Cover.new()
	cover.side_only = current_view == "start" and submenu.is_empty()
	cover.mouse_filter = Control.MOUSE_FILTER_STOP
	layer_root.add_child(cover)
	cover.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay = cover
	if current_view == "shop" and submenu.is_empty():
		_build_shop(cover)
		return
	if submenu == "settings" or current_view == "pause":
		_build_book(cover)
		return
	var language_note := _sheet(cover, 7, 1, "right")
	_place(language_note, 1, 0, -124, 15, -20, 51)
	_entry(language_note, _t("English", "Español"), _switch_language)
	if cover.side_only:
		_build_start(cover)
		return
	var holder := CenterContainer.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cover.add_child(holder)
	holder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var card := _sheet(holder, 26, 18, "folio")
	var wide := submenu in ["test_times", "run_log"] or (submenu.is_empty() and current_view == "gift")
	card.custom_minimum_size.x = 880 if wide else 500
	var content := _stack(card, 10)
	if submenu == "run_log":
		preload("res://scripts/run_log.gd").build(content, values, language, UPGRADES, GIFTS)
		_button(content, _t("Volver al resumen", "Back to results"), true, _open_submenu.bind("")).grab_focus()
	elif submenu == "test_times":
		_build_test_times(content)
	elif submenu == "confirm_new":
		_build_confirmation(content)
	elif current_view == "gift":
		_build_gifts(content)
	elif current_view == "end":
		_build_end(content)
	overlay_notice = _label(content, "", 16, ACCENT)
	overlay_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay_notice.hide()
	language_note.move_to_front()

func _build_book(cover: Control) -> void:
	var holder := CenterContainer.new()
	cover.add_child(holder)
	holder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var book := _stack(holder, 0)
	book.custom_minimum_size.x = 1050
	var settings := submenu == "settings"
	if settings:
		var tabs := _row(book, 4)
		tabs.alignment = BoxContainer.ALIGNMENT_END
		var names := {"comfort": _t("Vista y lectura", "View and readability"), "controls": _t("Controles", "Controls"), "audio": _t("Sonido", "Audio")}
		for tab: String in names:
			var button := _entry(tabs, names[tab], _change_tab.bind(tab), "current_tab" if settings_tab == tab else "tab")
			if settings_tab == tab:
				button.grab_focus()
	var binding := _sheet(book, 5, 6, "binding")
	binding.custom_minimum_size.y = 494
	var pages := _row(binding, 0)
	var left := _book_page(pages, true)
	var right := _book_page(pages, false)
	if settings:
		_build_settings(left, right)
	else:
		_pause_summary(left)
		if submenu == "confirm_new":
			_build_confirmation(right)
		else:
			_label(right, _t("Pausa", "Paused"), 41, INK, title_font)
			var resume := _entry(right, _t("Volver al claro", "Resume"), resume_requested.emit, "lead")
			_entry(right, _t("Guardar partida", "Save game"), save_requested.emit, "action")
			_entry(right, _t("Ajustes", "Settings"), _open_submenu.bind("settings"), "action")
			_entry(right, _t("Nueva partida", "New game"), _open_submenu.bind("confirm_new"), "action")
			_entry(right, _t("Guardar y salir", "Save and quit"), quit_requested.emit, "action")
			resume.grab_focus()
		overlay_notice = _label(left, "", 15, ACCENT)
		overlay_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		overlay_notice.hide()
	for page: Control in [left, right]:
		var space := Control.new()
		space.size_flags_vertical = Control.SIZE_EXPAND_FILL
		space.mouse_filter = Control.MOUSE_FILTER_IGNORE
		page.add_child(space)
		_rule(page)
	var left_foot := _row(left, 0)
	left_foot.custom_minimum_size.y = 32
	if settings:
		var label := _t("Volver a pausa", "Back to pause") if current_view == "pause" else _t("Volver", "Back")
		_entry(left_foot, label, _open_submenu.bind(""), "back")
	var right_foot := _row(right, 0)
	right_foot.alignment = BoxContainer.ALIGNMENT_END
	_entry(right_foot, _t("English", "Español"), _switch_language)

func _book_page(pages: Control, verso: bool) -> VBoxContainer:
	var page := _sheet(pages, 32, 18, "left" if verso else "right")
	page.name = "Verso" if verso else "Recto"
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var content := _stack(page, 6)
	var run := _t("El arquero del claro", "Archer of the Clearing") if verso else _t("Cuaderno de campo", "Field journal")
	if not verso and submenu == "settings":
		run = _t("Ajustes del cuaderno", "Journal settings")
	var header := _label(content, run, 15, MUTED, title_font)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if verso else HORIZONTAL_ALIGNMENT_RIGHT
	_rule(content)
	return content

func _pause_summary(page: Control) -> void:
	_label(page, _t("Tu vuelta", "Your run"), 41, INK, title_font)
	var stage := int(values.get("stage", 1))
	var target := _row(page, 14)
	var emblem := Pictogram.new("grain", ACCENT)
	emblem.custom_minimum_size = Vector2(38, 38)
	emblem.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	target.add_child(emblem)
	var caption := _stack(target, 0)
	_label(caption, _act_name(stage), 16, MUTED)
	_label(caption, _stage_label(stage), 26, INK, title_font)
	_rule(page)
	_pause_datum(page, _t("Savia", "Sap"), str(values.get("sap", 0)))
	_pause_datum(page, _t("Flechas en el carcaj", "Arrows in quiver"), "%d / %d" % [values.get("arrows", 24), values.get("capacity", 24)])
	_pause_datum(page, _t("Arco equipado", "Equipped bow"), _bow_name(str(values.get("bow", "branch"))))

func _pause_datum(page: Control, title: String, value: String) -> void:
	var line := _row(page, 8)
	line.custom_minimum_size.y = 34
	_label(line, title, 18, MUTED).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label(line, value, 20, INK, title_font)
	_rule(page)

func _build_start(parent: Control) -> void:
	var leaf := _sheet(parent, 36, 29, "folio")
	_place(leaf, 0.055, 0.5, 0, -193, 562, 193)
	var content := _stack(leaf, 14)
	_label(content, _t("CUADERNO DE CAMPO", "FIELD JOURNAL"), 15, MUTED)
	_rule(content)
	var title := _label(content, _t("El arquero\ndel claro", "Archer of\nthe Clearing"), 58, INK, title_font)
	title.add_theme_constant_override("line_spacing", -9)
	var description := _label(content, _t(
		"Rompé diez blancos de madera. Elegí cómo mejorar tu arco y buscá los puntos débiles de los dos jefes.",
		"Break ten wooden targets. Upgrade your bow and find the weak points on both bosses."
	), 20, MUTED)
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
	overlay_notice = _label(content, "", 16, ACCENT)
	overlay_notice.hide()

func _build_confirmation(content: Control) -> void:
	_label(content, _t("¿Empezar de nuevo?", "Start a new game?"), 33, INK, title_font)
	var explanation := _label(content, _t(
		"Se reemplazará la partida del claro, incluidas tus compras y la recompensa que elegiste. Tus ajustes se conservan.",
		"This will replace your clearing, upgrades and gift. Your settings will carry over."
	), 18, MUTED)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_entry(content, _t("Conservar partida", "Keep this run"), _open_submenu.bind(""), "lead").grab_focus()
	_entry(content, _t("Empezar de nuevo", "Start over"), restart_requested.emit, "action")

func _scroll_column(parent: Control, height: int) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size.y = height
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	parent.add_child(scroll)
	var column := _stack(scroll, 7)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return column

func _build_shop(cover: Control) -> void:
	var binding := _sheet(cover, 4, 5, "binding")
	binding.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var page := _sheet(binding, 30, 9, "inline")
	var chart := _stack(page, 4)
	var heading := _row(chart, 20)
	var title := _label(heading, _t("Árbol de mejoras", "Upgrade tree"), 41, INK, title_font)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var balance := _row(heading, 6)
	balance.add_child(Pictogram.new("sap", ACCENT))
	shop_sap = _label(balance, "", 18, INK, ui_font)
	_entry(heading, _t("English", "Español"), _switch_language)
	_rule(chart)
	upgrade_map = UpgradeMap.new()
	upgrade_map.language = language
	upgrade_map.animate_completion = minf(float(options.flashes), float(options.shake)) > 0.0
	upgrade_map.size_flags_vertical = Control.SIZE_EXPAND_FILL
	chart.add_child(upgrade_map)
	upgrade_detail = AtlasDetail.new()
	upgrade_map.add_child(upgrade_detail)
	upgrade_map.inspection_changed.connect(_select_upgrade)
	upgrade_map.map_moved.connect(_position_upgrade_detail)
	var available: Dictionary = values.get("offers", {})
	for id: String in available:
		var node := upgrade_map.add_socket(id)
		node.accessibility_name = _upgrade_name(id)
		node.pressed.connect(_try_buy.bind(id))
		node.gui_input.connect(_socket_input.bind(id))
		offer_controls[id] = node
	upgrade_map.arrange(available)
	_rule(chart)
	var equipment := _row(chart, 12)
	_entry(equipment, _t("Volver al claro", "Return to clearing"), resume_requested.emit, "back")
	shop_notice = _label(equipment, "", 15, MUTED)
	shop_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_notice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_notice.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	for id: String in ["branch", "recurve", "longbow"]:
		var button := _entry(equipment, _bow_name(id), equip_requested.emit.bind(id))
		button.add_theme_font_size_override("font_size", 15)
		button.accessibility_name = _t("Equipar ", "Equip ") + _bow_name(id)
		button.add_theme_color_override("font_disabled_color", MUTED)
		equipment_buttons[id] = button
	upgrade_map.focus_entry()

func _socket_input(event: InputEvent, id: String) -> void:
	var right_click: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed
	var delete_key: bool = event is InputEventKey and event.keycode == KEY_DELETE and event.pressed and not event.echo
	if not (right_click or delete_key):
		return
	offer_controls[id].accept_event()
	if values.get("offers", {}).get(id, {}).get("refundable", false):
		refund_requested.emit(id)

func _try_buy(id: String) -> void:
	if values.get("offers", {}).get(id, {}).get("available", false):
		buy_requested.emit(id)

func _select_upgrade(id: String) -> void:
	selected_upgrade = id
	if not is_instance_valid(upgrade_detail):
		return
	upgrade_detail.visible = not id.is_empty()
	if upgrade_detail.visible:
		_update_offer(id, values.offers[id])

func _position_upgrade_detail() -> void:
	if is_instance_valid(upgrade_detail) and upgrade_detail.visible and offer_controls.has(selected_upgrade):
		upgrade_detail.place(offer_controls[selected_upgrade].get_rect(), upgrade_map.size)

func _bow_name(id: String) -> String:
	match id:
		"longbow": return _t("Arco largo", "Longbow")
		"recurve": return _t("Arco rápido", "Recurve bow")
	return _t("Arco de rama", "Branch bow")

func _upgrade_name(id: String) -> String:
	var item: Array = UPGRADES[Paths.family(id)]
	return _t(item[0], item[1])

func _build_gifts(content: Control) -> void:
	_label(content, _t("Elegí una mejora", "Choose a reward"), 37, INK, title_font)
	var intro := _t("Rompiste el blanco 15. Elegí una carta para los últimos cinco árboles.", "You broke target 15. Choose a card for the last five trees.")
	match int(values.get("stage", 5)):
		5: intro = _t("Rompiste los dos lados del tronco. Elegí qué mejora llevarte.", "You broke both sides of the split trunk. Choose an upgrade to keep.")
		10: intro = _t("Venciste al segundo jefe. Elegí una carta para el tercer acto.", "You defeated the second boss. Choose a card for the third act.")
	_label(content, intro, 18, MUTED)
	var cards := _row(content, 10)
	for id in values.get("gift_offer", []):
		if not GIFTS.has(id):
			continue
		var data: Array = GIFTS[id]
		var card := _sheet(cards, 14, 14, "note")
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.custom_minimum_size = Vector2(245, 172)
		var col := _stack(card, 10)
		var stamp := TextureRect.new()
		stamp.texture = UpgradeMap.Icons.texture({"D01":"rate", "D03":"wheel", "D04":"damage", "D05":"weak", "D08":"capacity", "D09":"pickup", "D10":"pace", "D12":"capacity", "D14":"combo"}[id])
		stamp.custom_minimum_size = Vector2(32, 32)
		stamp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		stamp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		stamp.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		col.add_child(stamp)
		_rule(col)
		_label(col, _t(data[0], data[1]), 23, INK, title_font)
		var effect := _label(col, _t(data[2], data[3]), 17, MUTED)
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

func _act_name(stage: int) -> String:
	var index := clampi(ceili(stage / 5.0) - 1, 0, 3)
	return _t(["Primer acto", "Segundo acto", "Tercer acto", "Cuarto acto"][index],
			["First act", "Second act", "Third act", "Fourth act"][index])

func _stage_label(stage: int) -> String:
	return _t("Blanco %d de %d", "Target %d of %d") % [stage, values.get("stage_count", 20)]

func _build_end(content: Control) -> void:
	var stage := int(values.get("stage", 5))
	var can_continue := bool(values.get("can_continue_act", false))
	var title := _t("%s completado", "%s complete") % _act_name(stage) if can_continue else _t("El claro es tuyo", "The clearing is yours")
	_label(content, title, 38, INK, title_font)
	_label(content, _t("%d blancos rotos", "%d targets broken") % stage, 18, MUTED)
	end_stats = _label(content, "", 16, INK)
	end_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	end_stats.add_theme_constant_override("line_spacing", 5)
	_button(content, _t("Registro de la vuelta", "Run log"), false, _open_submenu.bind("run_log"))
	_button(content, _t("Ver tiempos de la prueba", "View playtest times"), false, _open_submenu.bind("test_times"))
	var replay := _button(content, _t("Volver a jugar", "Play again"), not can_continue, _open_submenu.bind("confirm_new"))
	if can_continue:
		var proceed := _button(content, _t("Continuar al blanco %d", "Continue to target %d") % (stage + 1), true, next_act_requested.emit)
		content.move_child(proceed, 3)
		proceed.grab_focus()
	else:
		replay.grab_focus()
	_button(content, _t("Ajustes", "Settings"), false, _open_submenu.bind("settings"))
	_button(content, _t("Salir", "Quit"), false, quit_requested.emit)

func _build_test_times(content: Control) -> void:
	_label(content, _t("Tiempos de la prueba", "Playtest times"), 33, INK, title_font)
	var explanation := _label(content, _t(
		"El tiempo observado incluye los menús y las pausas desde que entrás al claro. Ambos relojes se detienen si cambiás de ventana, minimizás o cerrás el juego.",
		"Observed time includes menus and pauses after you enter the clearing. Both clocks stop when you switch windows, minimize or close the game."
	), 17, MUTED)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var table := GridContainer.new()
	table.columns = 3
	table.add_theme_constant_override("h_separation", 22)
	table.add_theme_constant_override("v_separation", 8)
	content.add_child(table)
	_label(table, _t("Momento", "Milestone"), 16, MUTED).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label(table, _t("Tiempo observado", "Observed time"), 16, MUTED)
	_label(table, _t("Juego activo", "Active play"), 16, MUTED)
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
		_label(table, milestones[id], 17, INK)
		_label(table, _mark_time(session_marks, id), 16, ACCENT)
		_label(table, _mark_time(active_marks, id), 16, INK)
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
			var after := int(offers[id].get("rank", 0))
			if after != before:
				shop_notice.text = _t("Compraste %s.", "Purchased %s.") % _upgrade_name(id) if after > before else _t("Devolviste un nivel de %s.", "Returned one level of %s.") % _upgrade_name(id)
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
		upgrade_map.sync_visibility()
		shop_sap.text = _t("%d savia  ·  %d/%d niveles", "%d sap  ·  %d/%d levels") % [values.get("sap", 0), ranks, maximum]
		for id: String in equipment_buttons:
			var equipped := id == str(values.get("bow", "branch"))
			var button: Button = equipment_buttons[id]
			button.visible = id == "branch" or int(values.offers.get(id, {}).get("rank", 0)) > 0
			button.disabled = equipped
			button.text = _bow_name(id) + ("  ✓" if equipped else "")
	elif current_view == "end" and is_instance_valid(end_stats):
		var elapsed := int(values.get("elapsed", 0))
		var gift: Array = GIFTS.get(str(values.get("chosen_gift", "")), ["—", "—", "", ""])
		end_stats.text = _t("Tiempo activo     %d:%02d\nAciertos     %d / %d\nFlechas recogidas del taller     %d",
			"Active time     %d:%02d\nHits     %d / %d\nArrows collected from the workshop     %d") % [
			floori(elapsed / 60.0), elapsed % 60, values.get("hits", 0), values.get("shots", 0),
			values.get("collected", 0)]
		if int(values.get("ranks", {}).get("combo", 0)) > 0 or float(values.get("max_combo", 1.0)) > 1.0:
			end_stats.text += _t("\nMejor combo     ×%s", "\nBest combo     ×%s") % _number(values.max_combo, 2)
		if not str(values.chosen_gift).is_empty():
			end_stats.text += _t("\nRecompensa     %s\n%s", "\nReward     %s\n%s") % [_t(gift[0], gift[1]), _t(gift[2], gift[3])]
			var result := _reward_result(str(values.chosen_gift))
			if not result.is_empty():
				end_stats.text += "\n" + result
		else:
			var names := PackedStringArray()
			for id: String in [values.first_gift] + values.later_gifts:
				if GIFTS.has(id):
					names.append(_t(GIFTS[id][0], GIFTS[id][1]))
			end_stats.text += _t("\nCartas de la vuelta     ", "\nCards this run     ") + ", ".join(names)

func _reward_result(id: String) -> String:
	match id:
		"D01": return _t("Cadencia actual · %s disparos/s", "Current firing rate · %s shots/s") % _number(values.shot_rate, 2)
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
	stage_text.text = _stage_label(stage)
	hp_text.text = "%d / %d" % [values.get("hp", 160), values.get("max_hp", 160)]
	hp_bar.max_value = maxi(1, int(values.get("max_hp", 160)))
	hp_bar.value = values.get("hp", 160)
	lobes_text.visible = values.get("split", false)
	if lobes_text.visible:
		lobes_text.text = _t("Izq. %d  ·  Der. %d", "Left %d  ·  Right %d") % [values.get("left_hp", 0), values.get("right_hp", 0)]
	bow_text.text = _bow_name(str(values.get("bow", "branch"))).to_upper()
	ammo_text.text = "%d / %d" % [ammo, values.get("capacity", 24)]
	ammo_text.add_theme_color_override("font_color", ACCENT if ammo == 0 else INK)
	var combo := float(values.get("combo", 1.0))
	combo_panel.visible = int(values.get("ranks", {}).get("combo", 0)) > 0
	combo_text.text = "Combo  ×" + _number(combo, 2)
	if combo <= 1.001:
		combo_hint.text = _t("Listo", "Ready")
	elif float(values.get("combo_grace", 0.0)) <= 0:
		combo_hint.text = _t("En descenso", "Falling")
	else:
		combo_hint.text = _t("En racha", "Streak active")
	var ranks: Dictionary = values.get("ranks", {})
	triple_status.get_parent().visible = int(ranks.get("damage", 0)) >= 10
	var recent := int(values.get("recent_volley", 0))
	if recent > 0:
		triple_status.text = _t("Disparo triple · %d/3 en el tiro", "Triple shot · %d/3 fired") % recent
	else:
		triple_status.text = _t("Disparo triple · %d/3 listas", "Triple shot · %d/3 ready") % mini(ammo, 3)
	rain_status.get_parent().visible = int(ranks.get("rain", 0)) > 0
	if values.get("rain_falling", false):
		rain_status.text = _t("Lluvia de flechas · cayendo", "Arrow rain · falling")
	elif ammo == 0:
		rain_status.text = _t("Lluvia · sin munición", "Arrow rain · out of arrows")
	else:
		rain_status.text = _t("Lluvia de flechas · lista", "Arrow rain · ready")
	event_text.visible = str(values.get("event", "")) == "seed_rain"
	if event_text.visible:
		event_text.text = _t("Lluvia de semillas · %d s", "Seed rain · %d s") % ceili(values.get("event_remaining", 0.0))
	var guide := _guide()
	guide_panel.visible = not guide.is_empty()
	guide_text.text = guide

func _guide() -> String:
	if values.get("near_brizno", false):
		return _t("%s · Hablar con Brizno", "%s · Talk to Brizno") % preferences.binding_name("shop")
	if values.get("near_sentinel", false):
		return _t("%s · Cargar ballesta · %d/%d flechas", "%s · Load crossbow · %d/%d arrows") % [preferences.binding_name("shop"), values.get("sentinel_ammo", 0), values.get("sentinel_capacity", 12)]
	if values.get("near_dog", false):
		return ""
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
	if not options.get("first_steps", true) or values.get("fired_after_collect", false) or not values.get("learning_supplies", true):
		return ""
	var shoot := preferences.binding_name("shoot")
	if int(values.get("hits", 0)) == 0 and int(values.get("arrows", 24)) > 0:
		return _t("%s · Apuntá al tronco y dispará.", "%s · Aim at the trunk and shoot.") % shoot
	if int(values.get("collected", 0)) > 0:
		return _t("%s · Volvé a disparar con las flechas del taller.", "%s · Fire again with the workshop arrows.") % shoot
	if int(values.get("arrows", 24)) == 0:
		if int(values.get("workshop_stock", 0)) > 0:
			return _t("Buscá en el suelo las flechas que lanzó el taller.", "Look on the ground for the arrows launched by the workshop.")
		if int(values.get("knot_stock", 0)) > 0:
			return _t("Recogé las flechas al pie del tronco.", "Collect the arrows at the foot of the trunk.")
		if not values.get("workshop", false):
			return _t("%s · Acercate al tronco y golpeá con la rama.", "%s · Get close to the trunk and strike it.") % preferences.binding_name("strike")
	if values.get("workshop", false):
		if int(values.get("arrows", 0)) >= int(values.get("capacity", 24)):
			return _t("%s · Dispará para hacer lugar en el carcaj.", "%s · Shoot to make room in your quiver.") % shoot
		return _t("Seguí el atado que lanza el taller y recogelo donde caiga.", "Follow a bundle from the workshop and collect it where it lands.")
	var history: Dictionary = values.get("observations", {})
	if not history.has("buy_workshop") and values.get("offers", {}).get("workshop", {}).get("available", false):
		return _t("Volvé con Pipo para comprar el taller de flechas.", "Go back to Pipo to buy the arrow workshop.")
	if not history.has("buy_damage") and int(values.get("damage_rank", 0)) == 0 and values.get("offers", {}).get("damage", {}).get("available", false):
		return _t("Seguí la huella de Pipo. Tiene tu primera mejora gratis.", "Follow the paw print to Pipo for your free first upgrade.")
	return ""

func _number(number: float, precision: int = 1) -> String:
	if is_equal_approx(number, roundf(number)):
		return str(roundi(number))
	var result := String.num(number, precision)
	return result.replace(".", ",") if language == "es" else result

func _effect_values(id: String, offer: Dictionary) -> String:
	var name_tag := ""
	var suffix := ""
	var prefix := ""
	match Paths.family(id):
		"damage": name_tag = _t("Daño del arco de rama", "Branch bow damage")
		"damage_step": name_tag = _t("Daño adicional", "Extra base damage")
		"damage_mult":
			name_tag = _t("Multiplicador", "Multiplier")
			prefix = "×"
		"rate", "rate_step":
			name_tag = _t("Cadencia adicional", "Extra firing rate")
			suffix = "%"
		"rate_flat":
			name_tag = _t("Cadencia adicional", "Extra firing rate")
			suffix = _t(" disparos/s", " shots/s")
		"workshop", "wheel", "wheel_step":
			name_tag = _t("Producción", "Production")
			suffix = _t(" flechas/s", " arrows/s")
		"sentinel": name_tag = _t("Capacidad del depósito", "Crossbow capacity")
		"rain": name_tag = _t("Flechas extra por flecha", "Extra arrows per arrow")
		"capacity": name_tag = _t("Capacidad", "Capacity")
		"weak":
			name_tag = _t("Punto débil", "Weak point")
			prefix = "×"
		"pickup":
			name_tag = _t("Alcance", "Reach")
			suffix = " m"
		_: return ""
	var precision := 3 if Paths.family(id) == "wheel_step" else 2
	var current := prefix + _number(float(offer.current), precision)
	var next := prefix + _number(float(offer.next), precision)
	return name_tag + "  " + current + ("" if bool(offer.maxed) else " → " + next) + suffix

func _update_offer(id: String, offer: Dictionary) -> void:
	if offer.is_empty():
		return
	var rank := int(offer.rank)
	var maximum := int(offer.max_rank)
	var cost := int(offer.cost)
	var level := _t("Nivel %d/%d", "Level %d/%d") % [rank, maximum]
	var name_tag := _upgrade_name(id)
	var status := _t("Completa", "Complete") if bool(offer.maxed) else _t("Gratis", "Free") if cost == 0 else _t("%d de savia", "%d sap") % cost
	if not bool(offer.requirement_met) and not bool(offer.maxed):
		status = _t("Bloqueada", "Locked")
	var node: Button = offer_controls[id]
	node.accessibility_name = name_tag + ". " + level + ". " + status
	upgrade_map.update_socket(id, offer)
	if id != selected_upgrade:
		return
	var details := upgrade_detail
	var group := UpgradeMap.group_for(id)
	details.set_pigment(UpgradeMap.PIGMENTS[group])
	details.category.text = upgrade_map.group_name(group).to_upper()
	details.level.text = level.to_upper()
	details.title.text = _t("%s · Disparo triple", "%s · Triple shot") % name_tag if id == "damage" and rank >= 9 else name_tag
	var item: Array = UPGRADES[Paths.family(id)]
	details.effect.text = _t(item[2], item[3])
	details.numbers.text = _effect_values(id, offer)
	details.numbers.visible = not details.numbers.text.is_empty()

	var lines := PackedStringArray()
	if not bool(offer.maxed):
		for keys: Array in [["requires", "rank_required"], ["extra_requires", "extra_rank_required"]]:
			var parent := str(offer.get(keys[0], ""))
			if parent.is_empty():
				continue
			var required := int(offer.get(keys[1], 1))
			if int(values.offers[parent].rank) < required:
				lines.append(_t("Requiere %s (nivel %d).", "Requires %s (level %d).") % [_upgrade_name(parent), required])
		var missing := cost - int(values.get("sap", 0))
		if missing > 0:
			lines.append(_t("Te faltan %d de savia.", "Need %d more sap.") % missing)
	details.requirement.text = "\n".join(lines)
	details.requirement.visible = not lines.is_empty()
	var action := status
	if bool(offer.available):
		action = _t("Clic o Enter para comprar · ", "Click or Enter to buy · ") + status
	if bool(offer.get("refundable", false)):
		action += _t("\nClic derecho o Supr · Devolver %d de savia", "\nRight-click or Delete · Refund %d sap") % int(offer.refund_cost)
	details.actions.text = action
	_position_upgrade_detail()
	_position_upgrade_detail.call_deferred()


func _build_settings(left: Control, right: Control) -> void:
	var left_title := _t("Vista", "View")
	var right_title := _t("Lectura", "Readability")
	if settings_tab == "audio":
		left_title = _t("Arco e impacto", "Bow and impact")
		right_title = _t("Volumen", "Volume")
	elif settings_tab == "controls":
		left_title = _t("Movimiento", "Movement")
		right_title = _t("Acciones", "Actions")
	_label(left, left_title, 37, INK, title_font)
	_label(right, right_title, 37, INK, title_font)
	var column := _scroll_column(left, 288)
	var facing := _scroll_column(right, 288)
	if settings_tab == "comfort":
		_slider(column, "fov", _t("Campo de visión", "Field of view"), 55, 105, 1, "°")
		_slider(column, "zoom", _t("Acercamiento al apuntar", "Aiming zoom"), 0, 1, 0.05, "%")
		_slider(column, "shake", _t("Balanceo y vibración", "Sway and shake"), 0, 1, 0.05, "%")
		_slider(column, "flashes", _t("Intensidad de los destellos", "Flash intensity"), 0, 1, 0.05, "%")
		_toggle(facing, "first_steps", _t("Guía de los primeros pasos", "First steps guide"))
		_slider(facing, "reticle_size", _t("Tamaño de la mira", "Crosshair size"), 0.5, 2, 0.1, "%")
		_slider(facing, "damage_opacity", _t("Visibilidad de los números de daño", "Damage number opacity"), 0, 1, 0.05, "%")
		_toggle(facing, "group_damage", _t("Agrupar el daño de impactos seguidos", "Group damage from successive hits"))
	elif settings_tab == "audio":
		_timbre_picker(column, Timbres.SHOT, _t("Suelta de cuerda", "String release"), "shot")
		_timbre_picker(column, Timbres.IMPACT, _t("Impacto en madera", "Wood impact"), "arrow_impact")
		_entry(column, _t("Escuchar disparo e impacto", "Hear shot and impact"), audio_preview_requested.emit.bind("pair"), "action").name = "PreviewPair"
		_entry(column, _t("Escuchar ráfaga", "Hear a burst"), audio_preview_requested.emit.bind("burst"), "action").name = "PreviewBurst"
		_slider(facing, "volume_bow", _t("Arco y rama", "Bow and branch"), 0, 1, 0.05, "%")
		_slider(facing, "volume_world", _t("Claro, impactos y recogidas", "Clearing, hits and pickups"), 0, 1, 0.05, "%")
		_slider(facing, "volume_ui", _t("Compras y menús", "Purchases and menus"), 0, 1, 0.05, "%")
		var credit := RichTextLabel.new()
		credit.fit_content = true
		credit.scroll_active = false
		credit.bbcode_enabled = true
		credit.add_theme_font_override("normal_font", ui_font)
		credit.add_theme_font_size_override("normal_font_size", 15)
		credit.add_theme_color_override("default_color", MUTED)
		credit.text = "CosmicEmbers · [url=https://freesound.org/people/CosmicEmbers/sounds/387478/]Dart-Thud-1[/url] · [url=https://freesound.org/people/CosmicEmbers/sounds/387479/]Dart Thud 3[/url] · [url=https://creativecommons.org/licenses/by/3.0/]CC BY 3.0[/url]"
		credit.text += _t(" · recorte y nivelación", " · trimmed and level-matched")
		credit.meta_clicked.connect(func(url): OS.shell_open(str(url)))
		facing.add_child(credit)
	else:
		_slider(column, "sensitivity", _t("Sensibilidad del mouse", "Mouse sensitivity"), 0.2, 3, 0.1, "%")
		_toggle(facing, "toggle_fire", _t("Un clic inicia o detiene el disparo repetido", "Click to start or stop repeated fire"))
		for action: String in preferences.bindings:
			var movement := str(action).begins_with("move_") or action == "jump"
			var row := _row(column if movement else facing, 8)
			var labels: Array = Preferences.ACTION_NAMES[action]
			var name_label := _label(row, _t(labels[0], labels[1]), 17, INK)
			name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var key_button := _entry(row, preferences.binding_name(action), _listen.bind(action))
			binding_buttons[action] = key_button
		_entry(column, _t("Restablecer teclas y botones", "Reset key and mouse bindings"), _reset_bindings, "action")
	var status := _label(left, settings_notice, 15, ACCENT)
	status.name = "PreferencesNotice"
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.visible = not settings_notice.is_empty()

func _change_tab(tab: String) -> void:
	settings_tab = tab
	listening = ""
	settings_notice = ""
	_render_view()

func _timbre_picker(parent: Control, setting: String, title: String, cue: String) -> void:
	_label(parent, title, 17, INK)
	var row := _row(parent, 8)
	var picker := OptionButton.new()
	picker.name = setting.to_pascal_case()
	picker.accessibility_name = title
	picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	Journal.style_entry(picker, ui_font, "action")
	picker.add_theme_font_size_override("font_size", 17)
	picker.add_theme_constant_override("modulate_arrow", 1)
	var popup := picker.get_popup()
	popup.add_theme_stylebox_override("panel", Journal.box(PAPER, RULE, 6, 6))
	popup.add_theme_stylebox_override("hover", Journal.box(Journal.CANVAS, RULE, 6, 2))
	popup.add_theme_color_override("font_color", INK)
	popup.add_theme_color_override("font_hover_color", INK)
	popup.add_theme_font_override("font", ui_font)
	popup.add_theme_font_size_override("font_size", 17)
	popup.add_theme_constant_override("v_separation", 8)
	for id: String in Timbres.CATALOG[setting]:
		var entry: Array = Timbres.CATALOG[setting][id]
		var index := picker.item_count
		picker.add_item(_t(entry[0], entry[1]))
		picker.set_item_metadata(index, id)
		if id == options[setting]:
			picker.select(index)
	row.add_child(picker)
	picker.item_selected.connect(func(index: int):
		options[setting] = picker.get_item_metadata(index)
		_change_options()
		audio_preview_requested.emit(cue)
	)
	var listen := _entry(row, _t("Escuchar", "Listen"), audio_preview_requested.emit.bind(cue))
	listen.accessibility_name = _t("Escuchar · ", "Listen · ") + title
	listen.name = "Listen" + setting.to_pascal_case()

func _slider(parent: Control, id: String, title: String, minimum: float, maximum: float, step_size: float, unit: String) -> void:
	var row := _row(parent, 12)
	var caption := _label(row, title, 17, INK)
	caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var slider := HSlider.new()
	slider.name = id.to_pascal_case()
	slider.accessibility_name = title
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = step_size
	slider.value = options[id]
	slider.custom_minimum_size.y = 20
	slider.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	slider.add_theme_stylebox_override("slider", Journal.box(Color("#cbbfa6"), Color("#cbbfa6"), 0, 2))
	slider.add_theme_stylebox_override("grabber_area", Journal.box(ACCENT, ACCENT, 0, 2))
	slider.add_theme_stylebox_override("grabber_area_highlight", Journal.box(INK, INK, 0, 2))
	slider.add_theme_icon_override("grabber", Journal.slider_knob(5))
	slider.add_theme_icon_override("grabber_highlight", Journal.slider_knob(7))
	var focus := Journal.box(Color.TRANSPARENT, ACCENT, 0, 0)
	focus.set_border_width_all(1)
	slider.add_theme_stylebox_override("focus", focus)
	parent.add_child(slider)
	var value := _label(row, _setting_value(slider.value, unit), 16, ACCENT, mono_font)
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
	Journal.style_entry(check, ui_font, "link")
	check.custom_minimum_size.y = 37
	check.button_pressed = options.get(id, true)
	check.add_theme_font_override("font", ui_font)
	check.add_theme_font_size_override("font_size", 17)
	check.add_theme_icon_override("checked", Journal.check_mark(true))
	check.add_theme_icon_override("unchecked", Journal.check_mark(false))
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		check.add_theme_color_override(state, INK)
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
	if current_view == "shop" and is_instance_valid(shop_notice):
		shop_notice.text = _t(es, en)
		shop_notice.show()
	elif is_instance_valid(overlay_notice) and current_view != "play":
		overlay_notice.text = _t(es, en)
		overlay_notice.show()
	elif is_instance_valid(toast):
		toast.text = _t(es, en)
		toast_panel.show()

func hit_marker() -> void:
	hit_remaining = 0.16

func show_sap_earned(amount: int) -> void:
	if amount <= 0:
		return
	grouped_sap = (grouped_sap if gain_remaining > 0 else 0) + amount
	gain_remaining = 0.55
	sap_gain.text = "+%d" % grouped_sap
	sap_gain.show()

func show_damage(amount: int, source: String = "manual") -> void:
	if amount <= 0 or float(options.damage_opacity) <= 0:
		return
	if not bool(options.group_damage) or damage_remaining <= 0 or source != last_source:
		damage_total = 0
	damage_total += amount
	last_source = source
	damage_remaining = 0.58
	var kind := ""
	match source:
		"sentinel": kind = _t("Ballesta ", "Crossbow ")
		"spark": kind = _t("Chispa ", "Spark ")
		"critical": kind = _t("Crítico ", "Critical ")
		"weak": kind = _t("Punto débil ", "Weak spot ")
	damage_text.text = kind + "−" + str(damage_total)
	damage_text.modulate.a = options.damage_opacity
	damage_text.show()

func _process(delta: float) -> void:
	if current_view != "play" or not is_instance_valid(sight):
		return
	if gain_remaining > 0:
		gain_remaining = maxf(0, gain_remaining - delta)
		sap_gain.visible = gain_remaining > 0
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
