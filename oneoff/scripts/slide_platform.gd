extends Node2D

const OPEN_FLAG := "open"

var is_open := false

func _ready() -> void:
	if Global.has_node_flag(self, OPEN_FLAG):
		$AnimationPlayer.play("start_open")
		is_open = true

func open() -> void:
	$AnimationPlayer.play("open")
	is_open = true
	Global.set_node_flag(self, OPEN_FLAG)
