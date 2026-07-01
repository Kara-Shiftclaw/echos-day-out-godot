class_name Util
extends Object

const ROOM_SIZE := 128.

func _init() -> void:
	push_error("Do not instantiate Util object")

static func sign(b: bool) -> int:
	return 1 if b else -1

static func off_edge_in_direction(moving_right: bool, left: FloorDetector, right: FloorDetector) -> bool:
	return (moving_right and !right.valid_floor) or (!moving_right and !left.valid_floor)

static func off_screen_in_direction(moving_right: bool, left: VisibleOnScreenNotifier2D, right: VisibleOnScreenNotifier2D) -> bool:
	return (moving_right and !right.is_on_screen()) or (!moving_right and !left.is_on_screen())

static func chunk_of(global_position: Vector2) -> Vector2i:
	return Vector2i(global_position / Vector2(ROOM_SIZE, ROOM_SIZE))

static func other_is_right(this: Node2D, other: Node2D) -> bool:
	return other.global_position.x > this.global_position.x

static func serialize(obj: Object) -> Dictionary[String, Variant]:
	var ser: Dictionary[String, Variant] = {}
	for property in obj.get_property_list():
		if property["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE != 0:
			var property_name: String = property["name"]
			ser[property_name] = obj.get(property_name)
	return ser

static func deserialize(dict: Dictionary, empty_obj: Object) -> void:
	for property in empty_obj.get_property_list():
		var property_name: String = property["name"]
		if dict.has(property_name):
			empty_obj.set(property_name, dict.get(property_name))

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
