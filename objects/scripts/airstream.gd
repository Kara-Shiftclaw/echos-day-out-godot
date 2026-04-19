@tool
extends ReferenceRect

const FULL_SCREEN_PARTICLES := 20
const FULL_SCREEN_DURATION := 0.6

func on_resize() -> void:
	var col_rect := RectangleShape2D.new()
	col_rect.size = size
	$Area2D/CollisionShape2D.shape = col_rect
	$Area2D/CollisionShape2D.position = size / 2.
	
	$CPUParticles2D.emission_rect_extents = Vector2(size.x / 2., 5.)
	$CPUParticles2D.position = Vector2(size.x / 2., size.y - 5.)
	$CPUParticles2D.amount = roundi(FULL_SCREEN_PARTICLES * size.y / Util.ROOM_SIZE * size.x / 16.)
	$CPUParticles2D.lifetime = FULL_SCREEN_DURATION * size.y / Util.ROOM_SIZE

func player_entered(other: Node2D) -> void:
	if other is Player:
		other.in_airstream = true

func player_exited(other: Node2D) -> void:
	if other is Player:
		other.in_airstream = false

func _ready() -> void:
	on_resize()
