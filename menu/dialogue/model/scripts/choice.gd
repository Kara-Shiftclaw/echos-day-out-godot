extends Node

signal chosen()

@export var choice_text: String
@export var enabled: bool

func render() -> Button:
	var button := Button.new()
	button.text = choice_text
	button.pressed.connect(chosen.emit)
	return button
