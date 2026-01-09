class_name TextBoxView
extends Panel

const CHARACTERS_PER_SECOND := 20
const SCENE := preload("res://menu/dialogue/view/text_box.tscn")

signal scroll_finished()
signal close_signaled()

var visible_characters_float := 0.
var scrolling := true

static func with_text(text: String) -> TextBoxView:
	var text_box_view: TextBoxView = SCENE.instantiate()
	text_box_view.set_text(text)
	return text_box_view

func set_text(text: String) -> void:
	$Label.text = text

func _process(delta: float) -> void:
	if scrolling:
		var visible_delta = CHARACTERS_PER_SECOND * delta
		if Input.is_action_pressed("ui_skip_text"):
			visible_delta *= 3.
		visible_characters_float += visible_delta
		
		if visible_characters_float > $Label.text.length():
			scrolling = false
			scroll_finished.emit()
		
		$Label.visible_characters = floori(visible_characters_float)
	elif Input.is_action_just_pressed("ui_skip_text"):
		close_signaled.emit()
