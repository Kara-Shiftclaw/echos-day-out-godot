class_name Util
extends Object

func _init() -> void:
	push_error("Do not instantiate Util object")

static func sign(b: bool) -> int:
	return 1 if b else -1
