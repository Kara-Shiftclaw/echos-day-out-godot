extends Area2D

enum Attacks {
	SingleSwipe,
	DoubleSwipe,
	JumpDig,
	DoubleJumpDig,
	DoubleJumpSlash,
	DoubleJumpToMid,
	MidThrowBricks,
	MidJumpSlash,
	DoubleJumpToTop,
	TopDropBricks,
	DigUnderPlayer,
	DigSpike,
	DigToMid,
	DigToTop,
	Olhm,
	TopJumpSlash,
	LowToOlhm,
	NoOp,
}
enum State {
	Low,
	Mid,
	Top,
	Dig,
}

const DustCloud := preload("res://oneoff/bosses/sonia/dust_cloud.tscn")
const SpikeRock := preload("res://oneoff/bosses/sonia/spike_rock.tscn")
const Brick := preload("res://oneoff/bosses/sonia/brick.tscn")

const OLHM_HP_PERCENTAGE := 50.0
const JUMP_UP_PERCENTAGE := 80.0
const WIDTH := 16.0
const RUN_SPEED := 120.
const NOT_IMPLEMENTED_ATTACKS := [
	Attacks.TopJumpSlash,
	Attacks.LowToOlhm,
]

@export var door_reference_rect: ReferenceRect
@export var low_reference_rect: ReferenceRect
@export var left_reference_rect: ReferenceRect
@export var right_reference_rect: ReferenceRect
@export var top_reference_rect: ReferenceRect
@export var state := State.Top
@export var x_speed := 0.
@export var facing_right := true:
	set(value):
		facing_right = value
		if is_node_ready():
			sync_facing_right()
@export var knock_into_olhm := false

var last_attack := Attacks.JumpDig

signal start_olhm()
signal olhm_early_release()

func _physics_process(delta: float) -> void:
	var reference_rect := get_reference_rect()
	if reference_rect != null:
		var x_motion := x_speed * delta * Util.sign(facing_right)
		position.x = clampf(position.x + x_motion, reference_rect.offset_left, reference_rect.offset_right)

func start() -> void:
	init_attack(Attacks.JumpDig)

func decision_point() -> void:
	var selector := get_selector()
	var exclusions := get_exclusions()
	var next_attack: Attacks = Attacks.get(selector.select_attack(exclusions), Attacks.NoOp)
	init_attack(next_attack)

func update_state_after_last_attack() -> void:
	pass

func get_selector() -> RandomAttackSelector:
	match state:
		State.Low:
			return $LowSelector
		State.Mid:
			return $MidSelector
		State.Top:
			return $TopSelector
		State.Dig:
			return $DigSelector
	return null

func get_reference_rect() -> ReferenceRect:
	match state:
		State.Low:
			return low_reference_rect
		State.Mid:
			if position.x > 0.:
				return right_reference_rect
			else:
				return left_reference_rect
		State.Top:
			return top_reference_rect
	return null

func get_exclusions() -> Array[String]:
	var exclusions: Array[String] = [atk_str(last_attack)]
		
	if last_attack == Attacks.DoubleSwipe:
		exclusions.append(atk_str(Attacks.SingleSwipe))
	if last_attack == Attacks.SingleSwipe:
		exclusions.append(atk_str(Attacks.DoubleSwipe))
	
	var hp_percentage := calculate_hp_percentage()
	if hp_percentage > JUMP_UP_PERCENTAGE:
		exclusions.append_array([
			atk_str(Attacks.DoubleJumpToMid), 
			atk_str(Attacks.DoubleJumpToTop), 
			atk_str(Attacks.DigToMid), 
			atk_str(Attacks.DigToTop)])
	if hp_percentage > OLHM_HP_PERCENTAGE:
		exclusions.append(atk_str(Attacks.Olhm))
	
	var door_rect := door_reference_rect.get_global_rect()
	var echo_x := Global.echo.global_position.x
	if echo_x > door_rect.position.x and echo_x < door_rect.end.x:
		exclusions.append(atk_str(Attacks.DigUnderPlayer))
		
	if state == State.Mid and Global.echo.global_position.y > \
			right_reference_rect.get_global_rect().end.y + 8:
		exclusions.append(atk_str(Attacks.SingleSwipe))
	if last_attack == Attacks.DoubleJumpToMid or last_attack == Attacks.DigToMid:
		exclusions.append(atk_str(Attacks.JumpDig))
		
	if state == State.Top and Global.echo.global_position.y > \
			top_reference_rect.get_global_rect().end.y + 8:
		exclusions.append(atk_str(Attacks.DoubleSwipe))
	if last_attack == Attacks.DoubleJumpToTop or last_attack == Attacks.DigToTop:
		exclusions.append(atk_str(Attacks.JumpDig))
	
	for attack in NOT_IMPLEMENTED_ATTACKS:
		exclusions.append(atk_str(attack))
	
	return exclusions

func init_attack(next_attack: Attacks) -> void:
	match next_attack:
		Attacks.SingleSwipe:
			facing_right = Global.echo_is_right(self)
			$AnimationPlayer.play("single_swipe")
		Attacks.DoubleSwipe:
			facing_right = Global.echo_is_right(self)
			$AnimationPlayer.play("double_swipe")
		Attacks.JumpDig:
			match state:
				State.Low:
					facing_right = Global.echo_is_right(self)
					$AnimationPlayer.play("low_jump_dig")
				State.Mid:
					self.facing_right = position.x < 0
					$AnimationPlayer.play("mid_jump_dig")
				State.Top:
					$AnimationPlayer.play("top_jump_dig")
		Attacks.DoubleJumpDig:
			facing_right = Global.echo_is_right(self)
			$AnimationPlayer.play("double_jump_dig")
		Attacks.DoubleJumpSlash:
			facing_right = Global.echo_is_right(self)
			$AnimationPlayer.play("double_jump_slash")
		Attacks.DoubleJumpToMid:
			var nearest_jump_point := (right_reference_rect.offset_left - WIDTH) \
					* signf(position.x)
			self.facing_right = nearest_jump_point > 0
			x_speed = RUN_SPEED
			if abs(position.x) < abs(nearest_jump_point):
				var run_timer := get_tree().create_timer(abs(nearest_jump_point) / RUN_SPEED)
				$AnimationPlayer.play("run_toward_mid")
				run_timer.timeout.connect(func():
					position.y = right_reference_rect.offset_bottom
					$AnimationPlayer.play("double_jump_to_mid")
					$AnimationPlayer.seek(0., true)
				)
			else:
				position.y = right_reference_rect.offset_bottom
				$AnimationPlayer.play("double_jump_to_mid")
				$AnimationPlayer.seek(0., true)
		Attacks.MidThrowBricks:
			self.facing_right = position.x < 0.
			$AnimationPlayer.play("mid_throw_bricks")
		Attacks.MidJumpSlash:
			position.y = low_reference_rect.offset_bottom
			self.facing_right = position.x < 0
			$AnimationPlayer.play("mid_jump_slash")
			$AnimationPlayer.seek(0., true)
		Attacks.DoubleJumpToTop:
			self.facing_right = position.x < 0
			position.y = top_reference_rect.offset_bottom
			$AnimationPlayer.play("double_jump_to_top")
			$AnimationPlayer.seek(0., true)
		Attacks.TopDropBricks:
			self.facing_right = position.x < 0
			var run_dest := top_reference_rect.offset_right * -signf(position.x)
			var run_dur := absf(run_dest - position.x) / RUN_SPEED
			
			var run_timer := get_tree().create_timer(run_dur)
			run_timer.timeout.connect(func():
				x_speed = 0.
				decision_point()
			)
			
			x_speed = RUN_SPEED
			$AnimationPlayer.play("top_drop_bricks")
		Attacks.DigUnderPlayer:
			global_position.x = Global.echo.global_position.x
			position.y = low_reference_rect.offset_bottom
			$AnimationPlayer.play("dig_under_player")
		Attacks.DigSpike:
			var low_rect := low_reference_rect.get_rect()
			var door_rect := door_reference_rect.get_rect()
			var spawn_x := randf_range(low_rect.position.x, low_rect.end.x)
			while spawn_x > door_rect.position.x and spawn_x < door_rect.end.x:
				spawn_x = randf_range(low_rect.position.x, low_rect.end.x)
			
			position = Vector2(spawn_x, low_rect.end.y)
			self.facing_right = Global.echo_is_right(self)
			$AnimationPlayer.play("dig_spike")
		Attacks.DigToMid:
			var right_side := randf() > 0.5
			if right_side:
				facing_right = false
				position = Vector2(right_reference_rect.offset_left, right_reference_rect.offset_bottom)
				$AnimationPlayer.play("dig_to_right")
			else:
				facing_right = true
				position = Vector2(left_reference_rect.offset_right, left_reference_rect.offset_bottom)
				$AnimationPlayer.play("dig_to_left")
		Attacks.DigToTop:
			var x_spawn := randf_range(top_reference_rect.offset_left, top_reference_rect.offset_right)
			position = Vector2(x_spawn, top_reference_rect.offset_bottom)
			$AnimationPlayer.play("dig_to_top")
		Attacks.Olhm:
			$AnimationPlayer.play("olhm")
	last_attack = next_attack

func calculate_hp_percentage() -> float:
	return $EnemyManager.health as float / $EnemyManager.max_health as float * 100.

func on_hit() -> void:
	if knock_into_olhm and $AnimationPlayer.current_animation == "olhm":
		if state == State.Top:
			$AnimationPlayer.play("top_olhm_knockdown")
			$Sprite2D.position.y = -80
		else:
			$AnimationPlayer.play("mid_olhm_knockdown")
			$Sprite2D.position.y = -40
		position.y = low_reference_rect.offset_bottom
	knock_into_olhm = false

func spawn_dust_cloud(cloud_rotation_degrees: float, cloud_offset: Vector2, cloud_flip_h: bool) -> void:
	var dust_cloud: Node2D = DustCloud.instantiate()
	get_parent().add_child(dust_cloud)
	dust_cloud.global_position = global_position + cloud_offset
	dust_cloud.rotation_degrees = cloud_rotation_degrees
	dust_cloud.scale.x = Util.sign(!cloud_flip_h)

func double_spawn_dust_cloud(cloud_rotation_degrees: float, cloud_offset: Vector2) -> void:
	spawn_dust_cloud(cloud_rotation_degrees, cloud_offset, true)
	spawn_dust_cloud(cloud_rotation_degrees, cloud_offset, false)

func jump_towards_player(duration_to_ground: float, max_speed: float) -> void:
	var dist_to_echo := absf(Global.echo.global_position.x - global_position.x)
	x_speed = clampf(dist_to_echo * duration_to_ground, -max_speed, max_speed)

func spawn_spike_rock() -> void:
	var spike_rock: Node2D = SpikeRock.instantiate()
	spike_rock.moving_right = facing_right
	get_parent().add_child(spike_rock)
	spike_rock.global_position = global_position

func spawn_brick() -> void:
	var brick: Node2D = Brick.instantiate()
	get_parent().add_child(brick)
	brick.global_position = global_position + Vector2(-8. * Util.sign(facing_right), -16.)

func spawn_drop_brick() -> void:
	var brick: Node2D = Brick.instantiate()
	get_parent().add_child(brick)
	brick.global_position = global_position + Vector2(0., 6.)
	brick.drop()

func emit_start_olhm() -> void:
	start_olhm.emit()

func emit_olhm_early_release() -> void:
	olhm_early_release.emit()

func sync_facing_right() -> void:
	var flip_sign := Util.sign(facing_right)
	$Sprite2D.flip_h = !facing_right
	$DamageBox.scale.x = flip_sign

func atk_str(attack: Attacks) -> String:
	return Attacks.keys()[attack]
