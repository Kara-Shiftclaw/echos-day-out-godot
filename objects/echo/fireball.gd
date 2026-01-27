extends Area2D

const SPEED := 17. * 8.
const DOWN_SPEED := Vector2(3. * 8., 20. * 8.)
const EXPLODE_OFFSET := 1.

var hitbox_shape: CircleShape2D
var velocity: Vector2

@export var hitbox_radius: float:
	get:
		return hitbox_shape.radius
	set(value):
		if is_node_ready():
			hitbox_shape.radius = value
@export var moving_right := true

func _ready() -> void:
	hitbox_shape = $CollisionShape2D.shape
	hitbox_radius = 4.
	$Sprite2D.flip_h = !moving_right
	velocity = Vector2(SPEED * Util.sign(moving_right), SPEED)

func _physics_process(delta: float) -> void:
	position += velocity * delta

func fire_down() -> void:
	velocity = velocity.rotated(PI / 8. * Util.sign(moving_right))

func explode(_other: Node2D) -> void:
	$AnimationPlayer.play("explode")
	velocity = Vector2.ZERO
	translate(Vector2(EXPLODE_OFFSET * Util.sign(moving_right), EXPLODE_OFFSET))
