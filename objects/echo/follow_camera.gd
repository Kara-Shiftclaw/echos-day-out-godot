extends Camera2D

const BASE_OFFSET := Vector2(64., 64.)

var chunk := Vector2i(9999, 9999)

@export var following: Node2D

func _process(_delta: float) -> void:
	var new_chunk := (following.global_position / Util.ROOM_SIZE).floor() as Vector2i
	if new_chunk != chunk:
		chunk = new_chunk
		Global.load_chunk(chunk.x, chunk.y)
	global_position = chunk * Util.ROOM_SIZE
