extends Node2D

const LAST_SAVE_FILE := "user://last_save.txt"

const FirstStage := preload("res://stages/intro_mountain.tscn")
const OptionsMenu := preload("res://menu/options.tscn")
const EraseScene := preload("res://menu/erase_scene.tscn")
const CantCopyScene := preload("res://menu/cant_copy_scene.tscn")

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
	if $Options/UnderSaves/Copy.button_pressed or $Options/UnderSaves/Erase.button_pressed:
		$CantErase.play()
	else:
		Global.save_id = load_id
		write_last_save_id(load_id)
		get_tree().scene_changed.connect(func():
			Global.load_abilities(false, false, false, false, false)
			Global.recalculate_max_hp()
		, ConnectFlags.CONNECT_ONE_SHOT)
		get_tree().change_scene_to_packed(FirstStage)
		queue_free()

func continue_game(load_id: int) -> void:
	if $Options/UnderSaves/Copy.button_pressed:
		try_copy_save(load_id)
	elif $Options/UnderSaves/Erase.button_pressed:
		var erase_scene := EraseScene.instantiate()
		get_tree().root.add_child(erase_scene)
		erase_scene.save_id = load_id
		queue_free()
	else:
		if Global.has_saved_data(load_id):
			write_last_save_id(load_id)
			Global.load_data(load_id)
			queue_free()

func write_last_save_id(load_id: int) -> void:
	last_save_id = load_id
	FileAccess.open(LAST_SAVE_FILE, FileAccess.WRITE).store_string(str(load_id))

func open_options_menu() -> void:
	var options_menu := OptionsMenu.instantiate()
	add_child(options_menu)
	options_menu.get_child(0).connect("closed", func():
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
		
		$AnimationPlayer.play("load_menu")
		$Options/UnderSaves/Copy.focus_neighbor_top = $Options/Saves.get_child(0).get_path()
		$Options/UnderSaves/Erase.focus_neighbor_top = $Options/Saves.get_child(3).get_path()
		$Options/Saves.get_child(last_save_id - 1).call_deferred("grab_focus")
		
		var prev: Control = $Options/Saves.get_child(3)
		for child in $Options/Saves.get_children():
			var cur := child as Control
			#print("Connecting ", prev.name, " to ", cur.name)
			cur.focus_neighbor_left = prev.get_path()
			cur.focus_previous = prev.get_path()
			prev.focus_neighbor_right = cur.get_path()
			prev.focus_next = cur.get_path()
			cur.focus_neighbor_top = cur.get_path()
			prev = cur

func close_saved_games() -> void:
	$AnimationPlayer.play("close_load_menu")
	$AnimationPlayer.animation_finished.connect(func(_ignored):
		for child in $Options/Saves.get_children():
			child.queue_free()
			in_save_menu = false
	, ConnectFlags.CONNECT_ONE_SHOT)
	$Options/VBoxContainer/Start.call_deferred("grab_focus")

func quick_load(save_id: int) -> void:
	print("Quick load!")
	last_save_id = save_id
	open_saved_games()
	$AnimationPlayer.play("quick_load")
	$AnimationPlayer.seek(0., true)

func try_copy_save(save_id: int) -> void:
	for i in range(1, 5):
		if !Global.has_saved_data(i):
			var src_data := Global.get_load_json(save_id)
			var dst_file := FileAccess.open(Global.save_path(i), FileAccess.WRITE)
			dst_file.store_line(JSON.stringify(src_data, "\t"))
			dst_file.close()
			
			last_save_id = i
			in_save_menu = false
			for child in $Options/Saves.get_children():
				$Options/Saves.remove_child(child)
				child.queue_free()
			open_saved_games()
			$AnimationPlayer.play("post_copy")
			
			$Copy.play()
			$Options/UnderSaves/Copy.button_pressed = false
			return
	
	var cant_copy_scene := CantCopyScene.instantiate()
	get_tree().root.add_child(cant_copy_scene)
	cant_copy_scene.save_id = save_id
	queue_free()

func show_credits() -> void:
	$Credits.show()
	$Credits.grab_focus.call_deferred()
