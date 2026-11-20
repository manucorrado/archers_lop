@tool
extends Resource
## Shared material roles for all editable variants in the clearing.

@export var corteza := Color("#59453b"):
	set(value):
		corteza = value
		emit_changed()
@export var follaje := Color("#37493f"):
	set(value):
		follaje = value
		emit_changed()
@export var brotes := Color("#75865a"):
	set(value):
		brotes = value
		emit_changed()
@export var madera := Color("#b98755"):
	set(value):
		madera = value
		emit_changed()
@export var pluma := Color("#eee2bb"):
	set(value):
		pluma = value
		emit_changed()
@export var ligadura := Color("#557167"):
	set(value):
		ligadura = value
		emit_changed()
@export var piedra := Color("#73776a"):
	set(value):
		piedra = value
		emit_changed()
