@abstract class_name Player
extends CharacterBody2D

var facing_right := true:
	set(value):
		facing_right = value
		sync_facing_right()

var is_sprinting := false
var can_double_jump := false
var on_floor := true
@export var anim_priority := 0

signal land_on_floor()
signal respawned()

@abstract func sync_facing_right() -> void
@abstract func set_anim(anim_name: String) -> bool
@abstract func anim_seek(seconds := 0., update := false) -> void
@abstract func get_desired_speed() -> float
@abstract func get_acceleration() -> float
@abstract func new_stage_jump() -> void
@abstract func on_respawn_same_stage() -> void
@abstract func should_be_player() -> bool

func _ready() -> void:
	if should_be_player():
		Global.echo = self
		Global.echo_died.connect(die)
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
		global_position = Vector2.INF

func calculate_x_movement(delta: float) -> void:
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

func process_on_floor() -> void:
	if !on_floor:
		land_on_floor.emit()
	on_floor = true

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

func exit_save_point(_save_point: Node2D) -> void:
	pass

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
	velocity.y = Echo.STAGE_HAZARD_BOUNCE

func spawn_death_screen() -> void:
	var death_screen := Echo.DeathScreen.instantiate()
	Global.camera.add_child(death_screen)

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
