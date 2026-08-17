extends StaticBody2D

func break_wall(_other: Node2D) -> void:
	$AnimationPlayer.play("break")

func slow_smol_entered(other: Node2D) -> void:
	if other is Player:
		other.speed_scale = 0.5

func slow_smol_exited(other: Node2D) -> void:
	if other is Player:
		other.speed_scale = 1.
