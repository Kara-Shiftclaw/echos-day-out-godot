extends Area2D

signal activate()

var activated := false

func do_activate() -> void:
	if activated:
		$AnimationPlayer.play("hit_after_activated")
	else:
		activate.emit()
		activated = true
		$AnimationPlayer.play("activate")
