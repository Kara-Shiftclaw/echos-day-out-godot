extends Node

signal save()
signal chunk_loaded(cx: int, cy: int)

var echo: Echo

func emit_save() -> void:
	save.emit()

func load_chunk(cx: int, cy: int) -> void:
	chunk_loaded.emit(cx, cy)
