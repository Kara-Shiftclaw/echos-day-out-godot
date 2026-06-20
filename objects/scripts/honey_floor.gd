extends Control

const Honey := preload("res://objects/enemies/honey.tscn")

var echo_in := false

func _ready() -> void:
	var w := size.x
	$Sprite2D.region_rect.size.x = w
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w, 8.)
	$Area2D/CollisionShape2D.shape = rect
	$Area2D/CollisionShape2D.position.x = w / 2.

func enter(other: Node2D) -> void:
	if other is Player:
		other.add_child(Honey.instantiate())
		other.speed_scale = 0.5
		$HoneyShoot.play()
		echo_in = true

func exit(other: Node2D) -> void:
	if other is Player:
		other.speed_scale = 1.
		echo_in = false

func _physics_process(_delta: float) -> void:
	if echo_in and abs(Global.echo.velocity.x) > 0.1:
		$CPUParticles2D.global_position = Global.echo.global_position
		$CPUParticles2D.emitting = true
		if !$HoneyShoot.playing:
			$HoneyShoot.play()
	else:
		$CPUParticles2D.emitting = false
		if $HoneyShoot.playing:
			$HoneyShoot.stop()
		
