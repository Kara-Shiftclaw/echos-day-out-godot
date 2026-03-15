extends Area2D

const Honey := preload("res://objects/enemies/honey.tscn")

const SPEED := 17. * 8.
const EXPLODE_OFFSET := 1.

var velocity: Vector2

@export var moving_right := true

func _ready() -> void:
	$Sprite2D.flip_h = !moving_right
	velocity = Vector2(SPEED * Util.sign(moving_right), SPEED)

func _physics_process(delta: float) -> void:
	position += velocity * delta

func explode(other: Node2D = null) -> void:
	if other is Player:
		other.add_child(Honey.instantiate())
	elif other.is_in_group("Bees") and other.has_method("eat"):
		other.eat()
	elif other.has_node("EnemyManager"):
		return
	queue_free()
