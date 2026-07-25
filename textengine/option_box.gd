class_name OptionBox
extends Control

@export var buttons_parent: Node
@export var description: Label
@export var option_button_scene: PackedScene
@export var dynamic_position := true

signal option_chosen(id: int)
signal show_description()
signal hide_description()

func _ready() -> void:
	hide()

func clear() -> void:
	while buttons_parent.get_child_count() > 0:
		var first_child := buttons_parent.get_child(0)
		buttons_parent.remove_child(first_child)
		first_child.queue_free()

func add_option(option: TextEngine.Option) -> void:
	if option == null:
		buttons_parent.add_child(Control.new())
	else:
		var option_id := buttons_parent.get_child_count()
		var option_button: Button = option_button_scene.instantiate() if option_button_scene != null else Button.new()
		option_button.text = tr(option.display_text)
		
		option_button.pressed.connect(func():
			print("Option chosen")
			option_chosen.emit(option_id)
		)
		if description != null:
			if option.description != "":
				option_button.focus_entered.connect(func():
					show_description.emit()
					description.text = tr(option.description)
				)
			else:
				option_button.focus_entered.connect(hide_description.emit)
		
		buttons_parent.add_child(option_button)

func display_on_textbox(textbox: TextBox) -> void:
	if dynamic_position:
		global_position.x = textbox.global_position.x
		if textbox.is_moved():
			global_position.y = textbox.global_position.y - size.y
		else:
			global_position.y = textbox.global_position.y + textbox.size.y
	show()
	first_usable_button().call_deferred("grab_focus")

func first_usable_button() -> Button:
	for child in buttons_parent.get_children():
		if child is Button:
			return child
	return null
