extends ScrollContainer

@export var vbox_container: VBoxContainer

func _ready() -> void:
	for child_idx in range(1, get_child_count()):
		var child := get_child(child_idx)
		child.reparent(vbox_container)
	vbox_container.add_spacer(false)

func reset() -> void:
	scroll_vertical = 0

func scroll_view(scroll_to: int) -> void:
	var scroll_tween := create_tween()
	scroll_tween.tween_property(
		self,
		"scroll_vertical",
		scroll_to,
		0.4)
