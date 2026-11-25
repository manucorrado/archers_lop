extends Control
## World anchors are projected every frame so a hit stays on the wood as the camera turns.

const LIFETIME := 0.62
const MAX_LABELS := 32
const AmountFormat := preload("res://scripts/amount_format.gd")
const Journal := preload("res://scripts/field_journal.gd")
const INK := Color("#2c211c")
const PAPER := Color("#fff1cf")
const CRITICAL_INK := Color("#51221c")
const CRITICAL := Color("#ffaf63")
const PREFIX := {"sentinel": ["Ballesta ", "Crossbow "], "spark": ["Chispa ", "Spark "],
	"critical": ["Crítico ", "Critical "], "weak": ["Punto débil ", "Weak spot "]}
var stamps: Array[Dictionary] = []
var typeface := Journal.sans()
var language := "es"
var opacity := 1.0
var movement := 1.0
var glints := 1.0

func _ready() -> void:
	typeface.font_weight = 800
	mouse_filter = MOUSE_FILTER_IGNORE
	clip_contents = true
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	set_process(false)

func add_hit(point: Vector3, amount: int, source: String, group: bool) -> void:
	if amount <= 0 or opacity <= 0:
		return
	if group:
		for i in range(stamps.size() - 1, -1, -1):
			var stamp := stamps[i]
			if stamp.source == source and point.distance_squared_to(stamp.point) <= 0.36:
				stamp.amount += amount
				stamp.point = point
				stamp.remaining = LIFETIME
				queue_redraw()
				return
	if stamps.size() == MAX_LABELS:
		stamps.pop_front()
	stamps.append({"point": point, "amount": amount, "source": source, "remaining": LIFETIME, "age": 0.0})
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	for i in range(stamps.size() - 1, -1, -1):
		stamps[i].remaining -= delta
		stamps[i].age += delta
		if stamps[i].remaining <= 0:
			stamps.remove_at(i)
	set_process(not stamps.is_empty())
	queue_redraw()

func _draw() -> void:
	var camera := get_viewport().get_camera_3d()
	if not camera or not typeface or opacity <= 0:
		return
	for stamp in stamps:
		if camera.is_position_behind(stamp.point):
			continue
		var hit := get_global_transform_with_canvas().affine_inverse() * camera.unproject_position(stamp.point)
		if not Rect2(Vector2.ZERO, size).has_point(hit):
			continue
		var names: Array = PREFIX.get(stamp.source, ["", ""])
		var critical: bool = stamp.source == "critical"
		var caption := "−" + AmountFormat.short(stamp.amount, language)
		if not critical:
			caption = str(names[1 if language == "en" else 0]) + caption
		var alpha := minf(1.0, stamp.remaining * 6.0) * opacity
		var age := float(stamp.age)
		var lift := minf(age, 0.55) * 37.0 * movement
		var punch := maxf(0.0, 1.0 - age / 0.14) * movement
		var baseline := hit + Vector2(0, -lift - (34.0 if critical else 9.0))
		var size_px := roundi(31 + punch * 6) if critical else roundi(23 + punch * 3)
		var color := CRITICAL if critical else PAPER
		var outline := CRITICAL_INK if critical else INK
		var width := _centered(caption, baseline, size_px, color, outline, alpha)
		if critical:
			_centered(str(names[1 if language == "en" else 0]).strip_edges().to_upper(),
					baseline - Vector2(0, size_px + 2), 13, PAPER, outline, alpha)
			var spark := maxf(0, 1.0 - age / 0.24) * glints
			if spark > 0:
				for side: int in [-1, 1]:
					var p := baseline + Vector2(side * (width * 0.5 + 4), -size_px * 0.45)
					draw_line(p, p + Vector2(side * (5 + 4 * spark), -4), Color(CRITICAL, alpha * spark), 2, true)

func _centered(caption: String, baseline: Vector2, pixels: int, tint: Color, outline: Color, alpha: float) -> float:
	var width := typeface.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, pixels).x
	var at := (baseline - Vector2(width * 0.5, 0)).round()
	draw_string_outline(typeface, at, caption, HORIZONTAL_ALIGNMENT_LEFT, -1, pixels, 5, Color(outline, alpha))
	draw_string(typeface, at, caption, HORIZONTAL_ALIGNMENT_LEFT, -1, pixels, Color(tint, alpha))
	return width
