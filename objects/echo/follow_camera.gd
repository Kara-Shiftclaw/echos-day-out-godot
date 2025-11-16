extends Camera2D

const BASE_OFFSET := Vector2(64., 64.)
const ROOM_SIZE := 128.

@export var following: Node2D

func _process(_delta: float) -> void:
	global_position = (following.global_position / ROOM_SIZE).floor() * ROOM_SIZE
