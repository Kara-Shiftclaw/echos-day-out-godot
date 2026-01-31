extends Control

func start() -> void:
	$AnimationPlayer.play("start")
	
func end() -> void:
	$AnimationPlayer.play_backwards("start")
