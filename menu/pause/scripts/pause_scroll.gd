extends ScrollContainer


func _ready() -> void:
	await get_tree().process_frame
	$ScrollArrow.global_position = global_position + size + Vector2(-9, 3)
	on_scrolled()

func _input(event: InputEvent) -> void:
	if event.is_action("ui_accept") and !at_bottom():
		scroll_vertical += floori(size.y)
		on_scrolled()


func reset() -> void:
	scroll_vertical = 0
	on_scrolled()

func on_scrolled() -> void:
	await get_tree().process_frame
	if at_bottom():
		$AnimationPlayer.play("RESET")
	else:
		$AnimationPlayer.play("bob")

func at_bottom() -> bool:
	return scroll_vertical + size.y >= get_v_scroll_bar().max_value - 0.5
