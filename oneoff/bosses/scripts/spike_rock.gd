extends CharacterBody2D

const Y_CORRECTION := Vector2(0., -4.)
const SPEED := 200.

var moving_right: bool

func _ready() -> void:
	if moving_right:
		$AnimationPlayer.play("right")
	else:
		$AnimationPlayer.play("left")

func _physics_process(delta: float) -> void:
	var col = move_and_collide(velocity * delta)
	if col != null:
		$AnimationPlayer.play("break")

func get_spiked() -> void:
	var player_dir: Vector2 = Global.echo.global_position + Y_CORRECTION - $Sprite2D.global_position
	if moving_right != (player_dir.x > 0):
		if player_dir.y < 0:
			player_dir = Vector2.UP
		else:
			player_dir = Vector2.DOWN
	
	velocity = player_dir.normalized() * SPEED
	global_position = $Sprite2D.global_position
	$Sprite2D.position = Vector2.ZERO
	$AnimationPlayer.play("spin")

func neuter() -> void:
	$Damage.active = false
