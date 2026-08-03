extends ReferenceRect

const BackgroundTiles := preload("res://oneoff/background/scripts/background_tiles.gd")

@export var background_tiles: BackgroundTiles

var chunks_rect: Rect2i

func _ready() -> void:
	chunks_rect = Rect2i(position / Util.ROOM_SIZE, size / Util.ROOM_SIZE)
	Global.chunk_loaded.connect(chunk_loaded)
	background_tiles.entered_background.connect(func():
		var cur_chunk := Global.camera.chunk
		chunk_loaded(cur_chunk.x, cur_chunk.y)
	)

func chunk_loaded(x: int, y: int) -> void:
	if chunks_rect.has_point(Vector2i(x, y)) and background_tiles.in_background:
		Global.add_explored_space(x, y, name)
