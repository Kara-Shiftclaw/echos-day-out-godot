extends StaticBody2D

func break_wall(_other: Node2D) -> void:
	$AnimationPlayer.play("break")
