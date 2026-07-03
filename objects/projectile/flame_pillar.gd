extends Area2D

@export var creator_chunk: Vector2i

func _ready() -> void:
	var chunk := Vector2i(floori(global_position.x / Util.ROOM_SIZE), floori((global_position.y - 1.) / Util.ROOM_SIZE))
	if chunk != creator_chunk:
		queue_free()
	Global.chunk_loaded.connect(on_chunk_change)

func on_chunk_change(_x, _y) -> void:
	queue_free()
