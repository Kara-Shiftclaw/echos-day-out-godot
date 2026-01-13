extends CharacterBody2D

@export var exp_velocity: Vector2:
	get:
		return velocity
	set(value):
		velocity = value

func _physics_process(_delta: float) -> void:
	move_and_slide()

	if is_on_ceiling() and $AnimationPlayer.current_animation == "climb":
		$AnimationPlayer.play("idle")
