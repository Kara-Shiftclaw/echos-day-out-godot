extends Area2D

const ACTIVATED_FLAG := "activated"

signal activate()
signal already_activated()

var activated := false

func _ready() -> void:
	if Global.has_node_flag(self, ACTIVATED_FLAG):
		activated = true
		$AnimationPlayer.play("auto_activated")
		already_activated.emit()

func do_activate() -> void:
	if activated:
		$AnimationPlayer.play("hit_after_activated")
	else:
		activate.emit()
		activated = true
		Global.set_node_flag(self, ACTIVATED_FLAG)
		$AnimationPlayer.play("activate")
