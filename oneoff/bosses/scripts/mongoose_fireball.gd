extends Area2D

const SPEED := 24. * 8.
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

func aim(global_dest: Vector2) -> void:
	var raw_angle_to := global_position.angle_to(global_dest)
	while raw_angle_to < 0.:
		raw_angle_to += 2 * PI
	var min_angle := PI / 6. if moving_right else 4 * PI / 6.
	var max_angle := 2 * PI / 6. if moving_right else 5 * PI / 6.
	var angle_to := clampf(raw_angle_to, min_angle, max_angle)
	velocity = Vector2.from_angle(angle_to) * SPEED

func _physics_process(delta: float) -> void:
	position += velocity * delta

func explode(_other: Node2D) -> void:
	$AnimationPlayer.play("explode")
	velocity = Vector2.ZERO
	translate(Vector2(EXPLODE_OFFSET * Util.sign(moving_right), EXPLODE_OFFSET))

func disable_on_first_hit() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
