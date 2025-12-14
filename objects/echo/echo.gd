class_name Echo
extends CharacterBody2D

const Attack := preload("res://objects/echo/attack.tscn")
const DeathScreen := preload("res://objects/echo/particle/death_screen.tscn")
const Weight := Global.Weight

const SPEED_MAP: Dictionary[Weight, float] = {
	Weight.Thin: 10. * 8.,
	Weight.Fat: 10. * 8.,
	Weight.Obese: 8. * 8.,
	Weight.MorObese: 5. * 8.,
	Weight.Blob: 2. * 8.,
}
const ACCELERATION_MAP: Dictionary[Weight, float] = {
	Weight.Thin: 200. * 8.,
	Weight.Fat: 200. * 8.,
	Weight.Obese: 175. * 8.,
	Weight.MorObese: 125. * 8.,
	Weight.Blob: 75. * 8.,
}
const JUMP_VELOCITY_MAP: Dictionary[Weight, float] = {
	Weight.Thin: -14. * 8.,
	Weight.Fat: -14. * 8.,
	Weight.Obese: -11. * 8.,
	Weight.MorObese: -8. * 8.,
	Weight.Blob: -6. * 8.,
}
const GRAVITY = 120. * 8.
const JUMP_TIME_MAP: Dictionary[Weight, float] = {
	Weight.Thin: 3.5 * 8. / -JUMP_VELOCITY_MAP[Weight.Thin],
	Weight.Fat: 3.5 * 8. / -JUMP_VELOCITY_MAP[Weight.Fat],
	Weight.Obese: 3. * 8. / -JUMP_VELOCITY_MAP[Weight.Obese],
	Weight.MorObese: 1.75 * 8. / -JUMP_VELOCITY_MAP[Weight.MorObese],
	Weight.Blob: 1. * 8. / -JUMP_VELOCITY_MAP[Weight.Blob],
}
const HITBOX_SIZE_MAP: Dictionary[Weight, float] = {
	Weight.Thin: 6.,
	Weight.Fat: 7.,
	Weight.Obese: 9.,
	Weight.MorObese: 11.,
	Weight.Blob: 15.,
}
const HITBOX_OFFSET_MAP: Dictionary[Weight, float] = {
	Weight.Thin: 0.,
	Weight.Fat: 0.5,
	Weight.Obese: 1.5,
	Weight.MorObese: 0.5,
	Weight.Blob: 1.,
}
const FIREBALL_KNOCKBACK_MAP: Dictionary[Weight, float] = {
	Weight.Thin: -20. * 8.,
	Weight.Fat: -20. * 8.,
	Weight.Obese: -18. * 8.,
	Weight.MorObese: -15. * 8.,
	Weight.Blob: -12. * 8.,
}

const MAX_GRAVITY := -JUMP_VELOCITY_MAP[Weight.Thin]
const STAGE_HAZARD_BOUNCE := -1.5 * MAX_GRAVITY
const HEALTH_TIME = 30.
const SPRINT_SPEED = 14. * 8.
const DASH_SPEED = 20. * 8.
const EXPLODE_FALL_SPEED := 48. * 8.
const DOUBLE_JUMP_HEIGHT := 2. * 8.

@export var can_move := true
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
@export var anim_priority := 0

var cur_save_point: Node = null
var can_double_jump := false
var is_sprinting := false
var attack_rhythm: AttackRhythm = null

var facing_right := true:
	set(value):
		facing_right = value
		$Sprite2D.flip_h = !value
		$CollisionShape2D.position.x = HITBOX_OFFSET_MAP[Global.weight] * Util.sign(value)

func _ready() -> void:
	Global.echo = self
	max_health = HEALTH_TIME + Accessibility.max_hp_offset

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		if is_on_floor():
			begin_attack()

func _physics_process(delta: float) -> void:
	if can_move:
		if !$DashTimer.is_stopped():
			velocity = Vector2(DASH_SPEED * Util.sign(facing_right), 0.)
			move_and_slide()
		else:
			if Input.is_action_pressed("sprint") and Global.has_sprint:
				is_sprinting = true
			
			var desired_vel := get_desired_speed() * Input.get_axis("ui_left", "ui_right")
			var acceleration := ACCELERATION_MAP[Global.weight] / (2. if is_sprinting else 1.)
			velocity.x = move_toward(velocity.x, desired_vel, acceleration * delta)
			if desired_vel != 0.:
				facing_right = desired_vel > 0
				if is_on_wall() and is_on_floor():
					play_anim("wall_squish")
				else:
					play_anim("walk")
			else:
				is_sprinting = false
				play_anim("idle")
			
			if is_on_floor():
				$CoyoteTimeTimer.start()
				can_double_jump = Global.has_double_jump
				if is_cur_anim("jump"):
					anim_priority = 0
					play_anim("walk")
			if Input.is_action_just_pressed("jump"):
				if !$CoyoteTimeTimer.is_stopped():
					$CoyoteTimeTimer.stop()
					$JumpTimer.start(JUMP_TIME_MAP[Global.weight])
					play_anim("jump", 1)
				elif can_double_jump:
					$JumpTimer.start(DOUBLE_JUMP_HEIGHT / -JUMP_VELOCITY_MAP[Global.weight])
					can_double_jump = false
					play_anim("jump", 1)
			
			if !$JumpTimer.is_stopped():
				velocity.y = JUMP_VELOCITY_MAP[Global.weight]
				if !Input.is_action_pressed("jump") or is_on_ceiling():
					$JumpTimer.stop()
			else:
				velocity.y = move_toward(velocity.y, MAX_GRAVITY, GRAVITY * delta)
			
			move_and_slide()

func begin_attack() -> void:
	var attack_anim := get_attack_anim()
	var new_attack := play_anim(attack_anim, 10)
	if new_attack:
		var next_crit_dash := false
		if attack_rhythm != null:
			if attack_rhythm.in_rhythm():
				next_crit_dash = true
			attack_rhythm.queue_free()
		attack_rhythm = AttackRhythm.instantiate()
		attack_rhythm.crit_dash = next_crit_dash
		add_child(attack_rhythm)

func get_attack_anim() -> String:
	if attack_rhythm != null && attack_rhythm.in_rhythm():
		if attack_rhythm.crit_dash:
			return "attack_3"
		else:
			return "attack_2"
	else:
		return "attack"

func do_attack() -> void:
	var attack: Area2D = Attack.instantiate()
	var facing_sign := Util.sign(facing_right)
	attack.scale.x = facing_sign
	add_child(attack)
	attack.position = Vector2(facing_sign * 10., 0.)
	attack.get_node("Damage").connect("hit", attack_rhythm.validate)

func play_anim(anim_name: String, priority: int = 0) -> bool:
	if priority >= anim_priority:
		anim_priority = priority
		var prev_anim: String = $AnimationPlayer.current_animation
		var full_name := full_anim_name(anim_name)
		if $AnimationPlayer.has_animation(full_name):
			$AnimationPlayer.play(full_name)
			return prev_anim != full_name
		elif $AnimationPlayer.has_animation(anim_name):
			$AnimationPlayer.play(anim_name)
			return prev_anim != anim_name
	return false

func is_cur_anim(anim_name: String) -> bool:
	return $AnimationPlayer.assigned_animation == full_anim_name(anim_name)

func full_anim_name(anim_name: String) -> String:
	return "{0}_{1}".format([Global.weight as int, anim_name])

func enter_save_point(save_point: Node2D) -> void:
	$HealthTimer.stop()
	cur_save_point = save_point
	Global.last_save_path = save_point.get_path()
	Global.last_save_stage = get_tree().current_scene.scene_file_path

func exit_save_point(save_point: Node2D) -> void:
	if save_point == cur_save_point:
		$HealthTimer.start(max_health)
		cur_save_point = null

func on_hit(attacker: Node2D) -> void:
	var maybe_damage = attacker.get_node_or_null("Damage")
	if maybe_damage != null and maybe_damage.active:
		take_damage(maybe_damage.damage)
		maybe_damage.emit_hit()
		
func take_damage(amount: float) -> void:
	play_anim("hurt", 9)
	$HurtParticles.amount = amount
	$HurtParticles.restart()
	health -= amount

func stage_hurtbox_hit(_other: Node2D) -> void:
	take_damage(3.)
	velocity.y = STAGE_HAZARD_BOUNCE
	can_double_jump = Global.has_double_jump

func spawn_death_screen() -> void:
	var death_screen := DeathScreen.instantiate()
	Global.camera.add_child(death_screen)

func respawn() -> void:
	if Global.last_save_stage != get_tree().current_scene.scene_file_path:
		Global.full_respawn()
	else:
		$StageHurtbox/CollisionShape2D.set_deferred("disabled", false)
		$EnemyHurtbox/CollisionShape2D.set_deferred("disabled", false)
		$Sprite2D.show()
		global_position = get_node(Global.last_save_path).global_position
		can_move = true
		velocity = Vector2.ZERO
		play_anim("idle")

func get_desired_speed() -> float:
	if is_sprinting:
		return SPRINT_SPEED
	else:
		return SPEED_MAP[Global.weight]
