extends Node2D

func light() -> void:
	$AnimationPlayer.play("light")

func unlight() -> void:
	$AnimationPlayer.play("unlit")

func auto_light() -> void:
	$AnimationPlayer.play("idle")
