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

static func calculate_quadratic_jump(x_offset: float, max_height: float, duration_to_even: float) -> QuadraticJump:
	var x_velocity := x_offset / duration_to_even
	# y = vt - gt^2
	# 0 = vd - gd^2
	# v = gd
	# Y = vd/2 - gd^2/4
	# Y = gd^2/2 - gd^2/4
	# Y = gd^2/4
	# g = 4Y/d^2
	# v = 4Y/d
	var y_velocity := -4 * max_height / duration_to_even
	var gravity := -2 * y_velocity / duration_to_even
	
	return QuadraticJump.new(Vector2(x_velocity, y_velocity), gravity)

class QuadraticJump:
	extends RefCounted
	
	var initial_velocity: Vector2
	var gravity: float
	
	func _init(initial_velocity_: Vector2, gravity_: float) -> void:
		initial_velocity = initial_velocity_
		gravity = gravity_
