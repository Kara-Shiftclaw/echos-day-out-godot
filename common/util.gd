class_name Util
extends Object

const ROOM_SIZE := 128.

func _init() -> void:
	push_error("Do not instantiate Util object")

static func sign(b: bool) -> int:
	return 1 if b else -1

static func off_edge_in_direction(moving_right: bool, left: FloorDetector, right: FloorDetector) -> bool:
	return (moving_right and !right.valid_floor) or (!moving_right and !left.valid_floor)

static func off_screen_in_direction(moving_right: bool, left: FloorDetector, right: FloorDetector) -> bool:
	return (moving_right and !right.is_on_screen()) or (!moving_right and !left.is_on_screen())

static func chunk_of(global_position: Vector2) -> Vector2i:
	return Vector2i(global_position / Vector2(ROOM_SIZE, ROOM_SIZE))
