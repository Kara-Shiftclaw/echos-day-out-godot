extends CharacterBody2D

const SWIM_SPEED := 7. * 8.
const DIVE_VELOCITY := Vector2(0., 16. * 8.)
const DIE_H_VELOCITY := 12. * 8.
const DIE_V_IMPULSE := -10. * 8.
const DIE_DECELERATION := 15. * 8.

@export var facing_right := false:
	set(value):
		facing_right = value
		if is_node_ready():
			$Sprite2D.scale.x = Util.sign(!facing_right)

@export var state := State.Flutter
var base_height: float

enum State {
	Flutter,
	Dive,
	Stun,
	Dead,
}

func _ready() -> void:
	base_height = position.y
	$EnemyManager.set_save_property("base_height", base_height)

func _physics_process(delta: float) -> void:
	$Hurtbox/CollisionShape2D.shape = $CollisionShape2D.shape
	match state:
		State.Flutter:
			velocity.x = SWIM_SPEED * Util.sign(facing_right)
			if move_toward(position.y, base_height, SWIM_SPEED * delta) == base_height:
				velocity.y = 0
			else:
				velocity.y = SWIM_SPEED * Util.sign(position.y < base_height)
			move_and_slide()
			
			if is_on_ceiling():
				base_height = position.y
			if is_on_wall() or Util.off_screen_in_direction(facing_right, $Left, $Right):
				facing_right = !facing_right
			
			if $RayCast2D.is_colliding() and $RayCast2D.get_collider() is Player:
				$AnimationPlayer.play("prepare_dive")
		State.Dive:
			velocity = DIVE_VELOCITY
			move_and_slide()
			
			if is_on_floor() or !$DiveOffscreen.is_on_screen():
				$AnimationPlayer.play("dive_hit_stun")
		State.Dead:
			velocity.y += Echo.GRAVITY * delta
			velocity.x = move_toward(velocity.x, 0., DIE_DECELERATION * delta)
			move_and_slide()

func on_player_hit() -> void:
	if state == State.Dive:
		state = State.Flutter
		$AnimationPlayer.play("flutter")
		$Damage.active = false
	$RayCast2D.enabled = false

func die() -> void:
	$AnimationPlayer.play("die")
	state = State.Dead
	velocity.x = DIE_H_VELOCITY * Util.sign(Global.echo.global_position.x < global_position.x)
	velocity.y = DIE_V_IMPULSE
