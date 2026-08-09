class_name TextBox
extends Panel

const CHARACTERS_PER_SECOND := 20

signal scroll_finished()
signal close_signaled()
signal started()

@export var move_if_blocking_player := false
@export var move_always := false
var visible_characters_float := 0.
var scrolling := true
var dialogue_blip: AudioStreamPlayer

func _ready() -> void:
	dialogue_blip = get_node_or_null("DialogueBlip")
	if is_moved():
		position.y = get_viewport_rect().size.y - size.y
	else:
		position.y = 0.

func set_text(text: String) -> void:
	$Label.text = text
	visible_characters_float = 0.
	$Label.visible_characters = 0
	scrolling = true
	if is_moved():
		position.y = Util.ROOM_SIZE - size.y
	else:
		position.y = 0.
	started.emit()

func _process(delta: float) -> void:
	if visible:
		if Input.is_action_just_pressed("pause") and visible_characters_float > 0.:
			close_signaled.emit()
			visible_characters_float = $Label.text.length()

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

func is_moved() -> bool:
	return move_always or (move_if_blocking_player and player_blocked())

func player_blocked() -> bool:
	return false
