extends RefCounted
## Monochrome drawings stamped into the field journal. One stencil works on paper and on dark seals.

const Paths := preload("res://scripts/upgrade_paths.gd")

const SYMBOLS := {
	"damage": "M3 21 18 6m-5 0 8-3-3 8-1-4-4-1ZM5 17l-3 1 3-5 3-1m-1 5-1 4 4-3 1-4",
	"rate": "m2 11 7-3-3 4m-3 4 9-4-3 4m1 4L21 6m-5 0 6-3-2 7",
	"weak": "M22 12a10 9 0 1 1-20 0 10 9 0 0 1 20 0Zm-5 0a5 5 0 1 1-10 0 5 5 0 0 1 10 0Zm-4 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0Z",
	"workshop": "m2 11 10-8 10 8m-18 0 8-6 8 6v9H4Zm4 9v-6h5v6m3-7h2v3h-2M2 21h20",
	"refund": "M4 9a8 8 0 1 1 0 7m0-11v5h5m4-1c0 3-3 5-3 7a3 3 0 0 0 6 0c0-2-2-4-3-7Z",
	"recurve": "M3 21C10 19 17 13 19 6l2-4L3 21Zm4-4 9-10m-3 8 2-2",
	"longbow": "M2 21C15 21 22 8 21 2L2 21Zm2-2L19 4m-6 7 2 2",
	"spark": "m14 2-10 12h7l-2 8L21 9h-8l1-7Z",
	"combo": "M9 14 7 16a3 3 0 0 1-4-4l5-5a3 3 0 0 1 4 0m3 3 2-2a3 3 0 0 0-4-4l-2 2m0 9 3-3m1-1 2-2a3 3 0 0 1 4 4l-5 5a3 3 0 0 1-4 0",
	"crit": "m12 2 2 6 5-3-2 5 5 2-6 2 2 5-5-2-2 5-2-6-5 2 3-5-5-2 6-2-2-5 5 3 1-5Z",
	"steady": "M4 8h6l2-5 2 13 2-6h4M3 19h18m-4-3 4 3-4 3",
	"wheel": "M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-7 0a2 2 0 1 1-4 0 2 2 0 0 1 4 0ZM12 3v7m0 4v7M3 12h7m4 0h7M6 6l5 5m2 2 5 5M6 18l5-5m2-2 5-5",
	"capacity": "m4 18 4-10 8 3-5 10-7-3Zm4-8 6 2M12 9l5-7m-2 8 6-7m-4 9 5-5",
	"pickup": "M4 20c1-7 5-12 13-14m1-3C7 2 3 8 4 15c8 2 14-3 15-11l-1-1ZM11 14l3 5 5-5m-5 5 6-1",
	"pace": "M5 3h6l-1 6 2 3 7 2c2 1 2 4 0 5H5l-2-2 2-5V3Zm-1 11 5 1 2-3m-7 7v2h16v-3",
	"leap": "M3 19c3-9 7-14 15-14m-4-3 6 2-1 6m-8 9 9-3m-7 6 8-3",
	"pet": "m3 4 5 4 4-1 4 1 5-4-1 8 1 4-4 4-5 2-5-2-4-4 1-4-1-8Zm5 9h1m6 0h1m-6 3 2 2 2-2m-2 2v2",
	"damage_mult": "m2 21 12-12m-3 0 6-2-2 6M5 4l4 4M9 4 5 8m10 10 5 5m0-5-5 5",
	"rate_flat": "M2 14 12 4m-5 0h6v6m-9 8 12-12m-4 0h5v5m-2 7h7m-3-4v8",
	"sentinel": "m3 10 8-6 10 4M3 10l9 1 9-3M6 19 17 6m-6 9 4 5M8 14l-5 6m8-9 2-3",
}
static var cache: Dictionary = {}

static func texture(id: String, light := false) -> Texture2D:
	var family := Paths.family(id).trim_suffix("_step")
	var key := family + ("_light" if light else "")
	if not cache.has(key):
		var ink := "#fff3d5" if light else "#324a37"
		var svg := '<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24"><path fill="none" stroke="%s" stroke-width="1.6" stroke-linejoin="round" stroke-linecap="round" d="%s"/></svg>' % [ink, SYMBOLS[family]]
		var image := Image.new()
		image.load_svg_from_string(svg)
		cache[key] = ImageTexture.create_from_image(image)
	return cache[key]
