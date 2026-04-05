extends Node

signal next()

@export_multiline var text: String

func render() -> TextBoxView:
	var view := TextBoxView.with_text(text)
	view.scroll_finished.connect(func(): show_options(view))
	return view

func show_options(view: TextBoxView) -> void:
	var option_container := VBoxContainer.new()
	option_container.anchor_left = 0.
	option_container.anchor_right = 1.
	option_container.anchor_top = 1.
	option_container.offset_top = 1
	option_container.add_theme_constant_override("separation", 3)
	
	if view.move_if_blocking_echo and view.echo_blocked():
		option_container.anchor_bottom = 0.
		option_container.anchor_top = 0.
		option_container.offset_top = 0
		option_container.offset_bottom = -1
		option_container.grow_vertical = Control.GROW_DIRECTION_BEGIN
	
	view.add_child(option_container)
	
	for child in get_children():
		if child.enabled:
			var choice: Button = child.render()
			option_container.add_child(choice)
			
			child.chosen.connect(view.queue_free, ConnectFlags.CONNECT_ONE_SHOT)
	
	option_container.get_child(0).call_deferred("grab_focus")

func emit_next():
	next.emit()
