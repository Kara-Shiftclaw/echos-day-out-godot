extends CharacterBody2D

const MOVE_SPEED := 8. * 8.
const DEATH_BOUNCE := -128.
const DEATH_GRAVITY := Echo.GRAVITY / 2.

@export var moving_right := false

func _physics_process(delta: float) -> void:
	if $EnemyManager.health > 0:
		velocity = Vector2(MOVE_SPEED * Util.sign(moving_right), 0.)
		move_and_slide()
		
		if is_on_wall() or (moving_right and !$Right.valid_floor) or (!moving_right and !$Left.valid_floor):
			moving_right = !moving_right
		$Sprite2D.flip_h = moving_right
	else:
		velocity.y += DEATH_GRAVITY * delta
		move_and_slide()

func on_hit():
	var player_right := (Global.echo.global_position.x - global_position.x) > 0.
	if player_right == moving_right:
		moving_right = !moving_right

func die():
	var player_right := (Global.echo.global_position.x - global_position.x) > 0.
	velocity = Vector2(-Util.sign(player_right) * MOVE_SPEED, DEATH_BOUNCE)
	z_index = -10
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimationPlayer.play("die")

func respawn():
	$CollisionShape2D.set_deferred("disabled", false)
	show()

func disable_on_leave():
	if $EnemyManager.health <= 0:
		velocity = Vector2.ZERO
		hide()
