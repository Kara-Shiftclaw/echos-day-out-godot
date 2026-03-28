class_name StageTransition
extends ReferenceRect

@export_file("*.tscn") var other_stage: String
@export var other_transition_name: String
@export var other_transition_parent := "StageTransitions"
@export var enabled := true

func _ready() -> void:
	if other_transition_name == null or other_transition_name.is_empty():
		other_transition_name = get_tree().current_scene.name

func get_all_rooms() -> PackedVector2Array:
	var screen_rect := Rect2i(position / Util.ROOM_SIZE, size / Util.ROOM_SIZE)
	var result := PackedVector2Array()
	for xi in range(0, screen_rect.size.x):
		for yi in range(0, screen_rect.size.y):
			result.append(Vector2(screen_rect.position.x + xi, screen_rect.position.y + yi))
	return result

func get_other_transition_path() -> String:
	return "{0}/{1}".format([other_transition_parent, other_transition_name])

func disable() -> void:
	enabled = false
