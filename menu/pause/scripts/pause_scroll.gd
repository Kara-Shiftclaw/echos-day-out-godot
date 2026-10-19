extends ScrollContainer


const SCROLL_PX_PER_SECOND := 128.

var scroll_tween: Tween


func _ready() -> void:
	await get_tree().process_frame
	$ScrollArrow.global_position = global_position + size + Vector2(-9, 3)
	on_scrolled()

func _input(event: InputEvent) -> void:
	if event.is_action("ui_accept") and !at_bottom():
		if scroll_tween != null:
			scroll_tween.kill()
		
		$AnimationPlayer.play("RESET")
		scroll_tween = create_tween()
		scroll_tween.tween_property(self, "scroll_vertical", scroll_vertical + floori(size.y), floorf(size.y) / SCROLL_PX_PER_SECOND)
		scroll_tween.tween_callback(on_scrolled)


func reset() -> void:
	if scroll_tween != null:
		scroll_tween.kill()
		scroll_tween = null
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
