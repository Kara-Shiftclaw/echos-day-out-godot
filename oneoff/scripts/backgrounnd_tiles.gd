extends Node2D

@export var tile_map_layers: Array[TileMapLayer] = []
@export var foreground_col_layers: Array[TileMapLayer] = []
@export var sub_viewport: SubViewport
@export var renderer: Sprite2D
@export var in_background := false:
	set(value):
		in_background = value
		if is_node_ready():
			sync_in_background()

var layer_copies: Array[TileMapLayer] = []

func _ready() -> void:
	for layer in tile_map_layers:
		var layer_copy := layer.duplicate()
		layer_copy.collision_enabled = false
		sub_viewport.add_child(layer_copy)
		layer_copies.append(layer_copy)
	
	sync_in_background()

func _process(_delta: float) -> void:
	renderer.position = Vector2.ZERO
	renderer.global_position = Vector2(roundf(renderer.global_position.x), roundf(renderer.global_position.y))
	for layer in layer_copies:
		layer.global_position = -renderer.global_position + sub_viewport.size / 2.

func sync_in_background() -> void:
	renderer.visible = in_background
	for layer in tile_map_layers:
		layer.collision_enabled = in_background
	for layer in foreground_col_layers:
		layer.collision_enabled = !in_background
