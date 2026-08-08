@tool
extends Area2D

enum LockColor {
	Red = 0,
	Orange = 1,
	Green = 2,
	Yellow = 3,
}

const BackgroundTiles := preload("res://oneoff/background/scripts/background_tiles.gd")

@export var background_tiles: BackgroundTiles
@export var lock_color := LockColor.Red:
	set(value):
		lock_color = value
		sync_lock_color()

func _ready() -> void:
	if !Engine.is_editor_hint():
		background_tiles.add_node_to_background($Back.duplicate(), $Back.global_position)
	sync_lock_color()

func activated() -> void:
	var going_in := !background_tiles.in_background
	background_tiles.in_background = going_in
	$AnimationPlayer.play("open")

func sync_lock_color() -> void:
	if is_node_ready():
		$LockColor.frame = lock_color as int
