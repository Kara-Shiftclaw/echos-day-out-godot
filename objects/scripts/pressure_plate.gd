extends Area2D

signal down()
signal up()

func entered(_other: Node2D) -> void:
	down.emit()
	$AnimationPlayer.play("press", -1, 1. + (Global.weight as int / 2.))

func exited(_other: Node2D) -> void:
	up.emit()
	$AnimationPlayer.play_backwards("press", -1)
