extends Node2D

const DEFAULT_PLATFORM_OFFSET := -12.
const DEFAULT_PILLAR_OFFSET := 8.
const KNOCKBACK_VELOCITY := 30. * 8.

@export var platform_offset := 0.:
	set(value):
		frame_delta = value - platform_offset
		platform_offset = value
var frame_delta := 0.

var pillar_shape: RectangleShape2D

func _ready() -> void:
	pillar_shape = $Platform/Pillar/CollisionShape2D.shape

func _physics_process(time_delta: float) -> void:
	$Platform.velocity.y = frame_delta / time_delta
	$Platform.move_and_slide()
	$Platform.position.y = DEFAULT_PLATFORM_OFFSET + platform_offset
	$Platform/PillarSprite2D.region_rect.position.y = platform_offset
	$Platform/PillarSprite2D.region_rect.size.y = DEFAULT_PILLAR_OFFSET - platform_offset
	pillar_shape.size.y = -platform_offset
	$Platform/Pillar.position.y = DEFAULT_PILLAR_OFFSET - platform_offset / 2.

func knockback_other(other: Node2D) -> void:
	if other is CharacterBody2D:
		var other_right := other.global_position.x > global_position.x
		other.velocity.x = KNOCKBACK_VELOCITY * Util.sign(other_right)
