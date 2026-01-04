extends CharacterBody2D

const GRAVITY := 60. * 8.
const BASE_FLAP_IMPULSE := -GRAVITY * 0.4
const UP_FLAP_IMPULSE := 0.7 * BASE_FLAP_IMPULSE
const DOWN_FLAP_IMPULSE := 0.3 * BASE_FLAP_IMPULSE

const X_ACCELERATION := 20. * 8.
const X_MAX_VEL := 4. * 8.
const X_KNOCKBACK_RATIO := 1.5

@export var obey_gravity := false

func _physics_process(delta: float) -> void:
	if obey_gravity:
		velocity.y += GRAVITY * delta
		if $EnemyManager.health <= 0:
			velocity.x = move_toward(velocity.x, 0., X_ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, desired_x_vel(), X_ACCELERATION * delta)
	
	move_and_slide()

func desired_x_vel() -> float:
	var echo_right = Global.echo.global_position.x > global_position.x
	return X_MAX_VEL * Util.sign(echo_right)

func wake_up() -> void:
	if $AnimationPlayer.current_animation == "sleep":
		$AnimationPlayer.play("wake_up")

func reload() -> void:
	velocity = Vector2.ZERO
	obey_gravity = false
	if $EnemyManager.health > 0:
		show()
		$AnimationPlayer.play("sleep")
	else:
		hide()

func chomp() -> void:
	$AnimationPlayer.play("chomp")

func die() -> void:
	$AnimationPlayer.play("die")

func on_hit() -> void:
	if obey_gravity:
		velocity.x = -desired_x_vel() * X_KNOCKBACK_RATIO
	if $EnemyManager.health <= 0:
		$AnimationPlayer.play("die")

func flap() -> void:
	var echo_up = Global.echo.global_position.y < global_position.y
	velocity.y = UP_FLAP_IMPULSE if echo_up else DOWN_FLAP_IMPULSE
