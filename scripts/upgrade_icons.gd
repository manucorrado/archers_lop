extends RefCounted
## Monochrome drawings stamped into the field journal. One stencil works on paper and on dark seals.

const Paths := preload("res://scripts/upgrade_paths.gd")

const SYMBOLS := {
	"damage": "M3 21 15 9",
	"damage_step": "M5 20l6-6",
	"rate": "M4 5l7 7-7 7 M13 5l7 7-7 7",
	"rate_step": "M3 9h6 M2 15h5 M12 5l7 7-7 7",
	"weak": "M21 12a9 9 0 1 1-18 0 9 9 0 1 1 18 0Z",
	"workshop": "M2 11l10-8 10 8 M5 10v10h14V10 M10 20v-6h4v6",
	"refund": "M4 11a8 8 0 1 1 2 8 M3 5v7h7",
	"recurve": "M3 20l3-3q8-1 9-9l4-4 M3 20l16-16",
	"longbow": "M3 21Q21 20 21 3L3 21Z",
	"spark": "M14 2 5 13h6l-1 9L20 10h-7l1-8Z",
	"combo": "M10 14a4 4 0 0 0 6 0l4-4a4 4 0 0 0-6-6l-2 2 M14 10a4 4 0 0 0-6 0l-4 4a4 4 0 0 0 6 6l2-2",
	"multishot": "M12 21V4 M9 7l3-3 3 3 M12 20 3 9 M3 13V9h4 M12 20 21 9 M17 9h4v4",
	"rain": "M5 3v11 M2 11l3 4 3-4 M12 7v12 M9 16l3 4 3-4 M19 3v11 M16 11l3 4 3-4",
	"crit": "M12 2l2.5 6.5L21 6l-3.5 6L22 16l-7-1-3 7-2-7-7 1 4-5-3-5 6 2Z",
	"steady": "M2 12h5l3-6 4 12 3-6h5",
	"wheel": "M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z M12 4v16 M4 12h16",
	"wheel_step": "M17 12a5 5 0 1 1-10 0 5 5 0 1 1 10 0Z M12 4v3 M12 17v3 M4 12h3 M17 12h3",
	"capacity": "m5 10 10 3-4 8-8-3Z M9 10l3-7 M13 11l5-7",
	"pickup": "M3 20 15 8 M5 16C3 7 11 4 21 3c-1 9-6 16-16 13Z",
	"pace": "M6 4h6v7l3 2 4 1 2 3v3H4v-5l2-3Z",
	"leap": "M3 19Q8 4 20 5 M14 2l7 2-2 7",
	"pet": "M8 14q4-6 8 0l2 4q0 3-4 2l-2-1-3 1q-4 1-3-3Z",
	"damage_mult": "M3 21l10-10 M16 15l5 5 M21 15l-5 5",
	"rate_flat": "M2 5l6 7-6 7 M10 6l5 6-5 6 M16 17h6 M19 14v6",
	"sentinel": "M2 8q9-9 20 0L3 8 M12 4v10 M8 21l4-8 5 8",
}

# A solid tip, eye or paw pad stays legible when the atlas is zoomed out.
const FILLS := {
	"damage": "M10 9 21 3l-5 12Z",
	"damage_step": "M5 12 20 3l-6 15-2-5Z",
	"weak": "M15 12a3 3 0 1 1-6 0 3 3 0 1 1 6 0Z",
	"wheel_step": "M13.7 12a1.7 1.7 0 1 1-3.4 0 1.7 1.7 0 1 1 3.4 0Z",
	"pet": "M6 9a2 2.4 0 1 1-4 0 2 2.4 0 1 1 4 0Z M11 5.5a2 2.5 0 1 1-4 0 2 2.5 0 1 1 4 0Z M17 5.5a2 2.5 0 1 1-4 0 2 2.5 0 1 1 4 0Z M22 9a2 2.4 0 1 1-4 0 2 2.4 0 1 1 4 0Z",
	"damage_mult": "M8 9 19 3l-6 11Z",
}

static var cache: Dictionary = {}

static func for_rank(id: String, rank: int) -> String:
	if id == "damage" and rank >= 9:
		return "multishot"
	return Paths.family(id)

static func texture(id: String, light := false) -> Texture2D:
	var family := Paths.family(id)
	var key := family + ("_light" if light else "")
	if not cache.has(key):
		var ink := "#fff3d5" if light else "#3e352b"
		var svg := '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24"><path fill="none" stroke="%s" stroke-width="2.1" stroke-linejoin="round" stroke-linecap="round" d="%s"/>' % [ink, SYMBOLS[family]]
		if FILLS.has(family):
			svg += '<path fill="%s" d="%s"/>' % [ink, FILLS[family]]
		var image := Image.new()
		image.load_svg_from_string(svg + "</svg>")
		image.generate_mipmaps()
		cache[key] = ImageTexture.create_from_image(image)
	return cache[key]
