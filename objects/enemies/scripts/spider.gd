extends CharacterBody2D

@export var exp_velocity: Vector2:
	get:
		return velocity
	set(value):
		velocity = value

var is_echo_below := false
var is_echo_above := false

func _physics_process(_delta: float) -> void:
	if is_echo_below:
		velocity.y = min(velocity.y, 0.)
	if is_echo_above:
		if Global.weight >= Global.Weight.MorObese and velocity.y < 0.:
			$AnimationPlayer.play("fat_echo_sitting")
		velocity.y = max(velocity.y, 0.)
	
	move_and_slide()

	if is_on_ceiling() and $AnimationPlayer.current_animation == "climb":
		$AnimationPlayer.play("idle")

func hit_journal_entry() -> void:
	Global.journal_entries.set($EnemyManager.journal_entry, true)

func echo_above_entered(_other) -> void:
	is_echo_above = true

func echo_above_exited(_other) -> void:
	is_echo_above = false
	if $AnimationPlayer.current_animation == "fat_echo_sitting":
		$AnimationPlayer.play("climb")

func echo_below_entered(_other) -> void:
	is_echo_below = true

func echo_below_exited(_other) -> void:
	is_echo_below = false
