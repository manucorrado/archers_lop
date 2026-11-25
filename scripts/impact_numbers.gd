extends Control
## World anchors are projected every frame so a hit stays on the wood as the camera turns.

const LIFETIME := 0.62
const MAX_LABELS := 32
const INK := Color("#27231d")
const PAPER := Color("#ffe5ac")
const PREFIX := {"sentinel": ["Ballesta ", "Crossbow "], "spark": ["Chispa ", "Spark "],
	"critical": ["Crítico ", "Critical "], "weak": ["Punto débil ", "Weak spot "]}
var stamps: Array[Dictionary] = []
var typeface: Font
var language := "es"
var opacity := 1.0

func _ready() -> void:
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
	stamps.append({"point": point, "amount": amount, "source": source, "remaining": LIFETIME})
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	for i in range(stamps.size() - 1, -1, -1):
		stamps[i].remaining -= delta
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
		var caption := str(names[1 if language == "en" else 0]) + "−" + str(stamp.amount)
		var alpha := minf(1.0, stamp.remaining * 6.0) * opacity
		var width := typeface.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 19).x
		var at := (hit + Vector2(-width * 0.5, -9 - (LIFETIME - stamp.remaining) * 38)).round()
		draw_string_outline(typeface, at, caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, 4, Color(INK, alpha))
		draw_string(typeface, at, caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color(PAPER, alpha))
