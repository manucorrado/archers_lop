extends RefCounted
## Materials shared by the atlas frame, map and inspected piece.

const WALNUT := {
	"surround": Color("#291d17"), "surface": Color("#38291f"), "ink": Color("#f4e4cd"),
	"muted": Color("#d7bfa1"), "accent": Color("#e4bf89"), "rule": Color("#886b50"),
	"popup": Color("#292019"), "hover": Color("#59402d")
}
const LINEN := {
	"surround": Color("#f6efdc"), "surface": Color("#f5efdd"), "ink": Color("#303329"),
	"muted": Color("#645b49"), "accent": Color("#70482d"), "rule": Color("#af9e7b"),
	"popup": Color("#fcf6e8"), "hover": Color("#e6d9bc")
}

static func palette(id: String) -> Dictionary:
	return LINEN if id == "linen" else WALNUT

static func style_link(button: Button, id: String) -> void:
	var colors := palette(id)
	for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		var old := button.get_theme_stylebox(state)
		if old is StyleBoxFlat:
			var box := old.duplicate() as StyleBoxFlat
			box.bg_color = colors.hover if state in ["pressed", "hover"] else Color.TRANSPARENT
			box.border_color = colors.accent if state == "focus" else colors.rule
			button.add_theme_stylebox_override(state, box)
	for key: String in ["font_color", "font_pressed_color", "font_focus_color", "font_hover_color", "font_hover_pressed_color"]:
		button.add_theme_color_override(key, colors.ink)
	button.add_theme_color_override("font_disabled_color", colors.muted)
