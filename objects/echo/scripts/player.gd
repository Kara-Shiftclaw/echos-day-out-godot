@abstract class_name Player
extends CharacterBody2D

var facing_right := true:
	set(value):
		facing_right = value
		sync_facing_right()

var is_sprinting := false
@export var anim_priority := 0

@warning_ignore("unused_signal") signal land_on_floor()
@warning_ignore("unused_signal") signal respawned()

@abstract func sync_facing_right() -> void
@abstract func set_anim(anim_name: String) -> bool
@abstract func anim_seek(seconds := 0., update := false) -> void
@abstract func get_desired_speed() -> float
@abstract func get_acceleration() -> float
@abstract func new_stage_jump() -> void

func calculate_x_movement(delta: float) -> void:
	if Input.is_action_pressed("sprint") and Global.has_sprint:
		is_sprinting = true
	
	var desired_vel := get_desired_speed() * Input.get_axis("ui_left", "ui_right")
	var acceleration := get_acceleration() / (2. if is_sprinting else 1.)
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

func play_anim(anim_name: String, priority: int = 0) -> bool:
	if priority >= anim_priority:
		anim_priority = priority
		return set_anim(anim_name)
	else:
		return false

func die():
	Global.music_player.stop()
	play_anim("die", 999)

func enter_save_point(save_point: Node2D) -> void:
	Global.restore_health()
	Global.last_save_path = save_point.get_path()
	Global.last_save_stage = get_tree().current_scene.scene_file_path

func take_damage(amount: float) -> void:
	play_anim("hurt", 9)
	if amount > 0:
		$HurtParticles.amount = amount
		$HurtParticles.restart()
		Global.health -= amount

func stage_hurtbox_hit(_other: Node2D) -> void:
	take_damage(3.)
	velocity.y = Echo.STAGE_HAZARD_BOUNCE

func respawn() -> void:
	if Global.last_save_stage != get_tree().current_scene.scene_file_path:
		Global.full_respawn()
	else:
		$StageHurtbox/CollisionShape2D.set_deferred("disabled", false)
		$EnemyHurtbox/CollisionShape2D.set_deferred("disabled", false)
		$Sprite2D.show()
		global_position = get_node(Global.last_save_path).global_position
		on_respawn_same_stage()
		velocity = Vector2.ZERO
		play_anim("idle")
	Global.music_player.play()
	respawned.emit()

func on_respawn_same_stage() -> void:
	pass
