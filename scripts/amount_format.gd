extends RefCounted
## Accepts whole, base-ten amounts. Work on digits so suffix boundaries stay exact,
## including preview values larger than Godot's 64-bit gameplay counters.

const SUFFIXES := ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No",
	"Dc", "Ud", "Dd", "Td", "Qad", "Qid", "Sxd", "Spd", "Ocd", "Nod", "Vg"]

static func short(value: Variant, language := "es") -> String:
	var digits := str(value)
	var sign_text := "−" if digits.begins_with("-") else ""
	digits = digits.trim_prefix("-").lstrip("0")
	if digits.is_empty():
		return "0"
	var count := digits.length()
	if count <= 5:
		if count > 3:
			var separator := "." if language == "es" else ","
			digits = digits.left(count - 3) + separator + digits.right(3)
		return sign_text + digits
	@warning_ignore("integer_division")
	var magnitude := (count - 2) / 3
	if magnitude >= SUFFIXES.size():
		return sign_text + digits.left(1) + "e" + str(count - 1)
	return sign_text + digits.left(count - 3 * magnitude) + SUFFIXES[magnitude]

static func grouped(value: int, spanish: bool) -> String:
	var digits := str(value).trim_prefix("-")
	for position in range(digits.length() - 3, 0, -3):
		digits = digits.insert(position, "." if spanish else ",")
	return "−" + digits if value < 0 else digits
