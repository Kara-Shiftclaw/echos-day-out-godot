extends CharacterBody2D

const IMPULSE := -256.
const HIT_IMPULSE := 96.

func _ready() -> void:
	velocity.y = IMPULSE

func _physics_process(delta: float) -> void:
	var old_velocity := velocity
	velocity.y += Echo.GRAVITY * delta
	
	if is_on_ceiling():
		velocity.y = -old_velocity.y
	if is_on_wall():
		velocity.x = -old_velocity.x
	if is_on_floor() and $AnimationPlayer.current_animation == "spin":
		velocity = Vector2.ZERO
		$AnimationPlayer.play("land")
	move_and_slide()

func on_hit(_other) -> void:
	if $AnimationPlayer.current_animation == "spin" and $DisableHitTimer.is_stopped():
		var vel_dir := -Util.sign(Global.echo_is_right(self))
		velocity.x += vel_dir * HIT_IMPULSE
