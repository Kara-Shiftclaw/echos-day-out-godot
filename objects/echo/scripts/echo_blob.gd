extends Player

const MAX_SPEED: float = Echo.SPEED_MAP[Global.Weight.Thin]
const ACCELERATION: float = Echo.ACCELERATION_MAP[Global.Weight.Thin]
const JUMP_VELOCITY: float = Echo.JUMP_VELOCITY_MAP[Global.Weight.Obese]
const JUMP_TIME: float = 4.5 * 8. / -JUMP_VELOCITY
const GRAVITY := Echo.GRAVITY
const MAX_GRAVITY := Echo.MAX_GRAVITY
const SPRINT_SPEED := Echo.SPRINT_SPEED
const ATTACK_SPEED := Echo.DASH_SPEED
const NEW_STAGE_JUMP_HEIGHT := Echo.NEW_STAGE_JUMP_HEIGHT

@export var can_move := true
var can_attack := true
var jump_locked := false

func sync_facing_right() -> void:
	$Sprite2D.flip_h = !facing_right

func set_anim(anim_name: String) -> bool:
	var prev_anim: String = $AnimationPlayer.current_animation
	if $AnimationPlayer.has_animation(anim_name):
		$AnimationPlayer.play(anim_name)
		return prev_anim != anim_name
	else:
		return false

func anim_seek(seconds := 0., update := false) -> void:
	$AnimationPlayer.seek(seconds, update)

func get_desired_speed() -> float:
	if is_sprinting:
		return SPRINT_SPEED
	else:
		return MAX_SPEED

func get_acceleration() -> float:
	return ACCELERATION

func new_stage_jump():
	$JumpTimer.start(NEW_STAGE_JUMP_HEIGHT / -JUMP_VELOCITY)
	jump_locked = true
	play_anim("jump", 1)

func on_respawn_same_stage() -> void:
	can_move = true

func should_be_player() -> bool:
	return Global.is_smol


func _physics_process(delta: float) -> void:
	if can_move:
		if Input.is_action_just_pressed("attack") and can_attack and $AttackCooldownTimer.is_stopped():
			attack()
		if !is_attacking():
			if $DamageBox/Damage.active:
				stop_attack()
			
			if Input.is_action_pressed("sprint"):
				is_sprinting = true
			
			calculate_x_movement(delta)
		
		if is_on_floor():
			process_on_floor()
			$CoyoteTimeTimer.start()
			can_attack = true
			can_double_jump = false
			if is_cur_anim("jump"):
				anim_priority = 0
				play_anim("walk")
		else:
			on_floor = false
		
		if Input.is_action_just_pressed("jump"):
			if !$CoyoteTimeTimer.is_stopped():
				$CoyoteTimeTimer.stop()
				$JumpTimer.start(JUMP_TIME)
				play_anim("jump", 1)
			elif can_double_jump:
				$JumpTimer.start(Echo.DOUBLE_JUMP_HEIGHT / -JUMP_VELOCITY)
				can_double_jump = false
				if !play_anim("double_jump", 1):
					play_anim("jump", 1)
		
		if !$JumpTimer.is_stopped():
			velocity.y = JUMP_VELOCITY
			if !(Input.is_action_pressed("jump") or jump_locked) or is_on_ceiling():
				$JumpTimer.stop()
		else:
			var cur_gravity := GRAVITY if !is_attacking() else GRAVITY / 2.
			velocity.y = move_toward(velocity.y, MAX_GRAVITY, cur_gravity * delta)
			jump_locked = false
		
		move_and_slide()

func is_cur_anim(anim_name: String) -> bool:
	return $AnimationPlayer.current_animation == anim_name

func attack() -> void:
	can_attack = false
	$AttackCooldownTimer.start()
	$JumpTimer.stop()
	$CoyoteTimeTimer.stop()
	
	velocity.x = Util.sign(facing_right) * ATTACK_SPEED
	velocity.y = 0.
	$DamageBox/Damage.active = true
	$DamageBox/CollisionShape2D.set_deferred("disabled", false)
	$EnemyHurtbox/CollisionShape2D.set_deferred("disabled", true)
	$StageHurtbox/CollisionShape2D.set_deferred("disabled", true)
	play_anim("attack", 2)

func attack_hit() -> void:
	velocity = Vector2(0., Echo.STAGE_HAZARD_BOUNCE)
	can_attack = true
	stop_attack(true)

func stop_attack(successful := false) -> void:
	$DamageBox/Damage.active = false
	$DamageBox/CollisionShape2D.set_deferred("disabled", true)
	anim_priority = 0
	rotation = 0.
	
	if successful:
		var hurtbox_enable_timer := get_tree().create_timer(0.05)
		hurtbox_enable_timer.timeout.connect(func():
			$EnemyHurtbox/CollisionShape2D.set_deferred("disabled", false)
			$StageHurtbox/CollisionShape2D.set_deferred("disabled", false)
		)
	else:
		$EnemyHurtbox/CollisionShape2D.set_deferred("disabled", false)
		$StageHurtbox/CollisionShape2D.set_deferred("disabled", false)

func is_attacking() -> bool:
	return is_cur_anim("attack")
