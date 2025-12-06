extends Node2D

const FirstStage := preload("res://stages/intro_mountain.tscn")

func _ready() -> void:
	$"Options/VBoxContainer/New Game".grab_focus.call_deferred()

func new_game() -> void:
	get_tree().change_scene_to_packed(FirstStage)

func continue_game() -> void:
	Global.load_data(1)
