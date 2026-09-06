extends CharacterBody2D

const Explosion := preload("res://objects/particle/explosion.tscn")

const WALK_SPEED := 4. * 8.
const ATTACK_SPEED := 9. * 8.
const HEAD_X_VEL := 7. * 8.
const HEAD_Y_VEL := -20. * 8.

@export var facing_right = false:
	set(value):
		facing_right = value
		if is_node_ready():
			sync_facing_right()

@onready var player_raycast: RayCast2D = $Flip/RayCast2D

func _physics_process(delta: float) -> void:
	if $EnemyManager.health <= 0 and $Head.velocity != Vector2.ZERO:
		$Head.velocity.y += Echo.GRAVITY * delta
		$Head.move_and_slide()
		if $Head.is_on_floor():
			$AnimationPlayer.stop()
			$Head.velocity = Vector2.ZERO
	else:
		velocity.y += Echo.GRAVITY * delta
		if $AnimationPlayer.current_animation == "walk":
			if is_on_wall() or Util.off_edge_in_direction(facing_right, $Left, $Right):
				self.facing_right = !facing_right
			velocity.x = WALK_SPEED * Util.sign(facing_right)
			
			if player_raycast.is_colliding() and player_raycast.get_collider() is Player:
				$AnimationPlayer.play("prepare_attack")

		elif $AnimationPlayer.current_animation == "attack":
			if !$Spin.playing:
				$Spin.play()
			velocity.x = ATTACK_SPEED * Util.sign(facing_right)
			if is_on_wall() or Util.off_edge_in_direction(facing_right, $Left, $Right):
				$AnimationPlayer.play("stop_attack")

		else:
			velocity.x = 0.
	
	move_and_slide()


func reset_head() -> void:
	$Head.position = Vector2(0., -10.)

func die() -> void:
	velocity = Vector2.ZERO
	var explosion: Node2D = Explosion.instantiate()
	add_child(explosion)
	explosion.position.y = -8
	$AnimationPlayer.play("die")
	$Head.process_mode = Node.PROCESS_MODE_INHERIT
	$Head.show()
	$Head.velocity = Vector2(HEAD_X_VEL * -Util.sign(Global.echo_is_right(self)), HEAD_Y_VEL)


func sync_facing_right() -> void:
	$Flip.scale.x = Util.sign(!facing_right)
