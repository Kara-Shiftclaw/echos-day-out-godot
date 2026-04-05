class_name TextBoxView
extends Panel

const CHARACTERS_PER_SECOND := 20
const SCENE := preload("res://menu/dialogue/view/text_box.tscn")

signal scroll_finished()
signal close_signaled()

@export var move_if_blocking_echo := false
var visible_characters_float := 0.
var scrolling := true
var dialogue_blip: AudioStreamPlayer

static func with_text(text: String) -> TextBoxView:
	var text_box_view: TextBoxView = SCENE.instantiate()
	text_box_view.set_text(text)
	text_box_view.move_if_blocking_echo = true
	return text_box_view

func _ready() -> void:
	dialogue_blip = get_node_or_null("DialogueBlip")
	if move_if_blocking_echo and echo_blocked():
		position.y = Util.ROOM_SIZE - size.y

func set_text(text: String) -> void:
	$Label.text = text

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		close_signaled.emit()

	if scrolling:
		var visible_delta = CHARACTERS_PER_SECOND * delta
		if Input.is_action_pressed("ui_skip_text"):
			visible_delta *= 3.
		visible_characters_float += visible_delta
		
		if visible_characters_float > $Label.text.length():
			scrolling = false
			scroll_finished.emit()
		
		var new_visible_characters := floori(visible_characters_float)
		if new_visible_characters != $Label.visible_characters:
			$Label.visible_characters = new_visible_characters
			if dialogue_blip != null:
				dialogue_blip.play()
	elif Input.is_action_just_pressed("ui_skip_text"):
		close_signaled.emit()

func echo_blocked() -> bool:
	var echo_screen_y := fposmod(Global.echo.global_position.y, Util.ROOM_SIZE)
	return echo_screen_y < size.y
