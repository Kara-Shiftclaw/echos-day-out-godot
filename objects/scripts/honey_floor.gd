extends Control

const Honey := preload("res://objects/enemies/honey.tscn")

var echo_in := false

func _ready() -> void:
	var w := size.x
	$Sprite2D.region_rect.size.x = w
	($Area2D/CollisionShape2D.shape as RectangleShape2D).size.x = w
	$Area2D/CollisionShape2D.position.x = w / 2.

func enter(other: Node2D) -> void:
	if other is Echo:
		other.add_child(Honey.instantiate())
		$HoneyShoot.play()
		echo_in = true

func exit(other: Node2D) -> void:
	if other is Echo:
		echo_in = false

func _physics_process(_delta: float) -> void:
	if echo_in and abs(Global.echo.velocity.x) > 0.1:
		$CPUParticles2D.global_position = Global.echo.global_position
		$CPUParticles2D.emitting = true
		$HoneyShoot.playing = true
	else:
		$CPUParticles2D.emitting = false
		$HoneyShoot.playing = true
		
