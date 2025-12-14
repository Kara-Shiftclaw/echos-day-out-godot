extends Node2D

signal halfway()

func fade_in():
	$AnimationPlayer.play("fade_in")
	$AnimationPlayer.seek(0., true)

func emit_halfway():
	halfway.emit()
