class_name Echo
extends CharacterBody2D

const SPEED_MAP := {
	Weight.Thin: 10. * 8.,
	Weight.Chubby: 10. * 8.,
	Weight.Fat: 8. * 8.,
	Weight.Obese: 5. * 8.,
	Weight.Blob: 2. * 8.,
}
const ACCELERATION_MAP := {
	Weight.Thin: 200. * 8.,
	Weight.Chubby: 200. * 8.,
	Weight.Fat: 175. * 8.,
	Weight.Obese: 125. * 8.,
	Weight.Blob: 75. * 8.,
}
const JUMP_VELOCITY_MAP := {
	Weight.Thin: -14. * 8.,
	Weight.Chubby: -14. * 8.,
	Weight.Fat: -11. * 8.,
	Weight.Obese: -8. * 8.,
	Weight.Blob: -6. * 8.,
}
const GRAVITY = 120. * 8.
const JUMP_TIME_MAP := {
	Weight.Thin: 3.5 * 8. / -JUMP_VELOCITY_MAP[Weight.Thin],
	Weight.Chubby: 3.5 * 8. / -JUMP_VELOCITY_MAP[Weight.Chubby],
	Weight.Fat: 3. * 8. / -JUMP_VELOCITY_MAP[Weight.Fat],
	Weight.Obese: 1.75 * 8. / -JUMP_VELOCITY_MAP[Weight.Obese],
	Weight.Blob: 1. * 8. / -JUMP_VELOCITY_MAP[Weight.Blob],
}
const HITBOX_SIZE_MAP := {
	Weight.Thin: 6.,
	Weight.Chubby: 7.,
	Weight.Fat: 9.,
	Weight.Obese: 11.,
	Weight.Blob: 15.,
}
const HITBOX_OFFSET_MAP := {
	Weight.Thin: 0.,
	Weight.Chubby: 0.5,
	Weight.Fat: 1.5,
	Weight.Obese: 0.5,
	Weight.Blob: 1.,
}
const FIREBALL_KNOCKBACK_MAP := {
	Weight.Thin: -20. * 8.,
	Weight.Chubby: -20. * 8.,
	Weight.Fat: -18. * 8.,
	Weight.Obese: -15. * 8.,
	Weight.Blob: -12. * 8.,
}

const MAX_GRAVITY := -JUMP_VELOCITY_MAP[Weight.Thin]
const HEALTH_TIME = 30.
const SPRINT_SPEED = 14. * 8.
const EXPLODE_FALL_SPEED := 48. * 8.

enum Weight {
	Thin = 0,
	Chubby = 1,
	Fat = 2,
	Obese = 3,
	Blob = 4
}

@export var can_move := true
@export var weight := Weight.Thin

var facing_right := true

func _physics_process(delta: float) -> void:
	if can_move:
		var desired_vel := SPEED_MAP[weight] as float * Input.get_axis("ui_left", "ui_right")
		velocity.x = move_toward(velocity.x, desired_vel, ACCELERATION_MAP[weight] * delta)
		
		if is_on_floor():
			$CoyoteTimeTimer.start()
		if !$CoyoteTimeTimer.is_stopped() and Input.is_action_just_pressed("jump"):
			$CoyoteTimeTimer.stop()
			$JumpTimer.start(JUMP_TIME_MAP[weight])
		
		if !$JumpTimer.is_stopped():
			velocity.y = JUMP_VELOCITY_MAP[weight]
			if !Input.is_action_pressed("jump"):
				$JumpTimer.stop()
		else:
			velocity.y = move_toward(velocity.y, MAX_GRAVITY, GRAVITY * delta)
		
		move_and_slide()
