extends Button
## States have a distinct relief, badge and fill, including at overview scale.

const PLATE := [Vector2(-.92,-1),Vector2(.57,-1),Vector2(1,-.56),Vector2(1,.64),
	Vector2(.66,1),Vector2(-.67,1),Vector2(-1,.63),Vector2(-1,-.86)]
var atlas_style := "walnut"
var stamped_symbol: Texture2D
var rank := 0
var ranks := 1
var met := false
var affordable := false
var inspected := false
var family := "damage"
var space_for_rank := false

func _draw() -> void:
	var center := size * 0.5
	var r := maxf(2, center.x - 2)
	var done := rank >= ranks
	var walnut := atlas_style != "linen"
	if walnut:
		_draw_plate(center, r, done)
	else:
		_draw_stamp(center, r, done)
	if stamped_symbol:
		var extent := Vector2.ONE * maxf(3.0, floorf(r * 1.16))
		var fade := 1.0 if met or rank > 0 else .62
		draw_texture_rect(stamped_symbol, Rect2((center - extent * .5).round(), extent), false, Color(1,1,1,fade))
	if r >= 5:
		_draw_badge(center, r, done, walnut)

func _plate(center: Vector2, r: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for v: Vector2 in PLATE:
		points.append(center + v * r)
	return points

func _draw_plate(center: Vector2, r: float, done: bool) -> void:
	var points := _plate(center, r)
	var full := Color("#e9cc94")
	var face := Color("#3d2b22") if rank == 0 else Color("#614a34")
	draw_colored_polygon(_plate(center + Vector2(1, 2), r), Color("#241910"))
	draw_colored_polygon(points, full if done else face)
	points.append(points[0])
	var edge := Color("#a98d68") if rank == 0 else Color("#e6c68a")
	draw_polyline(points, Color("#fff2c7") if inspected else edge, 2.4 if inspected else 1.3, true)
	if r < 7:
		return
	var inset := _plate(center, r * .80)
	inset.append(inset[0])
	if done:
		draw_polyline(inset, Color("#9f8153"), .9, true)
		for side in [-1, 1]:
			draw_circle(center + Vector2(side * r * .72, 0), maxf(1, r * .065), Color("#655135"), true, -1, true)
	elif rank == 0:
		for i in range(inset.size() - 1):
			draw_dashed_line(inset[i], inset[i + 1], Color("#a78c6c"), 1.0, 2.8, true, true)
	else:
		var length := 1.45 * r / ranks
		var start := center + Vector2(-r * .73, r * .75)
		for i in ranks:
			var p := start + Vector2(i * length, 0)
			draw_line(p, p + Vector2(maxf(.8, length * .72), 0),
					Color("#fff0ac") if i < rank else Color("#917858"), 2.2 if i < rank else 1.0, true)

func _draw_stamp(center: Vector2, r: float, done: bool) -> void:
	var ink := Color("#443c2e")
	var face := Color("#f6efdc") if rank == 0 else Color("#e9d4a7")
	draw_circle(center, r, Color("#303d34") if done else face, true, -1, true)
	if inspected or rank > 0 or r < 6:
		draw_arc(center, r, 0, TAU, 36, Color("#985423") if inspected else ink, 2.3 if inspected else 1.5, true)
	else:
		var dashes := maxi(6, roundi(TAU * r / 6))
		for i in dashes:
			var angle := TAU * i / dashes
			draw_arc(center, r, angle, angle + TAU * .60 / dashes, 4, ink, 1.4, true)
	if r < 7:
		return
	if done:
		draw_arc(center, r - 2.4, 0, TAU, 36, Color("#e9dfc4"), 1.1, true)
	elif rank > 0:
		for i in ranks:
			var start := -PI * .5 + TAU * i / ranks
			draw_arc(center, r - 2.4, start, start + TAU * .82 / ranks, 6,
					Color("#785430") if i < rank else Color("#c5b389"), 2.6 if i < rank else 1.1, true)

func _draw_badge(center: Vector2, r: float, done: bool, walnut: bool) -> void:
	if rank > 0 and not done and not space_for_rank:
		return
	var partial := rank > 0 and not done
	var font := get_theme_default_font()
	var text_size := 12 if partial else 10
	var caption := "%d/%d" % [rank, ranks] if partial else ""
	var half_width := ceilf(font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size).x * .5) + 3 if partial else clampf(r * .32, 3, 6.5)
	var half_height := 7.0 if partial else half_width
	var at := center + Vector2(0 if walnut or partial else .73 * r, r * (.9 if walnut or partial else .61))
	if partial:
		at.y = center.y + r + 5
	var box := Rect2((at - Vector2(half_width,half_height)).round(), Vector2(2 * half_width,2 * half_height))
	var paper := Color("#eddaa7") if walnut else Color("#f8f0dc")
	var ink := Color("#413225") if walnut else Color("#45412f")
	var fill := ink if (rank == 0 and walnut) or (rank > 0 and not walnut) else paper
	var mark := paper if fill == ink else ink
	if walnut or partial:
		draw_rect(box, fill)
		draw_rect(box, Color("#c3a36f") if walnut else Color("#9e8560"), false, 1)
	else:
		draw_circle(at, half_height, fill, true, -1, true)
		draw_arc(at, half_height, 0, TAU, 20, mark, 1, true)
	if partial:
		draw_string(font, (at + Vector2(3-half_width,4)).round(), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, mark)
	elif done:
		draw_polyline(PackedVector2Array([at + Vector2(-.55,0) * half_height, at + Vector2(-.12,.4) * half_height,
				at + Vector2(.57,-.43) * half_height]), mark, maxf(1.15, half_height * .24), true)
	else:
		draw_line(at - Vector2.RIGHT * half_width * .53, at + Vector2.RIGHT * half_width * .53, mark, 1.1, true)
		draw_line(at - Vector2.DOWN * half_height * .53, at + Vector2.DOWN * half_height * .53, mark, 1.1, true)
