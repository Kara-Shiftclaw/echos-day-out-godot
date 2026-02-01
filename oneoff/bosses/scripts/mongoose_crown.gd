extends CharacterBody2D

const SPEED := 24. * 8.

@export var moving_right := true
var already_hit_wall := false
var sprite_position: Vector2:
	get:
		return $Sprite2D.global_position

func _ready() -> void:
	velocity = Vector2.RIGHT * SPEED * Util.sign(moving_right)
	$AnimationPlayer.play("spin_right" if moving_right else "spin_left")

func _physics_process(delta: float) -> void:
	var col := move_and_collide(velocity * delta)
	if col != null and !already_hit_wall:
		$AnimationPlayer.play("bounce_right" if moving_right else "bounce_left")
		velocity = Vector2.ZERO
