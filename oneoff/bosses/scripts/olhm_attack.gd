extends Node2D

func charge() -> void:
	$AnimationPlayer.play("charge")

func release_early() -> void:
	$AnimationPlayer.play("release")

func reset() -> void:
	$AnimationPlayer.play("RESET")
