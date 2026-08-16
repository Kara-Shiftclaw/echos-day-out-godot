extends CharacterBody2D

const Knife := preload("res://objects/projectile/thin_cat_knife.tscn")

enum Attack {
	Wait,
	Jump,
	JumpKnives,
	StandKnives,
	Spin,
	DoubleSpin,
	JumpDoubleSpin,
	Hide,
}

const HEIGHT_OFFSET := -9
const STAND_KNIFE_DIST := 64.
const STAND_KNIFE_DIST_SQ := STAND_KNIFE_DIST * STAND_KNIFE_DIST
const BACK_AWAY_DIST := 20.
const BACK_AWAY_DIST_SQ := BACK_AWAY_DIST * BACK_AWAY_DIST
const MAX_JUMP_DIST := 32
const JUMP_HEIGHT := 24.

@export var facing_right := false:
	set(value):
		facing_right = value
		sync_facing_right()
@export var should_hide := false
var last_attack := Attack.Wait
var jump: Util.QuadraticJump = null
var platform_edge_l: float
var platform_edge_r: float


func _ready() -> void:
	var platform_size: ReferenceRect = get_node_or_null("ReferenceRect")
	if platform_size != null:
		platform_edge_l = platform_size.global_position.x
		platform_edge_r = platform_edge_l + platform_size.size.x
	else:
		var chunk: Vector2i = $EnemyManager.chunk
		platform_edge_l = chunk.x * Util.ROOM_SIZE
		platform_edge_r = (chunk.x + 1) * Util.ROOM_SIZE 

func _physics_process(delta: float) -> void:
	$PlayerSight.target_position = Global.echo.global_position - $PlayerSight.global_position
	if last_attack == Attack.Wait and !$EnemyManager.post_load_frame and \
			$PlayerSight.is_colliding() and $PlayerSight.get_collider() is Player:
		decision_point()
	
	if jump != null:
		velocity.y += jump.gravity * delta
		move_and_slide()
		if is_on_floor():
			jump = null


func on_load_alive() -> void:
	show()
	if should_hide:
		last_attack = Attack.Hide
		$AnimationPlayer.play("hide")
		$AnimationPlayer.call_deferred("seek", 0., true)
		$AppearDetector/AppearDetectorShape.set_deferred("disabled", false)

func detect_player(other: Node2D) -> void:
	if other is Player and should_hide and $Hurtbox/CollisionShape2D.disabled:
		$AnimationPlayer.play("appear")
		$AppearDetector/AppearDetectorShape.set_deferred("disabled", true)


func decision_point() -> void:
	init_attack(next_attack())

func next_attack() -> Attack:
	if $PlayerSight.get_collider() == null or !($PlayerSight.get_collider() is Player):
		return Attack.Wait
	
	if Global.echo_is_right(self) != facing_right:
		return Attack.Spin
	
	var player_dist_sq := ($PlayerSight.target_position as Vector2).length_squared()
	if player_dist_sq >= STAND_KNIFE_DIST_SQ:
		return Attack.Wait
	
	var exclusions: Array[String] = [atk_str(last_attack)]
	return Attack.get($RandomAttackSelector.select_attack(exclusions), Attack.Wait)

func init_attack(attack: Attack) -> void:
	last_attack = attack
	match attack:
		Attack.Wait:
			$AnimationPlayer.play("idle")
		Attack.Jump:
			$AnimationPlayer.play("jump")
			prepare_jump()
		Attack.JumpKnives:
			$AnimationPlayer.play("throw_knives")
			prepare_jump()
		Attack.StandKnives:
			$AnimationPlayer.play("throw_knives")
		Attack.Spin:
			$AnimationPlayer.play("turn")
		Attack.DoubleSpin:
			$AnimationPlayer.play("double_turn")
		Attack.JumpDoubleSpin:
			prepare_jump()
			$AnimationPlayer.play("jump_double_spin")
		_:
			init_attack(Attack.Wait)


func throw_knife() -> void:
	var knife: Node2D = Knife.instantiate()
	knife.fire_angle = ($PlayerSight.target_position as Vector2).angle()
	get_parent().add_child(knife)
	knife.global_position = global_position + Vector2(0., HEIGHT_OFFSET)

func turn() -> void:
	self.facing_right = !facing_right

func auto_face_player() -> void:
	if Global.echo_is_right(self) != facing_right:
		turn()

func prepare_jump(duration := 0.8) -> void:
	var x_offset := get_jump_x_offset()
	jump = Util.calculate_quadratic_jump(x_offset, JUMP_HEIGHT, duration)
	velocity = jump.initial_velocity


func get_jump_x_offset() -> float:
	var jump_right := Global.echo_is_right(self)
	
	if jump_right:
		return minf(MAX_JUMP_DIST, platform_edge_r - global_position.x)
	else:
		return maxf(-MAX_JUMP_DIST, platform_edge_l - global_position.x)

func sync_facing_right() -> void:
	if is_node_ready():
		$SpriteHolder.scale.x = Util.sign(!facing_right)

func atk_str(attack: Attack) -> String:
	return Attack.keys()[attack]
