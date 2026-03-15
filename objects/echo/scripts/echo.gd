class_name Echo
extends Player

const Attack := preload("res://objects/echo/attack.tscn")
const Fireball := preload("res://objects/echo/fireball.tscn")
const Crush := preload("res://objects/echo/crush.tscn")
const DeathScreen := preload("res://objects/echo/particle/death_screen.tscn")
const Weight := Global.Weight

const SPEED_MAP: Dictionary[Weight, float] = {
	Weight.Thin: 10. * 8.,
	Weight.Fat: 10. * 8.,
	Weight.Obese: 8. * 8.,
	Weight.MorObese: 6.5 * 8.,
	Weight.Blob: 4. * 8.,
}
const ACCELERATION_MAP: Dictionary[Weight, float] = {
	Weight.Thin: 200. * 8.,
	Weight.Fat: 200. * 8.,
	Weight.Obese: 185. * 8.,
	Weight.MorObese: 160. * 8.,
	Weight.Blob: 130. * 8.,
}
const JUMP_VELOCITY_MAP: Dictionary[Weight, float] = {
	Weight.Thin: -16. * 8.,
	Weight.Fat: -16. * 8.,
	Weight.Obese: -14. * 8.,
	Weight.MorObese: -11. * 8.,
	Weight.Blob: -7. * 8.,
}
const GRAVITY = 120. * 8.
const JUMP_TIME_MAP: Dictionary[Weight, float] = {
	Weight.Thin: 3.5 * 8. / -JUMP_VELOCITY_MAP[Weight.Thin],
	Weight.Fat: 3.5 * 8. / -JUMP_VELOCITY_MAP[Weight.Fat],
	Weight.Obese: 3. * 8. / -JUMP_VELOCITY_MAP[Weight.Obese],
	Weight.MorObese: 2.5 * 8. / -JUMP_VELOCITY_MAP[Weight.MorObese],
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
const NEW_STAGE_JUMP_HEIGHT := 4. * 8.
const CRUSH_DOWN_VELOCITY := 1.5 * MAX_GRAVITY

const SWORD_BLADE_FLAG := "has_sword_blade"
const SWORD_HILT_FLAG := "has_sword_hilt"

@export var can_move := true

var cur_save_point: Node = null
var can_double_jump := false
var can_fireball := false
var can_crush := false
var is_crushing := false
var attack_rhythm: AttackRhythm = null
var on_floor := true

func sync_facing_right() -> void:
	$Sprite2D.flip_h = !facing_right
	$CollisionShape2D.position.x = HITBOX_OFFSET_MAP[Global.weight] * Util.sign(facing_right)


func _ready() -> void:
	Global.echo = self
	Global.echo_died.connect(die)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack") and !in_attack_anim():
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
					if is_sprinting:
						play_anim("sprint")
					else:
						play_anim("walk")
			else:
				is_sprinting = false
				play_anim("idle")
			
			if is_on_floor():
				if !on_floor:
					land_on_floor.emit()
				on_floor = true
				
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
					if !play_anim("double_jump", 1):
						play_anim("jump", 1)
			
			if !$JumpTimer.is_stopped():
				velocity.y = JUMP_VELOCITY_MAP[Global.weight]
				if !Input.is_action_pressed("jump") or is_on_ceiling():
					$JumpTimer.stop()
			elif !is_crushing:
				velocity.y = move_toward(velocity.y, MAX_GRAVITY, GRAVITY * delta)
			
			move_and_slide()

func new_stage_jump():
	$JumpTimer.start(NEW_STAGE_JUMP_HEIGHT / -JUMP_VELOCITY_MAP[Global.weight])
	play_anim("jump", 1)

func die():
	Global.music_player.stop()
	play_anim("die", 999)

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

func on_hit(attacker: Node2D) -> void:
	var maybe_damage = attacker.get_node_or_null("Damage")
	if maybe_damage != null and maybe_damage.active:
		take_damage(maybe_damage.damage)
		maybe_damage.emit_hit()
		
func take_damage(amount: float) -> void:
	play_anim("hurt", 9)
	if amount > 0:
		$HurtParticles.amount = amount
		$HurtParticles.restart()
		Global.health -= amount

func stage_hurtbox_hit(_other: Node2D) -> void:
	take_damage(3.)
	velocity.y = STAGE_HAZARD_BOUNCE
	can_double_jump = Global.has_double_jump
	can_fireball = Global.has_fireball
	can_crush = Global.has_crush
	is_crushing = false

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
		is_crushing = false
		velocity = Vector2.ZERO
		play_anim("idle")
	Global.music_player.play()
	respawned.emit()

func get_desired_speed() -> float:
	if is_sprinting:
		return SPRINT_SPEED
	else:
		return SPEED_MAP[Global.weight]
