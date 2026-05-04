extends Node2D

const LAST_SAVE_FILE := "user://last_save.txt"

const FirstStage := preload("res://stages/intro_mountain.tscn")
const OptionsMenu := preload("res://menu/options.tscn")

var last_save_id := 1
var in_save_menu := false

func _ready() -> void:
	Options.load_options()
	var last_save_file_contents := FileAccess.get_file_as_string(LAST_SAVE_FILE)
	if !last_save_file_contents.is_empty():
		last_save_id = last_save_file_contents.to_int()
	if !Global.has_saved_data(1):
		$Options/VBoxContainer/Continue.disabled = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel", false, false):
		if $Credits.visible:
			$Credits.hide()
			$Credits.reset_pos()
			$Options/VBoxContainer/Credits.grab_focus.call_deferred()
		if $AnimationPlayer.is_playing() and $AnimationPlayer.current_animation == "begin":
			$AnimationPlayer.seek(2.0)
		if in_save_menu:
			close_saved_games()

func new_game(load_id: int) -> void:
	Global.save_id = load_id
	write_last_save_id(load_id)
	get_tree().scene_changed.connect(func():
		Global.load_abilities(false, false, false, false, false)
		Global.recalculate_max_hp()
	, ConnectFlags.CONNECT_ONE_SHOT)
	get_tree().change_scene_to_packed(FirstStage)

func continue_game(load_id: int) -> void:
	if Global.has_saved_data(load_id):
		write_last_save_id(load_id)
		Global.load_data(load_id)

func write_last_save_id(load_id: int) -> void:
	last_save_id = load_id
	FileAccess.open(LAST_SAVE_FILE, FileAccess.WRITE).store_string(str(load_id))

func open_options_menu() -> void:
	var options_menu := OptionsMenu.instantiate()
	add_child(options_menu)
	options_menu.connect("closed", func():
		$Options/VBoxContainer/Options.grab_focus.call_deferred()
	)

func open_saved_games() -> void:
	if !in_save_menu:
		in_save_menu = true
		for i in range(1, 5):
			var button: Button
			if Global.has_saved_data(i):
				button = SaveGameHUD.load_from_save(Global.get_load_json(i), i)
				button.pressed.connect(func():
					continue_game(i)
				)
			else:
				button = SaveGameHUD.new_game()
				button.pressed.connect(func():
					new_game(i)
				)
			
			$Options/Saves.add_child(button)
			button.focus_neighbor_bottom = button.get_path()
			button.focus_neighbor_top = button.get_path()
		
		$AnimationPlayer.play("load_menu")
		var first: Button = $Options/Saves.get_child(0)
		var last: Button = $Options/Saves.get_child(3)
		first.focus_neighbor_left = last.get_path()
		last.focus_neighbor_right = first.get_path()
		$Options/Saves.get_child(last_save_id - 1).call_deferred("grab_focus")

func close_saved_games() -> void:
	$AnimationPlayer.play("close_load_menu")
	$AnimationPlayer.animation_finished.connect(func(_ignored):
		for child in $Options/Saves.get_children():
			child.queue_free()
			in_save_menu = false
	, ConnectFlags.CONNECT_ONE_SHOT)
	$Options/VBoxContainer/Start.call_deferred("grab_focus")

func show_credits() -> void:
	$Credits.show()
	$Credits.grab_focus.call_deferred()
