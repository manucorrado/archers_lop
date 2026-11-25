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
	"recurve": [507, 401, "rate"],
	"rate_step_01": [594, 314, "recurve"],
	"rate_step_02": [691, 217, "rate_step_01"],
	"longbow": [756, 152, "rate_step_02"],
	"rate_flat": [792, 116, "longbow"],
	"rain": [688, 180, "longbow"],

	# Nocked arrow, upper bow limb and arrowhead.
	"spark": [364, 389, "weak"],
	"combo": [339, 382, "weak"],
	"damage_step_01": [297, 322, "spark"],
	"crit": [263, 285, "damage_step_01"],
	"damage_step_02": [189, 221, "crit"],
	"damage_step_03": [233, 201, "damage_step_02"],
	"damage_step_04": [168, 167, "damage_step_03"],
	"damage_mult": [101, 133, "damage_step_04"],
	"damage_step_05": [135, 199, "damage_mult"],
	"damage_step_06": [169, 265, "damage_step_05"],
	"rate_step_03": [343, 215, "crit"],
	"rate_step_04": [426, 172, "rate_step_03"],
	"rate_step_05": [531, 156, "rate_step_04"],
	"rate_step_06": [641, 165, "rate_step_05"],
	"rate_step_07": [369, 256, "damage_step_01"],
	"rate_step_08": [439, 210, "rate_step_07"],
	"rate_step_09": [535, 194, "rate_step_08"],
	"rate_step_10": [649, 195, "rate_step_09"],

	# Lower bow limb and string. Both outlines follow playable nodes.
	"steady": [285, 336, "combo"],
	"damage_step_07": [248, 302, "steady"],
	"damage_step_08": [183, 375, "damage_step_07"],
	"damage_step_09": [140, 458, "damage_step_08"],
	"damage_step_10": [124, 563, "damage_step_09"],
	"damage_step_11": [133, 673, "damage_step_10"],
	"damage_step_12": [120, 754, "damage_step_11"],
	"rate_step_11": [224, 401, "steady"],
	"rate_step_12": [178, 471, "rate_step_11"],
	"rate_step_13": [162, 567, "rate_step_12"],
	"rate_step_14": [163, 681, "rate_step_13"],
	"rate_step_15": [144, 739, "rate_step_14"],
	"damage_step_13": [355, 553, "refund"],
	"damage_step_14": [296, 612, "damage_step_13"],
	"damage_step_15": [222, 686, "damage_step_14"],
	"damage_step_16": [124, 784, "damage_step_15"],
	"pet": [87, 821, "damage_step_16"],

	# Shaft and fletching. The first workshop purchase reveals just its two neighbors.
	"wheel": [480, 519, "workshop"],
	"capacity": [515, 476, "workshop"],
	"wheel_step_01": [544, 583, "wheel"],
	"wheel_step_02": [599, 638, "wheel_step_01"],
	"wheel_step_03": [624, 663, "wheel_step_02"],
	"wheel_step_04": [630, 708, "wheel_step_03"],
	"wheel_step_05": [704, 781, "wheel_step_04"],
	"wheel_step_06": [707, 739, "wheel_step_05"],
	"wheel_step_07": [749, 736, "wheel_step_06"],
	"wheel_step_08": [676, 662, "wheel_step_07"],
	"wheel_step_09": [652, 661, "wheel_step_08"],
	"pace": [529, 554, "capacity"],
	"wheel_step_10": [589, 614, "pace"],

	# Quiver, down to the stitched heel.
	"wheel_step_11": [441, 563, "wheel"],
	"wheel_step_12": [404, 607, "wheel_step_11"],
	"wheel_step_13": [338, 687, "wheel_step_12"],
	"wheel_step_14": [273, 774, "wheel_step_13"],
	"wheel_step_15": [254, 800, "wheel_step_14"],
	"wheel_step_16": [255, 824, "wheel_step_15"],
	"wheel_step_17": [287, 854, "wheel_step_16"],
	"wheel_step_18": [333, 838, "wheel_step_17"],
	"wheel_step_19": [299, 814, "wheel_step_18"],
	"wheel_step_20": [419, 778, "wheel_step_18"],
	"wheel_step_21": [375, 728, "wheel_step_20"],
	"rate_step_16": [485, 620, "wheel_step_11"],
	"rate_step_17": [536, 684, "rate_step_16"],
	"rate_step_18": [499, 710, "rate_step_17"],
	"rate_step_19": [451, 661, "rate_step_18"],

	# Quiver mouth. Every rung meets a socket on each side.
	"pickup": [550, 436, "capacity"],
	"leap": [584, 397, "pickup"],
	"damage_step_17": [615, 415, "leap"],
	"damage_step_18": [644, 436, "damage_step_17"],
	"damage_step_19": [670, 462, "damage_step_18"],
	"damage_step_20": [691, 491, "damage_step_19"],
	"damage_step_21": [716, 529, "damage_step_20"],
	"wheel_step_22": [605, 430, "leap"],
	"wheel_step_23": [625, 458, "wheel_step_22"],
	"wheel_step_24": [651, 483, "wheel_step_23"],
	"wheel_step_25": [678, 505, "wheel_step_24"],
	"wheel_step_26": [661, 570, "wheel_step_10"],

	# Three feathered arrows inside the quiver.
	"rate_step_20": [664, 354, "damage_step_17"],
	"rate_step_21": [702, 309, "rate_step_20"],
	"rate_step_22": [705, 276, "rate_step_21"],
	"rate_step_23": [765, 203, "rate_step_22"],
	"rate_step_24": [767, 232, "rate_step_23"],
	"rate_step_25": [786, 210, "rate_step_24"],
	"rate_step_26": [794, 230, "rate_step_25"],
	"rate_step_27": [734, 302, "rate_step_26"],
	"rate_step_28": [707, 403, "damage_step_18"],
	"rate_step_29": [751, 358, "rate_step_28"],
	"rate_step_30": [754, 326, "rate_step_29"],
	"rate_step_31": [806, 275, "rate_step_30"],
	"rate_step_32": [821, 259, "rate_step_31"],
	"rate_step_33": [842, 267, "rate_step_31"],
	"rate_step_34": [850, 288, "rate_step_33"],
	"rate_step_35": [811, 326, "rate_step_34"],
	"rate_step_36": [782, 355, "rate_step_35"],
	"damage_step_22": [728, 419, "damage_step_19"],
	"damage_step_23": [746, 447, "damage_step_20"],
	"damage_step_24": [797, 404, "damage_step_23"],
	"damage_step_25": [831, 402, "damage_step_24"],
	"damage_step_26": [903, 341, "damage_step_25"],
	"damage_step_27": [896, 320, "damage_step_26"],
	"damage_step_28": [849, 360, "damage_step_27"],
	"damage_step_29": [816, 389, "damage_step_28"],
	"damage_step_30": [804, 374, "damage_step_24"],
	"damage_step_31": [875, 313, "damage_step_30"],
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
	["rate_step_29", "rate_step_33"], ["rate_step_36", "rate_step_29"],
	["damage_step_29", "damage_step_24"], ["damage_step_27", "damage_step_31"],
]

const COSTS := {
	"damage": [0,9,9,14,21,31,46,69,103,1250], "rate": [14,21,31,46,68,103,154,231,346,346],
	"weak": [14], "workshop": [17], "refund": [6], "recurve": [370], "longbow": [16700],
	"spark": [18], "crit": [24], "combo": [190], "rain": [3200], "steady": [26], "wheel": [21], "capacity": [7,24],
	"pickup": [11], "pace": [21], "leap": [32], "pet": [28],
	"damage_mult": [390, 820, 1460], "rate_flat": [260, 320, 420, 550, 720, 930, 1210, 1560],
}

# Upgrading this existing bearing also mounts a crossbow. Its saved ownership,
# price and production bonus survive the move from the earlier workshop tree.
const SENTINEL_NODE := "wheel_step_05"
const SEED_NODE := "wheel_step_11"

static func family(id: String) -> String:
	if id == SENTINEL_NODE:
		return "sentinel"
	if id == SEED_NODE:
		return "seeds"
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
