extends Area2D

@export var background_tiles: Node2D

func activated() -> void:
	background_tiles.in_background = !background_tiles.in_background
