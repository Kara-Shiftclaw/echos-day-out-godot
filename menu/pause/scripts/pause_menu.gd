extends TabContainer

func _input(event: InputEvent) -> void:
	if event.is_action("pause") and event.is_pressed():
		queue_free()
		Global.call_deferred("unpause")

func save_options() -> void:
	Options.save()
	Global.recalculate_weight()
