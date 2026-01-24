extends StaticBody2D

func check_state() -> void:
	if Global.weight > Global.Weight.Thin:
		$AnimationPlayer.play("big_idle")
	else:
		$AnimationPlayer.play("small_idle")
