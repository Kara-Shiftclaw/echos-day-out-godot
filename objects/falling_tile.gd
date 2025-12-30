extends StaticBody2D

func maybe_player_entered(other: Node2D):
	if other is Echo:
		$AnimationPlayer.play("fall")
