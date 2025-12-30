extends ReferenceRect

const FALLING_TILE_SCENE := preload("res://objects/falling_tile.tscn")
const FALLING_TILE_WIDTH := 8.

func _ready() -> void:
	var num_falling_tiles := roundi(size.x / FALLING_TILE_WIDTH)
	for i in range(0, num_falling_tiles):
		var falling_tile := FALLING_TILE_SCENE.instantiate()
		add_child(falling_tile)
		falling_tile.position.x = i * FALLING_TILE_WIDTH
