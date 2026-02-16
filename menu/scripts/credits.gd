extends Control

const SCROLL_SPEED := 20. * 8.

var bottom: float

func _ready() -> void:
	bottom = 128. - $CreatedBy.size.y

func _process(delta: float) -> void:
	if has_focus():
		var map_scroll := Input.get_axis("ui_up", "ui_down")
		$CreatedBy.position.y = clamp($CreatedBy.position.y - map_scroll * SCROLL_SPEED * delta, bottom, 0.)

func _input(event: InputEvent) -> void:
	if has_focus():
		if (event.is_echo() or event.is_pressed()) and \
				(event.is_action("ui_up") or event.is_action("ui_left") or \
				event.is_action("ui_right") or event.is_action("ui_down")):
			get_viewport().set_input_as_handled()

func reset_pos() -> void:
	$CreatedBy.position.y = 0.
