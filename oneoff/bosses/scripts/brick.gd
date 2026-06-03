extends CharacterBody2D

const Y_CORRECTION := Vector2(0., -4.)
const SPEED := 180.

func _physics_process(delta: float) -> void:
	var col = move_and_collide(velocity * delta)
	if col != null:
		$AnimationPlayer.play("break")

func throw() -> void:
	var player_dir: Vector2 = Global.echo.global_position + Y_CORRECTION - $Sprite2D.global_position
	
	velocity = player_dir.normalized() * SPEED
	$AnimationPlayer.play("spin")

func drop() -> void:
	velocity = Vector2.DOWN * SPEED
	$AnimationPlayer.play("spin")
