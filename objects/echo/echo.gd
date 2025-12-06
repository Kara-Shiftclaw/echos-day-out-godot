class_name Echo
extends CharacterBody2D

const Attack := preload("res://objects/echo/attack.tscn")
const DeathScreen := preload("res://objects/echo/particle/death_screen.tscn")

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
const STAGE_HAZARD_BOUNCE := -1.5 * MAX_GRAVITY
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
@export var health: float:
	get:
		if cur_save_point != null:
			return max_health
		else:
			return $HealthTimer.time_left
	set(value):
		if value <= 0.:
			$HealthTimer.start(0.01)
		else:
			$HealthTimer.start(clamp(value, 0., max_health))
@export var max_health := HEALTH_TIME

var cur_save_point: Node = null
var last_save_pos := Vector2.INF

var facing_right := true:
	set(value):
		facing_right = value
		$Sprite2D.flip_h = !value

func _ready() -> void:
	Global.echo = self

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		if is_on_floor():
			play_anim("attack")

func _physics_process(delta: float) -> void:
	if can_move:
		var desired_vel := SPEED_MAP[weight] as float * Input.get_axis("ui_left", "ui_right")
		velocity.x = move_toward(velocity.x, desired_vel, ACCELERATION_MAP[weight] * delta)
		if desired_vel != 0.:
			facing_right = desired_vel > 0
		
		if is_on_floor():
			$CoyoteTimeTimer.start()
		if !$CoyoteTimeTimer.is_stopped() and Input.is_action_just_pressed("jump"):
			$CoyoteTimeTimer.stop()
			$JumpTimer.start(JUMP_TIME_MAP[weight])
		
		if !$JumpTimer.is_stopped():
			velocity.y = JUMP_VELOCITY_MAP[weight]
			if !Input.is_action_pressed("jump") or is_on_ceiling():
				$JumpTimer.stop()
		else:
			velocity.y = move_toward(velocity.y, MAX_GRAVITY, GRAVITY * delta)
		
		move_and_slide()

func do_attack() -> void:
	var attack: Area2D = Attack.instantiate()
	var facing_sign := Util.sign(facing_right)
	attack.scale.x = facing_sign
	add_child(attack)
	attack.position = Vector2(facing_sign * 10., 0.)

func play_anim(anim_name: String) -> void:
	var full_name = "{0}_{1}".format([weight as int, anim_name])
	$AnimationPlayer.play(full_name)

func enter_save_point(save_point: Node2D) -> void:
	$HealthTimer.stop()
	cur_save_point = save_point
	last_save_pos = save_point.global_position

func exit_save_point(save_point: Node2D) -> void:
	if save_point == cur_save_point:
		$HealthTimer.start(max_health)
		cur_save_point = null

func on_hit(attacker: Node2D) -> void:
	var maybe_damage = attacker.get_node_or_null("Damage")
	if maybe_damage != null and maybe_damage.active:
		take_damage(maybe_damage.damage)
		
func take_damage(amount: float) -> void:
	play_anim("hurt")
	$HurtParticles.amount = amount
	$HurtParticles.restart()
	health -= amount

func stage_hurtbox_hit(_other: Node2D) -> void:
	take_damage(3.)
	velocity.y = STAGE_HAZARD_BOUNCE

func spawn_death_screen() -> void:
	var death_screen := DeathScreen.instantiate()
	Global.camera.add_child(death_screen)

func respawn() -> void:
	$StageHurtbox/CollisionShape2D.set_deferred("disabled", false)
	$EnemyHurtbox/CollisionShape2D.set_deferred("disabled", false)
	$Sprite2D.show()
	global_position = last_save_pos
	can_move = true
	velocity = Vector2.ZERO
	play_anim("idle")
