class_name Echo
extends Player

const Attack := preload("res://objects/echo/attack.tscn")
const Fireball := preload("res://objects/echo/fireball.tscn")
const Crush := preload("res://objects/echo/crush.tscn")
const DeathScreen := preload("res://objects/echo/particle/death_screen.tscn")
const SmolEcho := preload("res://objects/echo/echo_blob.tscn")
const Weight := Global.Weight

const SPEED_MAP: Dictionary[Weight, float] = {
	Weight.Thin: 10. * 8.,
	Weight.Fat: 10. * 8.,
	Weight.Obese: 8. * 8.,
	Weight.MorObese: 6.5 * 8.,
	Weight.Blob: 3. * 8.,
}
const ACCELERATION_MAP: Dictionary[Weight, float] = {
	Weight.Thin: 200. * 8.,
	Weight.Fat: 200. * 8.,
	Weight.Obese: 185. * 8.,
	Weight.MorObese: 160. * 8.,
	Weight.Blob: 140. * 8.,
}
const JUMP_VELOCITY_MAP: Dictionary[Weight, float] = {
	Weight.Thin: -16. * 8.,
	Weight.Fat: -16. * 8.,
	Weight.Obese: -14. * 8.,
	Weight.MorObese: -11. * 8.,
	Weight.Blob: -6. * 8.,
}
const SPRINT_JUMP_VELOCITY := -2. * 8.
const GRAVITY = 120. * 8.
const JUMP_TIME_MAP: Dictionary[Weight, float] = {
	Weight.Thin: 3.5 * 8. / -JUMP_VELOCITY_MAP[Weight.Thin],
	Weight.Fat: 3.5 * 8. / -JUMP_VELOCITY_MAP[Weight.Fat],
	Weight.Obese: 3. * 8. / -JUMP_VELOCITY_MAP[Weight.Obese],
	Weight.MorObese: 2.6 * 8. / -JUMP_VELOCITY_MAP[Weight.MorObese],
	Weight.Blob: 2. * 8. / -JUMP_VELOCITY_MAP[Weight.Blob],
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

const MAX_GRAVITY := 18. * 8.
const STAGE_HAZARD_BOUNCE := -20. * 8.
const SPRINT_SPEED = 14. * 8.
const DASH_SPEED = 20. * 8.
const EXPLODE_FALL_SPEED := 48. * 8.
const DOUBLE_JUMP_HEIGHT := 2. * 8.
const NEW_STAGE_JUMP_HEIGHT := 3.5 * 8.
const CRUSH_DOWN_VELOCITY := 1.5 * MAX_GRAVITY
const NOCLIP_SPEED := 18. * 8.

const SWORD_BLADE_FLAG := "has_sword_blade"
const SWORD_HILT_FLAG := "has_sword_hilt"

@export var can_move := true

var cur_save_point: Node = null
var can_fireball := false
var can_crush := false
var is_crushing := false
var jump_locked := false
var attack_rhythm: AttackRhythm = null

func sync_facing_right() -> void:
	$Sprite2D.flip_h = !facing_right
	$CollisionShape2D.position.x = HITBOX_OFFSET_MAP[Global.weight] * Util.sign(facing_right)

func should_be_player() -> bool:
	return !Global.is_smol


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack") and !in_attack_anim():
		if is_on_floor():
			begin_attack()

func _physics_process(delta: float) -> void:
	if noclipping:
		process_noclip(delta)
		return
	
	if can_move:
		if !$DashTimer.is_stopped():
			velocity = Vector2(DASH_SPEED * Util.sign(facing_right), 0.)
			move_and_slide()
		else:
			if Input.is_action_pressed("sprint") and Global.has_sprint:
				is_sprinting = true
			
			calculate_x_movement(delta)
			
			if is_on_floor():
				process_on_floor()
				
				if is_crushing:
					is_crushing = false
					velocity = Vector2(0., STAGE_HAZARD_BOUNCE)
					anim_priority = 0
					play_anim("jump", 1)
					take_damage(3.)
					$DeathExp2.play()
					
					var crush: Node2D = Crush.instantiate()
					get_parent().add_child(crush)
					crush.global_position = global_position + Vector2(0., 9.)
				else:
					can_crush = Global.has_crush
			
				$CoyoteTimeTimer.start()
				can_double_jump = Global.has_double_jump
				is_double_jumping = false
				can_fireball = Global.has_fireball
				if is_cur_anim("jump"):
					anim_priority = 0
					play_anim("walk")
			else:
				on_floor = false
				if Input.is_action_just_pressed("attack") and can_fireball:
					play_anim("fireball", 1)
					can_fireball = false
					
					var fireball: Node2D = Fireball.instantiate()
					fireball.moving_right = facing_right
					get_parent().add_child(fireball)
					fireball.global_position = global_position + Vector2(4. * Util.sign(facing_right), 0.)
				
				if Input.is_action_just_pressed("ui_down") and can_crush:
					velocity.y = CRUSH_DOWN_VELOCITY
					$JumpTimer.stop()
					play_anim("crush", 2)
					is_crushing = true
			
			if Input.is_action_just_pressed("jump"):
				if !$CoyoteTimeTimer.is_stopped():
					$CoyoteTimeTimer.stop()
					$JumpTimer.start(JUMP_TIME_MAP[Global.weight])
					play_anim("jump", 1)
				elif can_double_jump:
					$JumpTimer.start(DOUBLE_JUMP_HEIGHT / -JUMP_VELOCITY_MAP[Global.weight])
					can_double_jump = false
					is_double_jumping = true
					if !play_anim("double_jump", 1):
						play_anim("jump", 1)
			
			if !$JumpTimer.is_stopped():
				velocity.y = JUMP_VELOCITY_MAP[Global.weight]
				if is_sprinting:
					velocity.y += SPRINT_JUMP_VELOCITY
				if is_double_jumping and in_airstream:
					velocity.y *= 2.
				if !(Input.is_action_pressed("jump") or jump_locked) or is_on_ceiling():
					$JumpTimer.stop()
			elif !is_crushing:
				velocity.y = move_toward(velocity.y, MAX_GRAVITY, GRAVITY * delta)
				jump_locked = false
			
			if move_and_slide() and is_on_wall():
				velocity.x = 0.

func new_stage_jump():
	$JumpTimer.start(NEW_STAGE_JUMP_HEIGHT / -JUMP_VELOCITY_MAP[Global.weight])
	jump_locked = true
	play_anim("jump", 1)

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
			$CritParticles.direction.x = -Util.sign(facing_right)
			return "attack_3"
		else:
			$CritParticles.direction.x = Util.sign(facing_right)
			return "attack_2"
	else:
		return "attack"

func do_attack() -> void:
	var attack: Area2D = Attack.instantiate()
	var facing_sign := Util.sign(facing_right)
	attack.scale.x = facing_sign
	add_child(attack)
	var offset := 15. if Global.flags.has(SWORD_HILT_FLAG) else 10.
	attack.position = Vector2(facing_sign * offset, 0.)
	
	var damage: Damage = attack.get_node("Damage")
	damage.hit.connect(attack_rhythm.validate)
	if Global.flags.has(SWORD_BLADE_FLAG):
		damage.damage = 6

func in_attack_anim() -> bool:
	return is_cur_anim("attack") or is_cur_anim("attack_2") or is_cur_anim("attack_3")

func set_anim(anim_name: String) -> bool:
	$Sprite2D.set_instance_shader_parameter("strength", 0)
	var prev_anim: String = $AnimationPlayer.current_animation
	var full_name := full_anim_name(anim_name)
	if $AnimationPlayer.has_animation(full_name):
		$AnimationPlayer.play(full_name)
		return prev_anim != full_name
	elif $AnimationPlayer.has_animation(anim_name):
		$AnimationPlayer.play(anim_name)
		return prev_anim != anim_name
	else:
		return false

func anim_seek(seconds := 0., update := false) -> void:
	$AnimationPlayer.seek(seconds, update)

func is_cur_anim(anim_name: String) -> bool:
	var player_anim: String = $AnimationPlayer.assigned_animation
	return player_anim == full_anim_name(anim_name) or player_anim == anim_name

func full_anim_name(anim_name: String) -> String:
	return "{0}_{1}".format([Global.weight as int, anim_name])

func enter_save_point(save_point: Node2D) -> void:
	cur_save_point = save_point
	Global.restore_health()
	Global.last_save_path = save_point.get_path()
	Global.last_save_stage = get_tree().current_scene.scene_file_path

func exit_save_point(save_point: Node2D) -> void:
	if save_point == cur_save_point:
		cur_save_point = null

func stage_hurtbox_hit(other: Node2D) -> void:
	super.stage_hurtbox_hit(other)
	can_double_jump = Global.has_double_jump or can_double_jump
	can_fireball = Global.has_fireball
	can_crush = Global.has_crush
	is_crushing = false

func on_respawn_same_stage() -> void:
	can_move = true
	is_crushing = false

func get_desired_speed() -> float:
	if is_sprinting:
		return SPRINT_SPEED
	else:
		return SPEED_MAP[Global.weight]

func get_acceleration() -> float:
	return ACCELERATION_MAP[Global.weight]
