extends CharacterBody2D

const Honeyball := preload("res://objects/projectile/honeyball.tscn")

const ECHO_OFFSET_LEFT := Vector2(-24., -24.)
const ECHO_OFFSET_RIGHT := Vector2(24., -24.)
const MAX_SPEED := 72.
const MAX_SPEED_SQ := MAX_SPEED * MAX_SPEED
const FLY_AWAY_SPEED := 128.
const ACCELERATION := 384.
const RANGE_TO_FIRE := 16.
const RANGE_TO_FIRE_SQ := RANGE_TO_FIRE * RANGE_TO_FIRE

var facing_right := false:
	set(value):
		facing_right = value
		if is_node_ready():
			sync_facing_right()
var drop_cannon: CharacterBody2D

func _ready() -> void:
	drop_cannon = $DropCannon
	sync_facing_right()

func _physics_process(delta: float) -> void:
	if $EnemyManager.health > 0:
		var offset_dest := get_offset_dest()
		var distance_to_offset = offset_dest - global_position
		velocity += distance_to_offset.normalized() * ACCELERATION * delta
		if velocity.length_squared() > MAX_SPEED_SQ:
			velocity = velocity.normalized() * MAX_SPEED
		
		move_and_slide()
		self.facing_right = Global.echo.global_position.x > global_position.x
		if global_position.distance_squared_to(offset_dest) < RANGE_TO_FIRE_SQ \
				and $PreshootTimer.is_stopped() and $ShootCooldownTimer.is_stopped():
			$PreshootTimer.start()
	else:
		if $AnimationPlayer.current_animation == "fly_away":
			velocity = Vector2(Util.sign(facing_right), -1).normalized() * FLY_AWAY_SPEED
			move_and_slide()
		
		if drop_cannon.get_node("Sprite2D").visible:
			drop_cannon.velocity.y += Echo.GRAVITY * delta
			var drop_cannon_cols := drop_cannon.move_and_collide(drop_cannon.velocity * delta)
			if drop_cannon_cols != null:
				drop_cannon.get_node("Sprite2D").hide()
				drop_cannon.get_node("CPUParticles2D").emitting = true

func shoot() -> void:
	var honeyball: Node2D = Honeyball.instantiate()
	honeyball.moving_right = facing_right
	get_parent().add_child(honeyball)
	honeyball.global_position = global_position
	$ShootCooldownTimer.start()

func get_offset_dest() -> Vector2:
	var echo_pos := Global.echo.global_position
	var left_offset := echo_pos + ECHO_OFFSET_LEFT
	var right_offset := echo_pos + ECHO_OFFSET_RIGHT
	
	if global_position.distance_squared_to(left_offset) > global_position.distance_squared_to(right_offset):
		return right_offset
	else:
		return left_offset

func sync_facing_right() -> void:
	$Sprite2D.flip_h = facing_right
	$Sprite2D.position.x = -Util.sign(facing_right)

func die() -> void:
	drop_cannon.call_deferred("reparent", get_parent())
	drop_cannon.get_node("Sprite2D").visible = true
	$AnimationPlayer.play("drop")

func reload_alive() -> void:
	$PreshootTimer.stop()
	$ShootCooldownTimer.stop()
	if drop_cannon.get_parent() != self:
		drop_cannon.reparent(self)
	$AnimationPlayer.play("idle")
	show()
