class_name AbstractTextScript
extends Node

signal text_started()
signal _self_impulse()
signal text_ended()

@export var default_textbox_scene: PackedScene = preload("res://textengine/text_box.tscn")
@export var default_option_box_scene: PackedScene = preload("res://textengine/option_box.tscn")
@export var pause_unpause: bool = true

var registered_textboxes: Array[TextBox] = []
var registered_option_boxes: Array[OptionBox] = []
var default_textbox: TextBox
var in_progress := false
var lflags := {}

func next_impulse() -> void:
	_self_impulse.emit()

func script() -> void:
	await txt("PLACEHOLDER_1")
	await txt("PLACEHOLDER_2")

func start() -> void:
	if pause_unpause:
		get_tree().paused = true
	in_progress = true
	text_started.emit()
	default_textbox = default_textbox_scene.instantiate()
	get_viewport().get_camera_2d().add_child(default_textbox)
	registered_textboxes.push_back(default_textbox)
	
	await script()
	
	for textbox in registered_textboxes:
		textbox.queue_free()
	default_textbox = null
	registered_textboxes = []
	text_ended.emit()
	in_progress = false
	lflags["repeat"] = true
	if pause_unpause:
		get_tree().paused = false

func txt_r(translation: String, begin: int, end: int, textbox: TextBox = null) -> void:
	for i in range(begin, end + 1):
		await txt("{0}_{1}".format([translation, i]), textbox)

func txt(translation: String, textbox: TextBox = null) -> void:
	#print(tr(translation))
	if textbox == null:
		textbox = default_textbox
	if textbox.visible == false:
		for other_textbox in get_tree().get_nodes_in_group("TextBoxes"):
			other_textbox.hide()
		textbox.show()
		
	textbox.set_text(tr(translation))
	textbox.close_signaled.connect(next_impulse, CONNECT_ONE_SHOT)
	
	await _self_impulse

func opt_txt(translation: String, options: Array[TextEngine.Option], option_box: OptionBox, textbox: TextBox = null) -> int:
	if textbox == null:
		textbox = default_textbox
	if textbox.visible == false:
		for other_textbox in get_tree().get_nodes_in_group("TextBoxes"):
			other_textbox.hide()
		textbox.show()
		
	textbox.set_text(tr(translation))
	
	await textbox.scroll_finished
	
	option_box.clear()
	for option in options:
		option_box.add_option(option)
	option_box.display_on_textbox(textbox)
	
	var chosen: int = await option_box.option_chosen
	option_box.hide()
	return chosen

func opt(display_text: String) -> TextEngine.Option:
	return TextEngine.Option.new(display_text)

func d_opt(display_text: String, description: String = "") -> TextEngine.Option:
	if description == "":
		description = display_text + "_D"
	return TextEngine.Option.new(display_text, description)

func load_textbox(path: String) -> TextBoxWrapper:
	var textbox: TextBox = load(path).instantiate()
	textbox.visible = false
	get_viewport().get_camera_2d().add_child(textbox)
	registered_textboxes.push_back(textbox)
	
	return TextBoxWrapper.new(textbox)

func load_option_box(path = null) -> OptionBox:
	if path != null and !(path is String or path is StringName):
		push_error("Invalid path of type ", typeof(path))
		return null
	
	var option_box_scene: PackedScene = default_option_box_scene if path == null else load(path)
	var option_box: OptionBox = option_box_scene.instantiate()
	get_viewport().get_camera_2d().add_child(option_box)
	registered_option_boxes.push_back(option_box)
	
	return option_box

func repeat() -> bool:
	return lflags.get("repeat", false)

class TextBoxWrapper:
	extends RefCounted
	
	var textbox: TextBox
	
	func _init(textbox_: TextBox) -> void:
		textbox = textbox_
	
	func txt(script: AbstractTextScript, translation: String):
		await script.txt(translation, textbox)
