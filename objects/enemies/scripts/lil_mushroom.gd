extends CharacterBody2D

const GRAVITY := Echo.GRAVITY
const HOP_IMPULSE := -120.
const HOP_X_VELOCITY := 50.

@export var awaiting_landing := false

func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	
	move_and_slide()
	if awaiting_landing and is_on_floor() and $EnemyManager.health > 0:
		$AnimationPlayer.play("land")
		velocity = Vector2.ZERO

func hop() -> void:
	velocity.y = HOP_IMPULSE
	velocity.x = Util.sign(echo_right()) * HOP_X_VELOCITY

func die() -> void:
	velocity.x = -Util.sign(echo_right()) * HOP_X_VELOCITY
	$AnimationPlayer.play("die")

func echo_right() -> bool:
	return Global.echo.global_position.x > global_position.x
