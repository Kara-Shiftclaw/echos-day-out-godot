class_name TextBoxView
extends Panel

const CHARACTERS_PER_SECOND := 20
const SCENE := preload("res://menu/dialogue/view/text_box.tscn")

signal scroll_ready()
signal scroll_finished()
signal scroll_continue()
signal close_signaled()

@export var move_if_blocking_echo := false
@export var move_always := false
@export var label: Label
@export var box_visible_size := 8 * 5
var visible_characters_float := 0.
var scrolling := true
var dialogue_blip: AudioStreamPlayer
var visible_size: int

static func with_text(text: String) -> TextBoxView:
	var text_box_view: TextBoxView = SCENE.instantiate()
	text_box_view.set_text(text)
	text_box_view.move_if_blocking_echo = true
	return text_box_view

func _ready() -> void:
	dialogue_blip = get_node_or_null("DialogueBlip")
	if move_always or (move_if_blocking_echo and echo_blocked()):
		position.y = Util.ROOM_SIZE - size.y
	if label == null:
		label = $Label
	visible_size = box_visible_size


func scroll_view() -> void:
	# Default implementation
	var scroll_container: ScrollContainer = get_node_or_null("ScrollContainer")
	if scroll_container != null:
		var scroll_tween := create_tween()
		scroll_tween.tween_property(
			scroll_container,
			"scroll_vertical",
			label.get_character_bounds(label.visible_characters + 1).position.y,
			0.4)


func set_text(text: String) -> void:
	label.text = tr(text)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
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
			scroll_view()
			scroll_continue.emit()
			visible_size += box_visible_size
			scrolling = true

func echo_blocked() -> bool:
	var echo_screen_y := fposmod(Global.echo.global_position.y, Util.ROOM_SIZE)
	return echo_screen_y < size.y
