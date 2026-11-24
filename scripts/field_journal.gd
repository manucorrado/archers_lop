extends RefCounted
## Paper, ink and page furniture shared by the field journal and the clearing's conversations.

const PAPER := Color("#f3ead4")
const CANVAS := Color("#e9dec4")
const INK := Color("#293f33")
const MUTED := Color("#556451")
const RULE := Color("#a69b7f")
const ACCENT := Color("#78532d")
const COVER := Color("#584438")
const GILT := Color("#8c612f")

static func serif() -> SystemFont:
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Palatino Linotype", "Book Antiqua", "Palatino", "Liberation Serif"])
	return font

static func sans() -> SystemFont:
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Segoe UI", "Source Sans 3", "Arial"])
	return font

static func box(fill: Color, edge: Color, mx: int, my: int, roundness := 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(1)
	style.set_corner_radius_all(roundness)
	style.content_margin_left = mx
	style.content_margin_right = mx
	style.content_margin_top = my
	style.content_margin_bottom = my
	return style

class Page extends PanelContainer:
	var kind := "note"

	func _draw() -> void:
		var w := size.x
		var h := size.y
		var ink := Color("#826b4b0c")
		if kind == "binding":
			for y: float in [2.5, h - 2.5]:
				draw_dashed_line(Vector2(5, y), Vector2(w - 5, y), Color("#b594797a"), 1, 4)
			return
		# Fine broken fibres sit beneath the writing. Positions depend only on the page.
		for i in range(5, int(h) - 3, 7):
			var x := fposmod(sin(i * 1.731) * 18391.81, maxf(1, w - 14))
			draw_line(Vector2(x, i + 0.5), Vector2(minf(w - 2, x + 11 + i % 29), i + 0.5), ink)
		if kind == "note":
			draw_line(Vector2(8, 6), Vector2(8, h - 6), Color("#a87e5878"))
		if kind == "left" or kind == "right":
			for i in 9:
				var x := w - i - 1 if kind == "left" else float(i)
				draw_line(Vector2(x, 1), Vector2(x, h-1), Color(0.31, 0.27, 0.16, (9-i)*0.011))
		if kind == "folio":
			draw_line(Vector2(10, 7), Vector2(10, h - 7), Color("#92745370"))
			draw_line(Vector2(13, 7), Vector2(13, h - 7), Color("#92745328"))

static func sheet(mx: int, my: int, kind := "note") -> PanelContainer:
	var page := Page.new()
	page.kind = kind
	page.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := box(PAPER, RULE, mx, my)
	if kind == "binding":
		style = box(COVER, Color("#463930"), mx, my, 3)
		style.shadow_color = Color("#1f160f4d")
		style.shadow_size = 5
		style.shadow_offset = Vector2(0, 4)
	elif kind == "left" or kind == "right":
		style.set_border_width_all(0)
		style.border_width_right = 1 if kind == "left" else 0
	elif kind == "folio" or kind == "note":
		style.shadow_size = 3
		style.shadow_offset = Vector2(1, 3)
		style.shadow_color = Color("#202b244d")
	page.add_theme_stylebox_override("panel", style)
	return page

## Navigation marks belong to the paper. Only the leading action carries a solid ink edge.
class Entry extends Button:
	var mark := ""

	func _draw() -> void:
		if mark != "forward" and mark != "back":
			return
		var tip := Vector2(size.x - 12 if mark == "forward" else 8, roundf(size.y * 0.5))
		var direction := 1 if mark == "forward" else -1
		var tint := Color("#88765b") if disabled else GILT
		draw_line(tip - Vector2(10 * direction, 0), tip, tint, 1.5, true)
		draw_polyline(PackedVector2Array([tip - Vector2(4 * direction, 4), tip, tip - Vector2(4 * direction, -4)]), tint, 1.5, true)

static func style_entry(button: Button, font: Font, kind: String) -> void:
	var record := kind in ["action", "lead"]
	var tab := kind in ["tab", "current_tab"]
	var tab_fill := Color("#dbcdb0") if kind == "tab" else Color("#69543e")
	button.custom_minimum_size.y = 43 if record else 32
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", font)
	button.add_theme_font_size_override("font_size", 20 if record else 16)
	if record:
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	if button is Entry:
		button.mark = "forward" if record else "back" if kind == "back" else ""
	for state: String in ["normal", "hover", "pressed", "disabled"]:
		var fill := Color("#e7dabd") if kind == "lead" else Color.TRANSPARENT
		if tab:
			fill = tab_fill
		if state == "hover" or state == "pressed":
			fill = Color("#eaddbf") if state == "hover" else Color("#dbcaab")
			if kind == "current_tab":
				fill = Color("#72573b")
			if button is CheckButton and state == "pressed":
				fill = Color.TRANSPARENT
		var style := box(fill, Color("#baac8e"), 10 if record or tab else 5, 3)
		style.set_border_width_all(0)
		if record:
			style.border_width_bottom = 1
			style.content_margin_right = 30
			style.content_margin_left = 15
		if kind == "lead":
			style.border_width_left = 3
			style.border_color = Color("#957747")
		if kind == "back":
			style.content_margin_left = 25
		if tab:
			style.corner_radius_top_left = 4
			style.corner_radius_top_right = 4
			style.border_width_top = 3 if kind == "current_tab" else 1
			style.border_width_left = 1
			style.border_width_right = 1
			style.content_margin_left = 16
			style.content_margin_right = 16
			style.border_color = GILT if kind == "current_tab" else RULE
		button.add_theme_stylebox_override(state, style)
	for state in ["font_color", "font_pressed_color", "font_focus_color", "font_hover_color", "font_hover_pressed_color"]:
		button.add_theme_color_override(state, PAPER if kind == "current_tab" else INK if record or tab else ACCENT)
	button.add_theme_color_override("font_disabled_color", MUTED)
	var focus := box(Color.TRANSPARENT, GILT, 0, 0)
	focus.set_border_width_all(0)
	focus.border_width_bottom = 2
	button.add_theme_stylebox_override("focus", focus)

static func slider_knob(radius: int) -> ImageTexture:
	var side := 2 * radius + 3
	var image := Image.create_empty(side, side, false, Image.FORMAT_RGBA8)
	var center := Vector2.ONE * (radius + 1)
	for x in side:
		for y in side:
			var dist := Vector2(x, y).distance_to(center)
			if dist < radius + 0.6:
				var color := PAPER if dist < radius - 1.5 else ACCENT
				color.a = clampf(radius + 0.6 - dist, 0, 1)
				image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)

static func check_mark(checked: bool) -> ImageTexture:
	var image := Image.create_empty(20, 20, false, Image.FORMAT_RGBA8)
	image.fill_rect(Rect2i(1, 1, 18, 18), GILT)
	image.fill_rect(Rect2i(3, 3, 14, 14), INK if checked else PAPER)
	if checked:
		for i in 4:
			image.fill_rect(Rect2i(5 + i, 9 + i, 2, 2), PAPER)
		for i in 7:
			image.fill_rect(Rect2i(9 + i, 12 - i, 2, 2), PAPER)
	return ImageTexture.create_from_image(image)
