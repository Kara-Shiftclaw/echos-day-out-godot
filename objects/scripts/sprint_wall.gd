extends StaticBody2D

@export var broken := false

func _process(_delta: float) -> void:
	if !broken:
		var wall_should_be_disabled := absf(Global.echo.velocity.x) == Echo.SPRINT_SPEED
		if wall_should_be_disabled != $WallCollision.disabled:
			$WallCollision.set_deferred("disabled", wall_should_be_disabled)

func on_break_collision(_other: Node2D) -> void:
	if !broken:
		$AnimationPlayer.play("break")

func on_player_hit(_other: Node2D) -> void:
	if !broken:
		$AnimationPlayer.play("hit")
