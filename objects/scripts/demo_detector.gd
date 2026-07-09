extends Node

@export var parent_demo_only := true

func _ready() -> void:
	if parent_demo_only != Global.IS_DEMO_BUILD:
		get_parent().queue_free()
