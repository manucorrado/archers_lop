extends Control
## A bow, nocked arrow and full quiver. The main strokes are purchase paths;
## the paired outlines and their small rivets reveal the equipment silhouette.

const Icons := preload("res://scripts/upgrade_icons.gd")
const POSITIONS := {
	"damage": Vector2(438, 470), "weak": Vector2(379, 411), "rate": Vector2(497, 411),
	"refund": Vector2(379, 529), "workshop": Vector2(497, 529),
	"spark": Vector2(254, 283), "crit": Vector2(100, 132), "combo": Vector2(351, 265),
	"steady": Vector2(506, 183), "recurve": Vector2(615, 288), "longbow": Vector2(783, 102),
	"wheel": Vector2(618, 741), "capacity": Vector2(719, 526), "pickup": Vector2(650, 428),
	"leap": Vector2(810, 209), "pace": Vector2(500, 702), "pet": Vector2(89, 819),
}

# The main paths start and end at the corresponding buttons. Internal points
# follow the outline through bends and forks, as in the reference drawing.
const BENDS := {
	"combo": [300,331], "crit": [184,230, 230,207, 169,168],
	"steady": [401,212], "capacity": [601,624],
	"wheel": [583,637, 617,666], "pickup": [704,485, 679,452],
	"pace": [583,637, 546,666], "leap": [690,388, 732,353, 741,300],
}
const DETAILS := {
	"crit": [[100,132, 126,207, 152,273, 184,230, 243,293, 282,342, 424,484]],
	"spark": [[88,819, 115,758, 137,662, 126,608, 112,539, 142,430, 194,355, 243,293],
		[88,819, 134,785, 157,719, 174,653, 165,587, 156,539, 179,453, 230,389, 282,342],
		[194,355, 230,389]],
	"combo": [[254,283, 318,230, 351,265]],
	"steady": [[318,230, 385,174, 507,144, 638,157, 682,156, 721,147, 755,130, 783,102],
		[506,183, 637,188, 678,186, 719,174, 752,148, 783,102]],
	"longbow": [[497,411, 592,313, 687,213, 752,148, 783,102]],
	"pet": [[89,819, 135,785, 219,685, 296,609, 379,529]],
	"wheel": [[617,666, 698,662, 776,741, 702,743, 699,819, 618,741],
		[497,529, 601,624, 702,743], [438,470, 472,526, 583,637, 617,666, 702,743]],
	"capacity": [[583,637, 546,666, 477,620, 438,563, 472,526],
		[438,563, 401,606, 442,657, 500,702, 546,666]],
	"pace": [[401,606, 339,679, 375,729, 411,769, 500,702],
		[339,679, 271,777, 294,818, 335,823, 411,769],
		[271,777, 249,802, 272,848, 319,848, 335,823]],
	"pickup": [[719,526, 683,514, 647,486, 614,451, 595,422, 584,397, 607,398, 626,406, 650,428],
		[595,440, 626,406, 666,356, 744,271, 810,209],
		[617,465, 650,428], [643,489, 679,452], [677,506, 704,485]],
	"leap": [[666,356, 698,306, 694,260, 764,190, 767,232, 810,209, 808,229, 741,300, 698,306],
		[767,232, 808,229], [732,353, 782,353, 848,293, 855,272, 799,296, 741,353],
		[799,296, 810,268, 763,327, 810,327, 855,272],
		[679,452, 719,414, 782,353], [704,485, 739,442, 781,412, 834,412, 892,353, 898,317, 842,352, 809,381, 781,412],
		[781,412, 784,381, 850,319, 842,352, 892,353], [809,381, 863,381]],
}
const LATENT := Color("#455a4f")
const OPEN := Color("#92a990")
const GROWN := Color("#dfb77a")

class Socket extends Button:
	var symbol: Texture2D
	var rank := 0
	var ranks := 1
	var met := false
	var affordable := false
	var inspected := false
	var radius := 17.0

	func _draw() -> void:
		var c := size * 0.5
		var outline := Color("#6c8173")
		var fill := Color("#263931")
		if rank > 0:
			outline = Color("#dbb574")
			fill = Color("#514539")
		elif affordable:
			outline = Color("#d0dfbb")
			fill = Color("#3b5645")
		elif met:
			outline = Color("#91a78c")
		if inspected or has_focus() or is_hovered():
			draw_circle(c, radius + 2.5, Color("#e9d5a7"), false, 1.3, true)
		draw_circle(c + Vector2(0, 1), radius + 0.9, Color("#0e1c17"), true, -1, true)
		draw_circle(c, radius, fill, true, -1, true)
		draw_circle(c, radius, outline, false, 1.4, true)
		if rank > 0 and ranks > 1:
			draw_arc(c, radius - 2, -PI * 0.5, -PI * 0.5 + TAU * rank / ranks,
				36, Color("#f5ca80"), 1.6, true)
		var icon_size := Vector2(24, 24) if radius >= 16.0 else Vector2(21, 21)
		var tint := Color.WHITE if met or rank > 0 else Color("#91a697")
		draw_texture_rect(symbol, Rect2((c - icon_size * 0.5).round(), icon_size), false, tint)

var buttons: Dictionary = {}
var parents: Dictionary = {}
var offers: Dictionary = {}
var revealed: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_place_buttons)

func add_socket(id: String) -> Socket:
	var node := Socket.new()
	node.symbol = Icons.texture(id)
	node.flat = true
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.focus_mode = Control.FOCUS_ALL
	node.radius = 18.0 if id == "damage" else 15.0
	node.custom_minimum_size = Vector2.ONE * (node.radius * 2 + 5)
	node.size = node.custom_minimum_size
	for style in ["normal", "hover", "focus", "pressed", "hover_pressed"]:
		node.add_theme_stylebox_override(style, StyleBoxEmpty.new())
	node.mouse_entered.connect(node.queue_redraw)
	node.mouse_exited.connect(node.queue_redraw)
	node.focus_entered.connect(node.queue_redraw)
	node.focus_exited.connect(node.queue_redraw)
	buttons[id] = node
	add_child(node)
	return node

func arrange(new_offers: Dictionary) -> void:
	offers = new_offers
	for id: String in buttons:
		parents[id] = str(offers[id].requires)
	sync_visibility()
	_place_buttons()

func sync_visibility() -> void:
	revealed.clear()
	for id: String in buttons:
		var parent: String = parents[id]
		if parent.is_empty() or parent == "damage" or int(offers[parent].rank) > 0:
			revealed[id] = true
		# Purchased descendants stay usable if a player refunds their parent.
		# Keep the path back to the centre, including for older save layouts.
		if int(offers[id].rank) > 0:
			var path := id
			while not path.is_empty():
				revealed[path] = true
				path = parents[path]
	for id: String in buttons:
		buttons[id].visible = revealed.has(id)
	queue_redraw()

func closest_revealed(id: String) -> String:
	while not revealed.has(id) and parents.has(id):
		id = parents[id]
	return id if revealed.has(id) else "damage"

func _point(p: Vector2) -> Vector2:
	# The silhouette has deliberately asymmetric bounds (arrowheads on the right).
	var bounds := Vector2(822, 761)
	var fit := minf((size.x - 56.0) / bounds.x, (size.y - 48.0) / bounds.y)
	return (size * 0.5 + (p - Vector2(493.5, 474.0)) * fit).round()

func _place_buttons() -> void:
	for id: String in buttons:
		var node: Socket = buttons[id]
		node.position = (_point(POSITIONS[id]) - node.size * 0.5).round()
	queue_redraw()

func update_socket(id: String, offer: Dictionary, inspected: bool) -> void:
	offers[id] = offer
	var socket: Socket = buttons[id]
	socket.rank = int(offer.rank)
	socket.ranks = int(offer.max_rank)
	socket.met = bool(offer.requirement_met)
	socket.affordable = bool(offer.available)
	socket.inspected = inspected
	socket.queue_redraw()

func _trace(raw: Array, tint: Color, width: float) -> void:
	var points := PackedVector2Array()
	for i in range(0, raw.size(), 2):
		points.append(_point(Vector2(raw[i], raw[i + 1])))
	draw_polyline(points, tint, width, true)
	for p in points:
		draw_circle(p, width + 0.6, tint, true, -1, true)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#172a24"))
	draw_rect(Rect2(Vector2.ZERO, size), Color("#46594b"), false, 1.0)
	for id: String in DETAILS:
		if int(offers.get(id, {}).get("rank", 0)) == 0:
			continue
		for stroke: Array in DETAILS[id]:
			_trace(stroke, Color("#b29b72"), 1.3)
	for id: String in parents:
		var parent: String = parents[id]
		if parent.is_empty() or not revealed.has(id):
			continue
		var offer: Dictionary = offers[id]
		var tint := GROWN if int(offer.rank) > 0 else OPEN if bool(offer.requirement_met) else LATENT
		var start: Vector2 = POSITIONS[parent]
		var finish: Vector2 = POSITIONS[id]
		var stroke := [start.x, start.y]
		stroke.append_array(BENDS.get(id, []))
		stroke.append_array([finish.x, finish.y])
		_trace(stroke, tint, 2.25)
