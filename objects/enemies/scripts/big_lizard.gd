extends CharacterBody2D

const FlamePillar := preload("res://objects/projectile/flame_pillar.tscn")
const DECELERATION := 450.
const GRAVITY := Echo.GRAVITY
const MAX_GRAVITY := Echo.MAX_GRAVITY
const JUMP_IMPULSE := -200.
const JUMP_TIME := -JUMP_IMPULSE / GRAVITY
const KNOCKBACK_IMPULSE := -90.
const FIRE_DASH_IMPULSE := 200.

@export var jumping := false
@export var facing_right := false:
	set(value):
		facing_right = value
		if is_node_ready():
			sync_facing_right()

func _physics_process(delta: float) -> void:
	if jumping:
		velocity.y += GRAVITY * delta
	else:
		velocity.x = move_toward(velocity.x, 0., DECELERATION * delta)
		if Util.off_edge_in_direction(velocity.x > 0, $Left, $Right):
			velocity.x = 0.
	
	move_and_slide()
	
	if jumping and is_on_floor():
		land()

func decision_point() -> void:
	var echo_pos := Global.echo.global_position
	self.facing_right = echo_pos.x > global_position.x
	
	var head_clearence := move_and_collide(Vector2(0., -16.), true) == null
	if head_clearence and abs(global_position.y - echo_pos.y) <= 18. \
			and abs(global_position.x - echo_pos.x) > 24.:
		jump(echo_pos)
	else:
		$AnimationPlayer.play("slam")

func jump(echo_pos: Vector2) -> void:
	jumping = true
	$AnimationPlayer.play("jump")
	velocity.y = JUMP_IMPULSE
	
	var dist_to_echo := echo_pos.x - global_position.x
	velocity.x = dist_to_echo / JUMP_TIME / 2.

func land() -> void:
	jumping = false
	if !$AnimationPlayer.current_animation == "hurt" and $EnemyManager.health > 0:
		velocity = Vector2.ZERO
		$AnimationPlayer.play("land")

func on_hit() -> void:
	if !$AnimationPlayer.current_animation == "retaliate":
		var echo_pos := Global.echo.global_position
		self.facing_right = echo_pos.x > global_position.x
		$AnimationPlayer.play("hurt")
	velocity.x = KNOCKBACK_IMPULSE * Util.sign(facing_right)

func retaliate() -> void:
	if is_on_floor():
		velocity.x = FIRE_DASH_IMPULSE * Util.sign(facing_right)
		$AnimationPlayer.play("retaliate")
	else:
		$AnimationPlayer.play("jump")

func sync_facing_right() -> void:
	var facing_right_sign := Util.sign(facing_right)
	$Sprite2D.flip_h = facing_right
	$FirePunch.scale.x = -facing_right_sign
	$Fire.scale.x = -facing_right_sign

func spawn_flame_pillar():
	$BelowEcho.global_position = Global.echo.global_position
	$BelowEcho.force_raycast_update()
	if $BelowEcho.is_colliding():
		var pillar_global_pos: Vector2 = $BelowEcho.get_collision_point()
		var flame_pillar: Node2D = FlamePillar.instantiate()
		get_parent().add_child(flame_pillar)
		flame_pillar.global_position = pillar_global_pos
