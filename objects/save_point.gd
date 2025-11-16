extends Area2D

func player_entered(_other: Node2D):
	#var player := other as Echo
	$SaveParticle.show()
	$SaveParticle.play("default")
	$Label/AnimationPlayer.play("saved_text")
