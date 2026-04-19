extends CharacterBody2D

const LEFT_SPRITE_OFFSET := -1.
const RIGHT_SPRITE_OFFSET := 2.
const LEFT_CLAW_OFFSET := 0.
const RIGHT_CLAW_OFFSET := 1.
const FAR_LOOK_LENGTH := 64.
const CLOSE_LOOK_LENGTH := 32.
const BACK_LOOK_LENGTH := -12.

signal die()

@export var anim_vel := Vector2.ZERO:
	set(value):
		anim_vel = Vector2(value.x * Util.sign(!moving_right), value.y)
		velocity = anim_vel
@export var moving_right := false:
	set(value):
		moving_right = value
		if is_node_ready():
			$Sprite2D.flip_h = value
			$Sprite2D.offset.x = RIGHT_SPRITE_OFFSET if value else LEFT_SPRITE_OFFSET
			$BigMeatyClaws.scale.x = Util.sign(!value)
			$BigMeatyClaws.position.x = RIGHT_CLAW_OFFSET if value else LEFT_CLAW_OFFSET
			$FrontFarLook.target_position.x = FAR_LOOK_LENGTH * Util.sign(value)
			$FrontCloseLook.target_position.x = CLOSE_LOOK_LENGTH * Util.sign(value)
			$BackLook.target_position.x = BACK_LOOK_LENGTH * Util.sign(value)
@export var turn_on_edge := true
@export var should_arena_standby := false

func _physics_process(_delta: float) -> void:
	if $EnemyManager.health > 0 and !in_arena_standby():
		if (is_on_wall() or Util.off_edge_in_direction(moving_right, $Left, $Right)) and !$EnemyManager.post_load_frame:
			if turn_on_edge:
				moving_right = !moving_right
				velocity.x = -velocity.x
			else:
				velocity.x = 0.
		move_and_slide()
		
		if ($FrontCloseLook.is_colliding() or $BackLook.is_colliding()) and $AttackCooldownTimer.is_stopped():
			self.moving_right = Global.echo.global_position.x > global_position.x
			$AnimationPlayer.play("attack")
			$AttackCooldownTimer.start()

func emit_die() -> void:
	die.emit()

func reload() -> void:
	if should_arena_standby:
		$AnimationPlayer.play("arena_standby")
	else:
		show()
		$AnimationPlayer.play("move")

func in_arena_standby() -> bool:
	var anim: String = $AnimationPlayer.current_animation
	return anim == "arena_standby" or anim == "arena_start"

func arena_start() -> void:
	$AnimationPlayer.play("arena_start")
