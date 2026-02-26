extends CharacterBody2D

const SPEED := 64.
const FAT_SPEED := 48.
const GRAVITY := Echo.GRAVITY / 2.
const MAX_WEIGHT := 5


var is_angry := false:
	set(value):
		is_angry = value
		$Damage.active = should_attack()
var is_hungry := false:
	set(value):
		is_hungry = value
		$Damage.active = should_attack()
var path: Path2D
var follower: PathFollow2D

var weight := 0:
	set(value):
		weight = clampi(value, 0, MAX_WEIGHT)
		if is_node_ready():
			sync_weight()
var facing_right := false:
	set(value):
		facing_right = value
		if is_node_ready():
			sync_facing_right()

signal ate()

func _ready() -> void:
	path = get_parent()
	
	create_follower.call_deferred()

func create_follower() -> void:
	follower = PathFollow2D.new()
	follower.loop = true
	path.add_child(follower)
	var nearest_offset := path.curve.get_closest_offset(position)
	follower.progress = nearest_offset
	follower.force_update_transform()
	global_position = follower.global_position

func _physics_process(delta: float) -> void:
	var speed := get_speed()
	if should_be_immobile():
		velocity.x = move_toward(velocity.x, 0., GRAVITY * delta)
		velocity.y += GRAVITY * delta
		move_and_slide()
	elif should_attack():
		var dist_to_echo := Global.echo.global_position - global_position
		if abs(dist_to_echo.x) > 0.1:
			self.facing_right = dist_to_echo.x > 0
		velocity = dist_to_echo.normalized() * speed
		move_and_slide()
	elif $EnemyManager.health <= 0:
		velocity.y += GRAVITY * delta
		move_and_slide()
	else:
		if follower != null:
			follower.progress += speed * delta
			var dist_to_follower := follower.global_position - global_position
			if abs(dist_to_follower.x) > 0.1:
				self.facing_right = dist_to_follower.x > 0
			if dist_to_follower.length_squared() > speed * speed * delta * delta:
				velocity = dist_to_follower.normalized() * speed
				move_and_slide()
			else:
				move_and_collide(dist_to_follower)

func get_speed() -> float:
	if weight >= 1:
		return FAT_SPEED
	else:
		return SPEED

func sync_facing_right() -> void:
	$Sprite2D.flip_h = facing_right

func sync_weight() -> void:
	if weight == 0:
		$AnimationPlayer.play("idle_0")
	else:
		$AnimationPlayer.play("gain_{0}".format([weight]))
	if should_be_immobile():
		$Damage.damage = 0
		is_angry = false
	else:
		$Damage.damage = 3

func after_hit() -> void:
	if is_hungry:
		ate.emit()
		weight += 1
		$EnemyManager.health += 2 * weight
		self.is_hungry = false

func should_attack() -> bool:
	return $EnemyManager.health > 0 and weight < MAX_WEIGHT and (is_angry or is_hungry)

func should_be_immobile() -> bool:
	return weight > 1

func on_damaged() -> void:
	if !should_be_immobile():
		self.is_angry = true

func reload_alive() -> void:
	show()
	if follower != null:
		follower.queue_free()
	create_follower()
	self.is_angry = false
	self.weight = 0
	z_index = 0

func die() -> void:
	self.is_hungry = false
	self.is_angry = false
	$AnimationPlayer.play("die_{0}".format([weight]))
	velocity.x = get_speed() * Util.sign(global_position.x > Global.echo.global_position.x)
	velocity.y = -32.
	z_index = -10

func become_hungry() -> void:
	self.is_hungry = true

func stop_hungry() -> void:
	self.is_hungry = false
