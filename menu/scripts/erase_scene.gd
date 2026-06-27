extends ColorRect

@export var player_can_close := false
var save_id: int

func return_to_title_screen() -> void:
	var title_screen_scene: PackedScene = load("res://menu/title_screen.tscn")
	var title_screen := title_screen_scene.instantiate()
	get_tree().root.add_child(title_screen)
	title_screen.quick_load(save_id)
	queue_free()

func erase_save() -> void:
	var path := Global.save_path(save_id)
	var remove_err := DirAccess.remove_absolute(path)
	if remove_err != OK:
		push_error("Couldn't remove save ", save_id, ": ", remove_err)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("ui_accept") and player_can_close:
		return_to_title_screen()
	if event.is_action("pause"):
		return_to_title_screen()
