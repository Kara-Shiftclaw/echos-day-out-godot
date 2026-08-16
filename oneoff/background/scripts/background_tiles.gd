extends Node2D

@export var tile_map_layers: Array[TileMapLayer] = []
@export var foreground_col_layers: Array[TileMapLayer] = []
@export var only_foreground: Array[Node] = []
@export var only_background: Array[Node] = []
@export var sub_viewport: SubViewport
@export var renderer: Sprite2D
@export var in_background := false:
	set(value):
		if in_background != value:
			in_background = value
			if value:
				entered_background.emit()
			else:
				exited_background.emit()

		if is_node_ready():
			call_deferred("sync_in_background")

var layer_copies: Array[TileMapLayer] = []

signal entered_background()
signal exited_background()

func _ready() -> void:
	for layer in tile_map_layers:
		var layer_copy := layer.duplicate()
		layer_copy.collision_enabled = false
		sub_viewport.add_child(layer_copy)
		layer_copies.append(layer_copy)
	
	sync_in_background()

func add_node_to_background(node: Node2D, node_global_position: Vector2) -> void:
	if node.get_parent() != null:
		node.reparent(layer_copies.get(0))
	else:
		layer_copies.get(0).add_child(node)
		node.global_position = node_global_position

func _process(_delta: float) -> void:
	renderer.position = Vector2.ZERO
	renderer.global_position = Vector2(roundf(renderer.global_position.x), roundf(renderer.global_position.y))
	for layer in layer_copies:
		layer.global_position = -renderer.global_position + sub_viewport.size / 2.

func sync_in_background() -> void:
	#renderer.visible = in_background
	for layer in tile_map_layers:
		layer.collision_enabled = in_background
	for layer in foreground_col_layers:
		layer.collision_enabled = !in_background
	for node in only_foreground:
		node.process_mode = Node.PROCESS_MODE_DISABLED if in_background else Node.PROCESS_MODE_INHERIT
	for node in only_background:
		node.process_mode = Node.PROCESS_MODE_INHERIT if in_background else Node.PROCESS_MODE_DISABLED
