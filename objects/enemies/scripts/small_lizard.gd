extends CharacterBody2D

enum State {
	WallCling,
	Notice,
	Jumping,
	Walking,
	FireDash,
	Dead,
}
const FlamePillar := preload("res://objects/projectile/flame_pillar.tscn")

const GRAVITY := Echo.GRAVITY
const JUMP_IMPULSE := -160.
const JUMP_X_VELOCITY := 60.
const WALK_X_VELOCITY := 60.
const FIRE_DASH_IMPULSE := 120.
const FIRE_DASH_DECELERATION := 180.
const NOTICE_RANGE := 48.

@export var facing_right := false:
	set(value):
		facing_right = value
		if is_node_ready():
			sync_facing_right()
@export var state := State.WallCling:
	set(value):
		if !(state == State.Dead and value != State.WallCling):
			state = value
		else:
			print("State change blocked!")

signal jumped_off_wall()

func _ready() -> void:
	sync_facing_right()

func _physics_process(delta: float) -> void:
	if state == State.WallCling:
		velocity = Vector2.ZERO
		var delta_to_echo: Vector2 = Global.echo.global_position - $PlayerSight.global_position
		$PlayerSight.target_position = delta_to_echo.normalized() * NOTICE_RANGE
		$PlayerSight.force_raycast_update()
		if $PlayerSight.get_collider() == Global.echo:
			$AnimationPlayer.play("notice")
	elif state == State.Jumping:
		velocity.y += GRAVITY * delta
		if is_on_floor():
			if $Left.valid_floor:
				spawn_flame_pillar($Left.global_position)
			if $Right.valid_floor:
				spawn_flame_pillar($Right.global_position)
			velocity = Vector2.ZERO
			$AnimationPlayer.play("land")
			state = State.Walking
			sync_facing_right()
	elif state == State.Walking:
		if Util.off_edge_in_direction(facing_right, $Left, $Right) or is_on_wall():
			self.facing_right = !facing_right
		velocity.x = WALK_X_VELOCITY * Util.sign(facing_right)
		if $PlayerSight.get_collider() == Global.echo and $FireDashCooldown.is_stopped():
			$AnimationPlayer.play("fire_dash")
	elif state == State.FireDash:
		velocity.x = move_toward(velocity.x, 0., FIRE_DASH_DECELERATION * delta)
		if Util.off_edge_in_direction(facing_right, $Left, $Right):
			velocity.x = 0
	elif state == State.Dead:
		velocity.x = 0.
		velocity.y += GRAVITY * delta
	
	move_and_slide()

func jump() -> void:
	$AnimationPlayer.play("jump")
	jumped_off_wall.emit()
	facing_right = !facing_right
	velocity = Vector2(JUMP_X_VELOCITY * Util.sign(facing_right), JUMP_IMPULSE)

func fire_dash_pounce() -> void:
	velocity.x = FIRE_DASH_IMPULSE * Util.sign(facing_right)

func sync_facing_right() -> void:
	var facing_right_sign := Util.sign(facing_right)
	$Sprite2D.flip_h = facing_right
	$FirePunch.scale.x = -facing_right_sign
	$Fire.scale.x = -facing_right_sign
	if state == State.Walking:
		$PlayerSight.target_position = Vector2.RIGHT * facing_right_sign * NOTICE_RANGE

func spawn_flame_pillar(pillar_global_pos: Vector2):
	var flame_pillar: Node2D = FlamePillar.instantiate()
	flame_pillar.creator_chunk = $EnemyManager.chunk
	flame_pillar.global_position = pillar_global_pos
	get_parent().add_child(flame_pillar)
