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
	view.add_child(option_container)
	
	for child in get_children():
		if child.enabled:
			var choice: Button = child.render()
			option_container.add_child(choice)
			
			child.chosen.connect(view.queue_free, ConnectFlags.CONNECT_ONE_SHOT)
	
	option_container.get_child(0).call_deferred("grab_focus")

func emit_next():
	next.emit()
