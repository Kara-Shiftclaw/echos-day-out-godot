extends Node2D

const FirstStage := preload("res://stages/intro_mountain.tscn")
const OptionsMenu := preload("res://menu/options.tscn")

func _ready() -> void:
	$Options/VBoxContainer.get_child(0).grab_focus.call_deferred()

func new_game() -> void:
	get_tree().scene_changed.connect(func():
		Global.echo.load_abilities(false, false, false, false)
	, )
	get_tree().change_scene_to_packed(FirstStage)

func continue_game() -> void:
	Global.load_data(1)

func load_options() -> void:
	var options_menu :=OptionsMenu.instantiate()
	add_child(options_menu)
	options_menu.connect("closed", func():
		$Options/VBoxContainer/Options.grab_focus.call_deferred()
	)
