extends CharacterBody2D

enum State {
	Waddle,
	Dash,
	Pause,
	EdgePause,
	ArenaStandby,
}

signal on_death()

const MOVE_SPEED := 5. * 8.
const DASH_SPEED := 10. * 8.
const KEEP_INERTIA_DECELERATION := 128. * 8.
const DASH_WALL_HIT_KNOCKBACK := -10. * 8.
const DIE_KNOCKBACK := -20. * 8.
const SPRITE_OFFSET := -1.5

@export var moving_right := false:
	set(value):
		moving_right = value
		if is_node_ready():
			update_sprite_flip()
@export var state := State.Waddle
@export var keep_inertia := false
@export var should_arena_standby := false

func _ready() -> void:
	update_sprite_flip()

func _physics_process(delta: float) -> void:
	if state == State.Waddle:
		velocity.x = MOVE_SPEED * Util.sign(moving_right)
		move_and_slide()
		if is_on_wall():
			$AnimationPlayer.play("wait_at_wall")
		if !$EnemyManager.post_load_frame and Util.off_edge_in_direction(moving_right, $Left, $Right):
			$AnimationPlayer.play("wait_at_edge")
	elif state == State.Dash:
		velocity.x = DASH_SPEED * Util.sign(moving_right)
		velocity.y += Echo.GRAVITY * delta
		move_and_slide()
		if is_on_wall():
			velocity.x = DASH_WALL_HIT_KNOCKBACK * Util.sign(moving_right)
			keep_inertia = true
			$AnimationPlayer.play("dash_into_wall")
		if Util.off_screen_in_direction(moving_right, $Left, $Right):
			$AnimationPlayer.play("wait_at_edge")
	elif is_pause_state():
		if keep_inertia:
			velocity.x = move_toward(velocity.x, 0., delta * KEEP_INERTIA_DECELERATION)
			if velocity.x == 0.:
				keep_inertia = false
		else:
			velocity.x = 0.
		velocity.y += Echo.GRAVITY * delta
		move_and_slide()
	
	if !$EnemyManager.post_load_frame and can_dash_state():
		if $PlayerSight.is_colliding() and $PlayerSight.get_collider() is Echo:
			$AnimationPlayer.play("dash")

func turn_around() -> void:
	self.moving_right = !moving_right

func update_sprite_flip() -> void:
	$Wolf.flip_h = moving_right
	$Wolf.position.x = SPRITE_OFFSET * Util.sign(moving_right)
	$PlayerSight.position.x = SPRITE_OFFSET * Util.sign(moving_right)
	$PlayerSight.target_position.x = 128. * Util.sign(moving_right)

func is_pause_state() -> bool:
	return state == State.Pause or state == State.EdgePause

func can_dash_state() -> bool:
	return state == State.Waddle or state == State.EdgePause

func die() -> void:
	var player_right := Global.echo.global_position.x > global_position.x
	moving_right = player_right
	velocity.x = DIE_KNOCKBACK * Util.sign(player_right)
	$AnimationPlayer.play("die")
	$AnimationPlayer.seek(0., true)
	$EnemyDieSound.play()
	on_death.emit()

func reload() -> void:
	if $EnemyManager.health > 0:
		if should_arena_standby:
			$AnimationPlayer.play("arena_standby")
			hide()
			state = State.ArenaStandby
		else:
			show()
			$AnimationPlayer.play("waddle")
			state = State.Waddle
			$Wolf.frame = 0
	else:
		hide()

func arena_start() -> void:
	$AnimationPlayer.play("arena_start")
