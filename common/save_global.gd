extends Node

signal save()

func emit_save() -> void:
	save.emit()
