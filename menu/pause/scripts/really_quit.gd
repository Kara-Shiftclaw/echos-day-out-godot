extends CenterContainer

signal not_quitting()

func _input(event: InputEvent) -> void:
	if event.is_action("pause") or event.is_action("ui_cancel"):
		no()

func yes() -> void:
	get_tree().paused = false
	Global.music_player.stream = null
	get_tree().change_scene_to_file("res://menu/title_screen.tscn")

func no() -> void:
	not_quitting.emit()
	queue_free()
