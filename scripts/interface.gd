extends CanvasLayer

signal start_requested
signal resume_requested
signal restart_requested
signal quit_requested
signal buy_requested(id: String)
signal shop_requested

const PAPER := Color("#fff4dc")
const LINEN := Color("#d7d5bb")
const AMBER := Color("#f2bb67")
const INK := Color("#172c27")
const PANEL := Color("#192d28f7")
const EDGE := Color("#627365")
const LANG_FILE := "user://interface.cfg"

class Sight extends Control:
	var flash := 0.0

	func _draw() -> void:
		var center := size * 0.5
		for axis in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
			var a: Vector2 = center + axis * 4.0
			var b: Vector2 = center + axis * 9.0
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
var offer_controls: Dictionary = {}
var shop_offer_ids := ["damage", "workshop", "capacity"]
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
	var config := ConfigFile.new()
	if config.load(LANG_FILE) == OK and config.get_value("interface", "language", "es") == "en":
		language = "en"
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
	sight = Sight.new()
	sight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(sight)
	_place(sight, 0.5, 0.5, -16, -16, 16, 16)

	var quiver := _panel(hud, Color("#182820e8"), Color("#73807495"), 14, 5)
	_place(quiver, 0.0, 1.0, 24, -79, 175, -24)
	var quiver_row := _row(quiver, 8)
	quiver_row.add_child(Pictogram.new("arrow", PAPER))
	var quiver_values := _stack(quiver_row, -3)
	_label(quiver_values, _t("FLECHAS", "ARROWS"), 11, LINEN, mono_font)
	ammo_text = _label(quiver_values, "", 20, PAPER, mono_font)

	guide_panel = _panel(hud, Color("#182820e8"), Color("#73807495"), 13, 7)
	_place(guide_panel, 0.5, 1.0, -225, -65, 225, -24)
	guide_text = _label(guide_panel, "", 16, PAPER)
	guide_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	guide_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	toast_panel = _panel(hud, Color("#20372ff2"), Color("#b19363"), 12, 5)
	_place(toast_panel, 0.5, 0.0, -220, 84, 220, 118)
	toast = _label(toast_panel, "", 16, PAPER)
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_panel.hide()

func set_view(view: String) -> void:
	current_view = view
	if not is_instance_valid(layer_root):
		return
	if is_instance_valid(overlay):
		overlay.hide()
		layer_root.remove_child(overlay)
		overlay.queue_free()
	overlay = null
	offer_controls.clear()
	shop_sap = null
	shop_notice = null
	end_stats = null
	hud.visible = view == "play"
	if view != "play":
		_build_overlay(view)
	_update_values()

func _build_overlay(view: String) -> void:
	var cover := Cover.new()
	cover.side_only = view == "start"
	cover.mouse_filter = Control.MOUSE_FILTER_STOP
	layer_root.add_child(cover)
	cover.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay = cover
	var language_btn := _button(cover, _t("English", "Español"), false, _switch_language)
	_place(language_btn, 1, 0, -144, 24, -24, 64)
	if view == "start":
		_build_start(cover)
		return

	var holder := CenterContainer.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cover.add_child(holder)
	holder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var card := _panel(holder, PANEL, EDGE, 25, 19)
	card.custom_minimum_size.x = 550 if view == "shop" else 475
	var content := _stack(card, 12)
	if view == "shop":
		_build_shop(content)
	elif view == "pause":
		_label(content, _t("Pausa", "Paused"), 41, PAPER, title_font)
		_label(content, _t("La partida se reanuda al volver al claro.", "Your run resumes when you return to the clearing."), 17, LINEN)
		var back := _button(content, _t("Volver al claro", "Resume"), true, func(): resume_requested.emit())
		_button(content, _t("Abrir mejoras", "Open upgrades"), false, func(): shop_requested.emit())
		_button(content, _t("Reiniciar los tres nudos", "Restart the three knots"), false, func(): restart_requested.emit())
		_button(content, _t("Salir al escritorio", "Quit to desktop"), false, func(): quit_requested.emit())
		back.grab_focus()
	elif view == "end":
		_label(content, _t("Claro liberado", "Clearing restored"), 40, PAPER, title_font)
		_label(content, _t("Rompiste los tres nudos del bosque.", "You broke all three woodland knots."), 18, LINEN)
		end_stats = _label(content, "", 16, PAPER, mono_font)
		end_stats.add_theme_constant_override("line_spacing", 5)
		var again := _button(content, _t("Volver a jugar", "Play again"), true, func(): restart_requested.emit())
		_button(content, _t("Salir al escritorio", "Quit to desktop"), false, func(): quit_requested.emit())
		again.grab_focus()

func _build_start(parent: Control) -> void:
	var content := _stack(parent, 13)
	_place(content, 0.07, 0.5, 0, -174, 480, 174)
	var title := _label(content, _t("El arquero\ndel claro", "Archer of\nthe Clearing"), 61, PAPER, title_font)
	title.add_theme_constant_override("line_spacing", -7)
	var description := _label(content, _t(
		"Rompé tres nudos de madera y construí un taller que produzca tus flechas.",
		"Break three timber knots and build a workshop to craft your arrows."
	), 20, LINEN)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var actions := _row(content, 10)
	var first := _button(actions, _t("Entrar al claro", "Enter the clearing"), true, func(): start_requested.emit())
	_button(actions, _t("Salir", "Quit"), false, func(): quit_requested.emit())
	var keys := _label(content, _t(
		"WASD  Moverse     ·     Ratón  Apuntar\nClic izq.  Disparar     ·     F  Golpe de rama\nTab  Mejoras     ·     Esc  Pausa",
		"WASD  Move     ·     Mouse  Aim\nLeft click  Shoot     ·     F  Branch strike\nTab  Upgrades     ·     Esc  Pause"
	), 15, LINEN, mono_font)
	keys.add_theme_constant_override("line_spacing", 2)
	first.grab_focus()

func _build_shop(content: Control) -> void:
	var heading := _row(content, 20)
	var title := _label(heading, _t("Mejoras", "Upgrades"), 38, PAPER, title_font)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_sap = _label(heading, "", 19, AMBER, mono_font)
	for id in shop_offer_ids:
		_add_offer(content, id)
	shop_notice = _label(content, "", 16, AMBER)
	shop_notice.hide()
	var back := _button(content, _t("Volver al claro", "Return to the clearing"), true, func(): resume_requested.emit())
	back.grab_focus()

func _add_offer(content: Control, id: String) -> void:
	var card := _panel(content, Color("#263b32"), Color("#52685a"), 12, 7)
	var row := _row(card, 10)
	var description := _stack(row, 0)
	description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var names := {
		"damage": _t("Pulso de madera", "Timber pulse"),
		"workshop": _t("Taller de flechas", "Arrow workshop"),
		"capacity": _t("Carcaj de viaje", "Travel quiver")
	}
	_label(description, names[id], 20, PAPER)
	var effect := _label(description, "", 15, LINEN)
	var purchase := _button(row, "", false, func(): buy_requested.emit(id))
	purchase.custom_minimum_size.x = 132
	purchase.add_theme_font_size_override("font_size", 15)
	purchase.add_theme_stylebox_override("disabled", _box(Color("#21322b"), Color("#49594d"), 12, 6))
	purchase.add_theme_color_override("font_disabled_color", Color("#a9b2a4"))
	offer_controls[id] = {"effect": effect, "button": purchase}

func _switch_language() -> void:
	language = "en" if language == "es" else "es"
	var config := ConfigFile.new()
	config.set_value("interface", "language", language)
	config.save(LANG_FILE)
	layer_root.remove_child(hud)
	hud.queue_free()
	_build_hud()
	set_view(current_view)

func refresh(state: Dictionary) -> void:
	if current_view == "shop" and is_instance_valid(shop_notice) and not values.is_empty():
		if int(state.get("damage_rank", 0)) > int(values.get("damage_rank", 0)):
			shop_notice.text = _t("Comprado. Ahora infligís %d de daño por flecha.", "Purchased. Your arrows now deal %d damage.") % int(state.damage)
			shop_notice.show()
		elif bool(state.get("workshop", false)) and not bool(values.get("workshop", false)):
			shop_notice.text = _t("Taller construido. Recogé las flechas en su bandeja.", "Workshop built. Collect arrows from its tray.")
			shop_notice.show()
		elif int(state.get("capacity_rank", 0)) > int(values.get("capacity_rank", 0)):
			shop_notice.text = _t("Carcaj ampliado a %d flechas.", "Quiver expanded to %d arrows.") % int(state.capacity)
			shop_notice.show()
	values = state
	if is_instance_valid(layer_root):
		_update_values()

func _update_values() -> void:
	var stage := int(values.get("stage", 1))
	var sap := int(values.get("sap", 0))
	var arrows := int(values.get("arrows", 24))
	var cap := int(values.get("capacity", 24))
	var hp := int(values.get("hp", 160))
	var total_hp := maxi(1, int(values.get("max_hp", 160)))
	var have_shop := bool(values.get("workshop", false))
	var rank := int(values.get("damage_rank", 0))
	if current_view == "play":
		sap_text.text = str(sap)
		stage_text.text = _t("NUDO ", "KNOT ") + "%d / 3" % stage
		hp_text.text = "%d / %d" % [hp, total_hp]
		hp_bar.max_value = total_hp
		hp_bar.value = hp
		ammo_text.text = "%d / %d" % [arrows, cap]
		ammo_text.modulate = AMBER if arrows == 0 else Color.WHITE
		if arrows == 0 and int(values.get("knot_stock", 0)) > 0:
			guide_text.text = _t("Recogé el haz que cayó al pie del nudo.", "Collect the bundle at the foot of the knot.")
		elif arrows == 0 and (not have_shop or int(values.get("workshop_stock", 0)) == 0):
			guide_text.text = _t("Sin flechas. Acercate al nudo y golpeá con F.", "Out of arrows. Get close and strike the knot with F.")
		elif have_shop and int(values.get("collected", 0)) == 0 and arrows >= cap:
			guide_text.text = _t("Carcaj lleno. Dispará para hacer sitio a las flechas del taller.", "Quiver full. Shoot to make room for workshop arrows.")
		elif have_shop and (int(values.get("collected", 0)) == 0 or arrows < 6):
			var stock := int(values.get("workshop_stock", 0))
			guide_text.text = _t("Taller  ·  Acercate a la bandeja de la izquierda", "Workshop  ·  Approach the tray on the left") + "  (%d)" % stock
		elif _can_buy("workshop"):
			guide_text.text = _t("Tab  ·  Construí tu taller de flechas", "Tab  ·  Build your arrow workshop")
		elif rank == 0 and _can_buy("damage"):
			guide_text.text = _t("Tab  ·  Comprá Pulso de madera", "Tab  ·  Buy Timber pulse")
		elif int(values.get("shots", 0)) < 3:
			guide_text.text = _t("Apuntá al nudo y dispará con clic izquierdo.", "Aim at the knot and fire with left click.")
		else:
			guide_text.text = _t("Tab  Mejoras     ·     Esc  Pausa", "Tab  Upgrades     ·     Esc  Pause")
		return
	if current_view == "shop" and is_instance_valid(shop_sap):
		shop_sap.text = _t("%d savia", "%d sap") % sap
		_update_offer("damage", _t("Daño base por flecha", "Base damage per arrow")
			+ ("  10 → 12" if rank == 0 else "  12 → 14" if rank == 1 else "  14"))
		_update_offer("workshop", _t("Produce 1,5 flechas por segundo", "Crafts 1.5 arrows per second"))
		_update_offer("capacity", _t("Capacidad del carcaj", "Quiver capacity") + ("  40" if cap >= 40 else "  24 → 40"))
	if current_view == "end" and is_instance_valid(end_stats):
		var elapsed := int(values.get("elapsed", 0.0))
		var shots := int(values.get("shots", 0))
		var hits := int(values.get("hits", 0))
		var accuracy := int(round(100.0 * hits / maxi(shots, 1)))
		end_stats.text = _t("Tiempo de juego     %d:%02d\nAciertos            %d / %d (%d%%)\nFlechas del taller  %d",
			"Time played         %d:%02d\nHits                %d / %d (%d%%)\nWorkshop arrows     %d") % [
			floori(elapsed / 60.0), elapsed % 60, hits, shots, accuracy, int(values.get("collected", 0))
		]

func _can_buy(id: String) -> bool:
	return bool(values.get("offers", {}).get(id, {}).get("available", false))

func _update_offer(id: String, effect: String) -> void:
	var entry: Dictionary = offer_controls[id]
	var button: Button = entry.button
	var detail: Label = entry.effect
	detail.text = effect
	var offer: Dictionary = values.get("offers", {}).get(id, {})
	var price := int(offer.get("cost", 0))
	var required_stage := int(offer.get("stage", 1))
	button.disabled = not _can_buy(id)
	if offer.is_empty():
		button.text = "—"
	elif bool(offer.maxed):
		button.text = _t("Completado", "Complete")
	elif int(values.get("stage", 1)) < required_stage:
		button.text = _t("Nudo %d  ·  %d", "Knot %d  ·  %d") % [required_stage, price]
	elif button.disabled:
		button.text = _t("%d savia", "%d sap") % price
	else:
		button.text = _t("Comprar  ·  %d", "Buy  ·  %d") % price

func notify(es: String, en: String) -> void:
	notice_es = es
	notice_en = en
	toast_remaining = 2.4
	if is_instance_valid(toast):
		toast.text = _t(es, en)
		toast_panel.show()

func hit_marker() -> void:
	hit_remaining = 0.16

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
		sight.flash = hit_remaining / 0.16
		sight.queue_redraw()
