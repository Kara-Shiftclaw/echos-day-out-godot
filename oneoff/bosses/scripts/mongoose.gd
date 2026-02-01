extends CharacterBody2D

const Fireball := preload("res://oneoff/bosses/mongoose_fireball.tscn")
const Crown := preload("res://oneoff/bosses/mongoose_crown.tscn")
const FlamePillar := preload("res://objects/projectile/flame_pillar.tscn")

enum Attack {
	Start,
	
	Shadowboxing,
	GoodJump,
	BadJump,
	CrownThrow,
	JumpFire
}

const ODDS_OF_ATTACK: Dictionary[Attack, int] = {
	Attack.Shadowboxing: 7,
	Attack.GoodJump: 5,
	Attack.BadJump: 3,
	Attack.CrownThrow: 3,
	Attack.JumpFire: 5
}
const STARTING_PREV_ATTACKS: Array[Attack] = [
	Attack.CrownThrow,
	Attack.BadJump,
	Attack.BadJump,
	Attack.CrownThrow,
	Attack.JumpFire,
]
const CROWN_RUN_SPEED := 12. * 8.
const CROWN_RUN_MARGIN := 4.
const LEFT_PILLAR_OFFSET := Vector2(-10., 12.)
const RIGHT_PILLAR_OFFSET := Vector2(10., 12.)

@export var facing_right := true:
	set(value):
		facing_right = value
		if is_node_ready():
			sync_facing_right()
@export var can_move := true

var prev_attacks := STARTING_PREV_ATTACKS.duplicate()
var current_attack: Attack = Attack.Start
var gravity := 0.
var crown: Node2D = null

func _ready() -> void:
	sync_facing_right()
	decision_point()

func _physics_process(delta: float) -> void:
	if can_move:
		if crown != null:
			move_and_slide()
			if is_on_wall():
				crown.queue_free()
				crown = null
				$AnimationPlayer.play("crown_pickup")
		else:
			velocity.y += gravity * delta
			move_and_slide()

func decision_point() -> void:
	can_move = true
	var latest_attack = current_attack
	if latest_attack != Attack.Start:
		prev_attacks.push_front(latest_attack)
		prev_attacks.pop_back()
	else:
		latest_attack = prev_attacks[0]
	
	var odds := ODDS_OF_ATTACK.duplicate()
	odds.erase(latest_attack)
	if $EnemyManager.health > $EnemyManager.max_health / 2:
		pass#odds.erase(Attack.CrownThrow)
	for prev_attack in prev_attacks:
		if odds.has(prev_attack):
			odds[prev_attack] = clamp(odds[prev_attack] - 1, 0, 99)
	
	var total_odds: int = odds.keys().reduce(func(accum, odd) -> int:
		return accum + odd
	, 0)
	var choice := randi_range(0, total_odds)
	for attack in odds:
		choice -= odds[attack]
		if choice <= 0:
			current_attack = attack
			break
	init_attack(current_attack)

func init_attack(attack: Attack):
	self.facing_right = Global.echo.global_position.x > global_position.x
	set_deferred("velocity", Vector2.ZERO)
	match attack:
		Attack.Shadowboxing:
			$AnimationPlayer.play("shadowboxing")
		Attack.GoodJump:
			$AnimationPlayer.play("good_jump")
		Attack.BadJump:
			$AnimationPlayer.play("bad_jump")
		Attack.JumpFire:
			$AnimationPlayer.play("jump_fire")
		Attack.CrownThrow:
			$AnimationPlayer.play("crown_throw")
		_:
			print("Attack ", attack, ", choosing a new one")
			decision_point()

func sync_facing_right() -> void:
	$Sprite2D.flip_h = !facing_right

func shoot_fireball() -> void:
	var fireball: Node2D = Fireball.instantiate()
	fireball.moving_right = facing_right
	get_parent().add_child(fireball)
	fireball.global_position = global_position + Vector2(4. * Util.sign(facing_right), 0.)
	fireball.aim(Global.echo.global_position)

func jump_to(x_offset: float, max_height: float, duration_to_even: float) -> void:
	var jump := Util.calculate_quadratic_jump(Util.sign(facing_right) * x_offset, max_height, duration_to_even)
	velocity = jump.initial_velocity
	gravity = jump.gravity

func stop_move() -> void:
	velocity.x = 0.
	gravity = 0.

func jump_land() -> void:
	stop_move()
	spawn_flame_pillar(global_position + LEFT_PILLAR_OFFSET)
	spawn_flame_pillar(global_position + RIGHT_PILLAR_OFFSET)

func spawn_flame_pillar(pillar_global_pos: Vector2) -> void:
	var flame_pillar: Node2D = FlamePillar.instantiate()
	get_parent().add_child(flame_pillar)
	flame_pillar.global_position = pillar_global_pos

func throw_crown() -> void:
	crown = Crown.instantiate()
	crown.moving_right = facing_right
	get_parent().add_child(crown)
	crown.global_position = global_position + Vector2(12. * Util.sign(facing_right), 4.)
	Global.echo.respawned.connect(crown.queue_free)

func begin_crown_run() -> void:
	velocity.x = CROWN_RUN_SPEED * Util.sign(facing_right)
	$AnimationPlayer.play("crown_run")

func is_crown_running() -> bool:
	return $AnimationPlayer.current_animation == "crown_run"

func die() -> void:
	Engine.time_scale = 0.25
	velocity = Vector2.ZERO
	gravity = 0.
	crown = null
	self.facing_right = Global.echo.global_position.x > global_position.x
	$AnimationPlayer.play("die")

func resume_normal_speed() -> void:
	Engine.time_scale = 1.
	jump_to(-32., 32., 0.4)
