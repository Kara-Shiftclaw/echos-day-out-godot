extends CharacterBody2D

signal die()

enum Attack {
	Slam,
	WallJump,
	SpinThrow,
	Repeat,
}

const ODDS_OF_ATTACK: Dictionary[Attack, int] = {
	Attack.Slam: 7,
	Attack.WallJump: 4,
	Attack.SpinThrow: 5,
	Attack.Repeat: 3,
}
const STARTING_PREV_ATTACKS: Array[Attack] = [
	Attack.WallJump,
	Attack.SpinThrow,
	Attack.SpinThrow
]
const ECHO_RUN_BUFFER_RANGE := 16.
const RUN_VELOCITY := Echo.SPEED_MAP[Global.Weight.Thin]
const JUMP_HEIGHT := 64.
const JUMP_TIME := 0.8
const DIE_KNOCKBACK := -20. * 8.
const DIE_DECELERATION := 128. * 8.

@export var facing_right := true:
	set(value):
		facing_right = value
		if is_node_ready():
			sync_facing_right()
@export var left_wall_jump: Node2D
@export var right_wall_jump: Node2D

var gravity: float
var wall_jump_impulse: Vector2
var moving_to: Node2D = null
var prev_attacks := STARTING_PREV_ATTACKS.duplicate()
var current_attack: Attack = Attack.Slam

func arena_start() -> void:
	velocity = Vector2.ZERO
	$AnimationPlayer.play("arena_start")

func _physics_process(delta: float) -> void:
	if moving_to != null:
		var dest_x := moving_to.global_position.x
		var movement := move_toward(global_position.x, dest_x, RUN_VELOCITY * delta) - global_position.x
		move_and_collide(Vector2(movement, 0.))
		if global_position.x == dest_x or \
				(moving_to is Player and abs(global_position.x - dest_x) < ECHO_RUN_BUFFER_RANGE):
			attack_after_run(current_attack)
	elif $AnimationPlayer.current_animation == "wall_jump":
		velocity.y += gravity * delta
		move_and_slide()
	elif $AnimationPlayer.current_animation == "die":
		velocity.x = move_toward(velocity.x, 0., delta * DIE_DECELERATION)
		move_and_slide()

func on_death() -> void:
	die.emit()
	self.facing_right = Global.echo_is_right(self)
	moving_to = null
	velocity.x = DIE_KNOCKBACK * Util.sign(facing_right)
	$AnimationPlayer.play("die")

func decision_point() -> void:
	var latest_attack = current_attack
	prev_attacks.push_front(latest_attack)
	prev_attacks.pop_back()
	
	var odds := ODDS_OF_ATTACK.duplicate()
	odds.erase(latest_attack)
	for prev_attack in prev_attacks:
		if odds.has(prev_attack):
			odds[prev_attack] = clamp(odds[prev_attack] - 1, 0, 99)
	
	var total_odds: int = odds.keys().reduce(func(accum, odd) -> int:
		return accum + odd
	, 0)
	var choice := randi_range(0, total_odds)
	for attack in odds:
		choice -= odds[attack]
		if choice <= 0 and attack != Attack.Repeat:
			current_attack = attack
			break
	init_attack(current_attack)

func init_attack(attack: Attack) -> void:
	moving_to = null
	self.facing_right = Global.echo_is_right(self)
	match attack:
		Attack.Slam:
			$AnimationPlayer.play("walk")
			moving_to = Global.echo
		Attack.WallJump:
			var left_dist := global_position.distance_to(left_wall_jump.global_position)
			var right_dist := global_position.distance_to(right_wall_jump.global_position)
			self.facing_right = right_dist < left_dist
			moving_to = right_wall_jump if facing_right else left_wall_jump
			$AnimationPlayer.play("walk")
		Attack.SpinThrow:
			$AnimationPlayer.play("spin_throw")
		#Attack.JumpSlam:
			#$AnimationPlayer.play("jump_fire")
		_:
			print("Attack ", attack, ", choosing a new one")
			decision_point()

func attack_after_run(attack: Attack) -> void:
	match attack:
		Attack.Slam:
			self.facing_right = Global.echo_is_right(self)
			$AnimationPlayer.play("slam")
		Attack.WallJump:
			var jump := Util.calculate_quadratic_jump(12. * 4., JUMP_HEIGHT, JUMP_TIME)
			gravity = jump.gravity
			wall_jump_impulse = jump.initial_velocity
			$AnimationPlayer.play("wall_jump")
		_:
			push_warning("Attack ", attack, " doesn't have a run follow-up, choosing new one")
			decision_point()
	moving_to = null

func start_wall_jump() -> void:
	velocity = wall_jump_impulse
	velocity.x *= Util.sign(facing_right)

func jump_off_wall(dur_into_jump: float = 0.3) -> void:
	self.facing_right = !facing_right
	var dist_to_echo := Global.echo.global_position.x - global_position.x
	var time_left := JUMP_TIME - dur_into_jump
	velocity.x = dist_to_echo / time_left

func land_wall_jump() -> void:
	velocity = Vector2.ZERO

func sync_facing_right() -> void:
	var flip_sign := Util.sign(!facing_right)
	$SpriteContainer.scale.x = flip_sign
	$Hurtbox.scale.x = flip_sign
	$DamageBox.scale.x = flip_sign

func timeout_damage() -> void:
	$DamageBox/Damage.active = false
	get_tree().create_timer(0.1).timeout.connect(func():
		$DamageBox/Damage.active = true
	)
