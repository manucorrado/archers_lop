extends RefCounted
## Paper, ink and page furniture shared by the field journal and the clearing's conversations.

const PAPER := Color("#f3ead4")
const CANVAS := Color("#e9dec4")
const INK := Color("#293f33")
const MUTED := Color("#556451")
const RULE := Color("#a69b7f")
const ACCENT := Color("#78532d")
const COVER := Color("#384c3a")

static func serif() -> SystemFont:
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Georgia", "STIX Two Text", "Times New Roman"])
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
	if kind == "left" or kind == "right":
		style.set_border_width_all(0)
		style.border_width_right = 1 if kind == "left" else 0
	elif kind == "folio" or kind == "note":
		style.shadow_size = 3
		style.shadow_offset = Vector2(1, 3)
		style.shadow_color = Color("#202b244d")
	page.add_theme_stylebox_override("panel", style)
	return page
