extends CharacterBody2D

var BOUNCE: Util.QuadraticJump
var GRAVITY: float
var BOUNCE_VELOCITY: Vector2
const ROLL_VELOCITY := 12. * 8.
const HIT_MICROBOUNCE := -2. * 8.

@export var facing_right := true

func _ready() -> void:
	BOUNCE = Util.calculate_quadratic_jump(0., 3. * 8., 0.5)
	GRAVITY = BOUNCE.gravity
	BOUNCE_VELOCITY = BOUNCE.initial_velocity

func _physics_process(delta: float) -> void:
	move_and_slide()
	$Sprite2D.flip_h = !facing_right
	
	if is_rolling():
		velocity.x = ROLL_VELOCITY * Util.sign(facing_right)
		if is_on_wall():
			if $EnemyManager.health > 0:
				facing_right = !facing_right
				bounce()
			else:
				$AnimationPlayer.play("die")
	elif is_on_floor():
		roll()
	velocity.y += GRAVITY * delta

func reload_alive() -> void:
	show()
	bounce()

func roll() -> void:
	velocity.x = ROLL_VELOCITY * Util.sign(facing_right)
	$AnimationPlayer.play("roll_{0}".format(["right" if facing_right else "left"]))

func bounce() -> void:
	velocity = BOUNCE_VELOCITY
	$AnimationPlayer.play("bounce")

func is_rolling() -> bool:
	return $AnimationPlayer.current_animation == "roll_left" or $AnimationPlayer.current_animation == "roll_right"

func take_damage() -> void:
	var echo_right := Global.echo.global_position.x > global_position.x
	facing_right = !echo_right
	roll()
	velocity.y = HIT_MICROBOUNCE
