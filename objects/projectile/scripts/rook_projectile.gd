extends CharacterBody2D

const SPEED := 72

func aim_at_echo() -> void:
	var distance := Global.echo.global_position - global_position
	velocity = distance.normalized() * SPEED
	$AnimationPlayer.play("idle")

func _physics_process(_delta: float) -> void:
	move_and_slide()
