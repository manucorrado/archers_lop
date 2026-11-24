extends Resource
## Para agregar una charla en el Inspector, sumá un diccionario con un «id»
## único y estable y dos listas, «es» y «en». Cada par de textos en la misma
## posición forma una página. Podés usar «from», «until», «workshop» o «split»
## para condicionarla, y «repeat» para que vuelva a aparecer al agotar las nuevas.
## Se respeta el orden de la lista al elegir entre las historias disponibles.

@export var entries: Array[Dictionary] = []

func readable_stories() -> Dictionary:
	var catalog := {}
	for entry in entries:
		var id: Variant = entry.get("id")
		if not id is String or id.strip_edges().is_empty() or catalog.has(id):
			continue
		var es: Variant = entry.get("es")
		var en: Variant = entry.get("en")
		if not _has_pages(es) or not _has_pages(en) or es.size() != en.size():
			continue
		if not entry.get("from", 1) is int or not entry.get("until", 10) is int:
			continue
		catalog[id] = entry
	return catalog

func _has_pages(pages: Variant) -> bool:
	if not (pages is Array or pages is PackedStringArray) or pages.is_empty():
		return false
	for line in pages:
		if not line is String or line.strip_edges().is_empty():
			return false
	return true

func find_story(id: String) -> Dictionary:
	return readable_stories().get(id, {})

func choose(heard: Dictionary, stage: int, workshop: bool, split: bool) -> String:
	var repeat := ""
	var fewest := 2147483647
	for entry: Dictionary in readable_stories().values():
		if stage < entry.get("from", 1) or (entry.has("until") and stage > entry.until):
			continue
		if (entry.get("workshop", false) and not workshop) or (entry.get("split", false) and not split):
			continue
		var times := int(heard.get(entry.id, 0))
		if times == 0:
			return entry.id
		if entry.get("repeat", false) and times < fewest:
			repeat = entry.id
			fewest = times
	return repeat
