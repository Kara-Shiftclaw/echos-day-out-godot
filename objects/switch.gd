extends Area2D

const ACTIVATED_FLAG := "activated"

signal activate()

var activated := false

func _ready() -> void:
	if Global.has_node_flag(self, ACTIVATED_FLAG):
		activated = true
		$AnimationPlayer.play("auto_activated")

func do_activate() -> void:
	if activated:
		$AnimationPlayer.play("hit_after_activated")
	else:
		activate.emit()
		activated = true
		Global.set_node_flag(self, ACTIVATED_FLAG)
		$AnimationPlayer.play("activate")
