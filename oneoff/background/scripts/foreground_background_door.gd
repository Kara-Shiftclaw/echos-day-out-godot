extends Area2D

const BackgroundTiles := preload("res://oneoff/background/scripts/background_tiles.gd")

@export var background_tiles: BackgroundTiles

func activated() -> void:
	background_tiles.in_background = !background_tiles.in_background
