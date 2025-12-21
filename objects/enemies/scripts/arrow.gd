extends CharacterBody2D

const SPEED := 14. * 8.

var moving_right := false
var moving_down := false

func _ready() -> void:
	sync_moving_right()
	
func _physics_process(delta: float) -> void:
	var col := move_and_collide(velocity * delta)
	if col != null:
		queue_free()

func on_hit(other: Node2D) -> void:
	var maybe_damage: Damage = other.get_node_or_null("Damage")
	if maybe_damage != null:
		moving_down = true
		moving_right = !moving_right
		sync_moving_right()
		$Hurtbox.queue_free()
		collision_layer = 1 << 3

func sync_moving_right():
	$Sprite2D.flip_h = moving_right
	if moving_down:
		$Sprite2D.frame = 1
		velocity = SPEED * Vector2(Util.sign(moving_right), 1.).normalized()
	else:
		$Sprite2D.frame = 0
		velocity = SPEED * Vector2(Util.sign(moving_right), 0.)
