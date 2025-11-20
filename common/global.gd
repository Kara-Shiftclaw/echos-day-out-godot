extends Node

signal save()

var echo: Echo

func emit_save() -> void:
	save.emit()
