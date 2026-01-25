extends Node2D

func light() -> void:
	$AnimationPlayer.play("light")

func auto_light() -> void:
	$AnimationPlayer.play("idle")
