extends Area2D

func player_entered(other: Node2D):
	if other is Echo:
		var player := other as Echo
		player.enter_save_point(self)
		$SaveParticle.show()
		$SaveParticle.play("default")
		$Label/AnimationPlayer.play("saved_text")
		$SaveSfx.play()
		Global.save_data(self)
	else:
		push_warning("Non-player node ", other, " entered")

func player_exited(other: Node2D):
	if other is Echo:
		var player := other as Echo
		player.exit_save_point(self)
	else:
		push_warning("Non-player node ", other, " exited")
