extends RefCounted
## Each marked point of the drawing is a purchase. A parent is always one straight
## segment away. Seams connect completed paths when both ends have been bought.

const VERTICES := {
	"damage": [438, 470, ""],
	"weak": [405, 437, "damage"],
	"rate": [471, 437, "damage"],
	"refund": [405, 503, "damage"],
	"workshop": [471, 503, "damage"],

	# String, from the grip to the upper limb.
	"recurve": [505, 398, "rate"],
	"rate_step_01": [592, 313, "recurve"],
	"rate_step_02": [687, 213, "rate_step_01"],
	"longbow": [752, 147, "rate_step_02"],
	"rate_flat": [783, 102, "longbow"],
	"rain": [695, 168, "longbow"],

	# Nocked arrow, upper bow limb and arrowhead.
	"spark": [353, 381, "weak"],
	"combo": [330, 399, "weak"],
	"damage_step_01": [303, 331, "spark"],
	"crit": [258, 276, "damage_step_01"],
	"damage_step_02": [183, 230, "crit"],
	"damage_step_03": [230, 207, "damage_step_02"],
	"damage_step_04": [169, 168, "damage_step_03"],
	"damage_mult": [100, 132, "damage_step_04"],
	"damage_step_05": [126, 207, "damage_mult"],
	"damage_step_06": [153, 273, "damage_step_05"],
	"rate_step_03": [318, 231, "crit"],
	"rate_step_04": [385, 174, "rate_step_03"],
	"rate_step_05": [507, 144, "rate_step_04"],
	"rate_step_06": [638, 157, "rate_step_05"],
	"rate_step_07": [351, 265, "damage_step_01"],
	"rate_step_08": [402, 213, "rate_step_07"],
	"rate_step_09": [507, 184, "rate_step_08"],
	"rate_step_10": [637, 189, "rate_step_09"],

	# Lower bow limb and string. Both outlines follow playable nodes.
	"steady": [281, 351, "combo"],
	"damage_step_07": [238, 297, "steady"],
	"damage_step_08": [194, 355, "damage_step_07"],
	"damage_step_09": [142, 430, "damage_step_08"],
	"damage_step_10": [112, 539, "damage_step_09"],
	"damage_step_11": [137, 662, "damage_step_10"],
	"damage_step_12": [118, 761, "damage_step_11"],
	"rate_step_11": [230, 390, "steady"],
	"rate_step_12": [179, 453, "rate_step_11"],
	"rate_step_13": [156, 539, "rate_step_12"],
	"rate_step_14": [174, 653, "rate_step_13"],
	"rate_step_15": [156, 730, "rate_step_14"],
	"damage_step_13": [353, 552, "refund"],
	"damage_step_14": [296, 609, "damage_step_13"],
	"damage_step_15": [219, 686, "damage_step_14"],
	"damage_step_16": [135, 785, "damage_step_15"],
	"pet": [89, 819, "damage_step_16"],

	# Shaft and fletching. The first workshop purchase reveals just its two neighbors.
	"wheel": [503, 542, "workshop"],
	"capacity": [510, 471, "workshop"],
	"wheel_step_01": [546, 587, "wheel"],
	"wheel_step_02": [579, 642, "wheel_step_01"],
	"wheel_step_03": [617, 675, "wheel_step_02"],
	"wheel_step_04": [617, 741, "wheel_step_03"],
	"wheel_step_05": [699, 819, "wheel_step_04"],
	"wheel_step_06": [702, 743, "wheel_step_05"],
	"wheel_step_07": [777, 741, "wheel_step_06"],
	"wheel_step_08": [699, 662, "wheel_step_07"],
	"wheel_step_09": [631, 654, "wheel_step_08"],
	"pace": [546, 550, "capacity"],
	"wheel_step_10": [600, 616, "pace"],

	# Quiver, down to the stitched heel.
	"wheel_step_11": [440, 562, "wheel"],
	"wheel_step_12": [401, 606, "wheel_step_11"],
	"wheel_step_13": [339, 679, "wheel_step_12"],
	"wheel_step_14": [272, 777, "wheel_step_13"],
	"wheel_step_15": [246, 802, "wheel_step_14"],
	"wheel_step_16": [272, 849, "wheel_step_15"],
	"wheel_step_17": [319, 849, "wheel_step_16"],
	"wheel_step_18": [341, 820, "wheel_step_17"],
	"wheel_step_19": [293, 818, "wheel_step_18"],
	"wheel_step_20": [412, 770, "wheel_step_18"],
	"wheel_step_21": [374, 728, "wheel_step_20"],
	"rate_step_16": [477, 617, "wheel_step_11"],
	"rate_step_17": [543, 671, "rate_step_16"],
	"rate_step_18": [500, 702, "rate_step_17"],
	"rate_step_19": [441, 658, "rate_step_18"],

	# Quiver mouth. Every rung meets a socket on each side.
	"pickup": [548, 434, "capacity"],
	"leap": [584, 397, "pickup"],
	"damage_step_17": [626, 405, "leap"],
	"damage_step_18": [653, 428, "damage_step_17"],
	"damage_step_19": [678, 452, "damage_step_18"],
	"damage_step_20": [704, 484, "damage_step_19"],
	"damage_step_21": [720, 526, "damage_step_20"],
	"wheel_step_22": [601, 437, "leap"],
	"wheel_step_23": [623, 463, "wheel_step_22"],
	"wheel_step_24": [646, 487, "wheel_step_23"],
	"wheel_step_25": [676, 509, "wheel_step_24"],
	"wheel_step_26": [661, 567, "wheel_step_10"],

	# Three feathered arrows inside the quiver.
	"rate_step_20": [666, 356, "damage_step_17"],
	"rate_step_21": [698, 306, "rate_step_20"],
	"rate_step_22": [694, 260, "rate_step_21"],
	"rate_step_23": [764, 190, "rate_step_22"],
	"rate_step_24": [767, 232, "rate_step_23"],
	"rate_step_25": [810, 207, "rate_step_24"],
	"rate_step_26": [810, 233, "rate_step_25"],
	"rate_step_27": [741, 299, "rate_step_26"],
	"rate_step_28": [692, 389, "damage_step_18"],
	"rate_step_29": [732, 353, "rate_step_28"],
	"rate_step_30": [764, 323, "rate_step_29"],
	"rate_step_31": [796, 295, "rate_step_30"],
	"rate_step_32": [810, 265, "rate_step_31"],
	"rate_step_33": [855, 272, "rate_step_31"],
	"rate_step_34": [848, 298, "rate_step_33"],
	"rate_step_35": [807, 328, "rate_step_34"],
	"rate_step_36": [782, 354, "rate_step_35"],
	"damage_step_22": [719, 416, "damage_step_19"],
	"damage_step_23": [739, 443, "damage_step_20"],
	"damage_step_24": [781, 412, "damage_step_23"],
	"damage_step_25": [835, 412, "damage_step_24"],
	"damage_step_26": [893, 353, "damage_step_25"],
	"damage_step_27": [898, 317, "damage_step_26"],
	"damage_step_28": [843, 352, "damage_step_27"],
	"damage_step_29": [810, 382, "damage_step_28"],
	"damage_step_30": [783, 380, "damage_step_24"],
	"damage_step_31": [849, 320, "damage_step_30"],
}

const SEAMS := [
	["damage_step_02", "damage_step_06"], ["damage_step_02", "damage_step_07"],
	["rate_step_03", "rate_step_07"], ["rate_step_06", "rate_flat"], ["rate_step_10", "rain"],
	["damage_step_08", "rate_step_11"], ["rate_step_15", "damage_step_16"], ["damage_step_12", "pet"],
	["wheel_step_03", "wheel_step_06"], ["wheel_step_09", "wheel_step_06"], ["wheel_step_09", "wheel_step_10"],
	["wheel_step_14", "wheel_step_19"], ["wheel_step_21", "wheel_step_13"], ["wheel_step_20", "rate_step_18"],
	["rate_step_19", "wheel_step_12"], ["rate_step_17", "wheel_step_02"],
	["wheel_step_22", "damage_step_17"], ["wheel_step_23", "damage_step_18"],
	["wheel_step_24", "damage_step_19"], ["wheel_step_25", "damage_step_20"], ["wheel_step_25", "damage_step_21"],
	["wheel_step_26", "damage_step_21"],
	["rate_step_21", "rate_step_24"], ["rate_step_24", "rate_step_26"], ["rate_step_21", "rate_step_27"],
	["rate_step_27", "rate_step_29"], ["rate_step_32", "rate_step_30"], ["rate_step_34", "rate_step_31"],
	["rate_step_30", "rate_step_35"], ["rate_step_36", "rate_step_29"], ["rate_step_36", "damage_step_22"],
	["damage_step_26", "damage_step_28"], ["damage_step_29", "damage_step_24"], ["damage_step_28", "damage_step_31"],
]

const COSTS := {
	"damage": [0,9,9,14,21,31,46,69,103,1250], "rate": [14,21,31,46,68,103,154,231,346,346],
	"weak": [14], "workshop": [17], "refund": [6], "recurve": [37], "longbow": [1670],
	"spark": [18], "crit": [24], "combo": [190], "rain": [3200], "steady": [26], "wheel": [21], "capacity": [7,24],
	"pickup": [11], "pace": [21], "leap": [32], "pet": [28],
	"damage_mult": [390, 820, 1460], "rate_flat": [260, 320, 420, 550, 720, 930, 1210, 1560],
}

# Upgrading this existing bearing also mounts a crossbow. Its saved ownership,
# price and production bonus survive the move from the earlier workshop tree.
const SENTINEL_NODE := "wheel_step_05"

static func family(id: String) -> String:
	if id == SENTINEL_NODE:
		return "sentinel"
	var suffix := id.find("_step_")
	return id.left(suffix + 5) if suffix >= 0 else id

static func position_of(id: String) -> Vector2:
	var vertex: Array = VERTICES[id]
	return Vector2(vertex[0], vertex[1])

static func build_tree() -> Dictionary:
	var tree := {}
	var depth := {}
	for id: String in VERTICES:
		var parent: String = VERTICES[id][2]
		var level := 0 if parent.is_empty() else int(depth[parent]) + 1
		depth[id] = level
		var costs: Array = COSTS[id] if COSTS.has(id) else [roundi(level * level * 4.75) + 2]
		tree[id] = {"parent": parent, "costs": costs, "family": family(id)}
	tree.pet.extra_parent = "damage"
	tree.pet.extra_rank = 10
	return tree
