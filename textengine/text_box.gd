class_name TextBox
extends Panel

const CHARACTERS_PER_SECOND := 20

signal scroll_ready()
signal scroll_finished()
signal scroll_continue(new_top: int)
signal close_signaled()
signal started()

@export var move_if_blocking_player := false
@export var move_always := false
@export var label: Label
@export var box_visible_size := 8 * 5
@export var auto_free := true
var visible_characters_float := 0.
var scrolling := true
var dialogue_blip: AudioStreamPlayer
var visible_size: int

func _ready() -> void:
	dialogue_blip = get_node_or_null("DialogueBlip")
	if is_moved():
		position.y = Global.camera.get_viewport_rect().size.y - size.y
	else:
		position.y = 0.
	if label == null:
		label = $Label
	visible_size = box_visible_size

func set_text(text: String) -> void:
	label.text = text
	visible_characters_float = 0.
	visible_size = box_visible_size
	label.visible_characters = 0
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
			visible_characters_float = label.text.length()

		if scrolling:
			var visible_delta = CHARACTERS_PER_SECOND * delta
			if Input.is_action_pressed("ui_skip_text"):
				visible_delta *= 3.
			visible_characters_float += visible_delta
			
			if visible_characters_float > label.text.length():
				scrolling = false
				scroll_finished.emit()
			
			var new_visible_characters := floori(visible_characters_float)
			if new_visible_characters != label.visible_characters:
				var previous := label.visible_characters
				label.visible_characters = new_visible_characters
				if label.get_character_bounds(new_visible_characters).position.y >= visible_size:
					label.visible_characters = previous
					scrolling = false
					scroll_ready.emit()
				elif dialogue_blip != null:
					dialogue_blip.play()
		elif Input.is_action_just_pressed("ui_skip_text"):
			if label.visible_characters >= label.text.length():
				close_signaled.emit()
			else:
				scroll_continue.emit(next_char_top())
				visible_size += box_visible_size
				scrolling = true

func is_moved() -> bool:
	return move_always or (move_if_blocking_player and player_blocked())

func player_blocked() -> bool:
	var echo_screen_y := fposmod(Global.echo.global_position.y, Util.ROOM_SIZE)
	return echo_screen_y < size.y

func next_char_top() -> float:
	return floori(label.get_character_bounds(label.visible_characters + 1).position.y)
