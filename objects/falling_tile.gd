extends StaticBody2D

func maybe_player_entered(other: Node2D):
	if other is Echo:
		if other.is_sprinting:
			$AnimationPlayer.play("fall")
		else:
			$AnimationPlayer.play("non_sprint_fall")
