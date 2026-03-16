extends Node2D

const FirstStage := preload("res://stages/intro_mountain.tscn")
const OptionsMenu := preload("res://menu/options.tscn")

func _ready() -> void:
	Options.load_options()
	if !Global.has_saved_data(1):
		$Options/VBoxContainer/Continue.disabled = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel", false, false) and $Credits.visible:
		$Credits.hide()
		$Credits.reset_pos()
		$Options/VBoxContainer/Credits.grab_focus.call_deferred()

func new_game() -> void:
	get_tree().scene_changed.connect(func():
		Global.load_abilities(false, false, false, false, false)
		Global.recalculate_max_hp()
	, ConnectFlags.CONNECT_ONE_SHOT)
	get_tree().change_scene_to_packed(FirstStage)

func continue_game() -> void:
	if Global.has_saved_data(1):
		Global.load_data(1)

func open_options_menu() -> void:
	var options_menu := OptionsMenu.instantiate()
	add_child(options_menu)
	options_menu.connect("closed", func():
		$Options/VBoxContainer/Options.grab_focus.call_deferred()
	)

func show_credits() -> void:
	$Credits.show()
	$Credits.grab_focus.call_deferred()
