extends Node

enum Weight {
	Thin = 0,
	Fat = 1,
	Obese = 2,
	MorObese = 3,
	Blob = 4
}

signal save()
signal chunk_loaded(cx: int, cy: int)

var echo: Echo
var camera: FollowCamera
var health_bar: HealthBar
var save_id := 1
var last_save_path := ^"/root/IntroMountain/SavePoint"
var last_save_stage := "res://stages/intro_mountain.tscn"

var has_fireball := false
var has_double_jump := false
var has_sprint := false
var has_crush := false
var weight := Weight.Thin

var music_player: AudioStreamPlayer = null
var master_vol := 1.
var music_vol := 0.7
var sfx_vol := 0.9

var flags := {}

func save_data(save_point: Node) -> void:
	var save_dict := {
		"stage": save_point.get_tree().current_scene.scene_file_path,
		"save_point": save_point.get_path(),
		"flags": flags,
		"fireball": has_fireball,
		"double_jump": has_double_jump,
		"sprint": has_sprint,
		"crush": has_crush,
	}
	var save_file := FileAccess.open(save_path(save_id), FileAccess.WRITE)
	save_file.store_line(JSON.stringify(save_dict))
	save.emit()

func load_data(load_id: int) -> void:
	save_id = load_id
	var load_file := FileAccess.open(save_path(load_id), FileAccess.READ)
	var load_json: Dictionary = JSON.parse_string(load_file.get_line())
	flags = load_json["flags"]
	
	get_tree().scene_changed.connect(func():
		var save_point_path: String = load_json["save_point"]
		var save_point: Node2D = get_tree().current_scene.get_node_or_null(save_point_path)
		if save_point == null:
			push_error("Save point {0} not found".format([save_point_path]))
		
		echo.global_position = save_point.global_position
		load_abilities(load_json["fireball"],
				load_json["double_jump"],
				load_json["sprint"],
				load_json["crush"])
		camera.recalculate_chunk()
		health_bar.recalculate_health_bar()
	, ConnectFlags.CONNECT_ONE_SHOT)
	get_tree().change_scene_to_file(load_json["stage"])

func load_new_stage(stage: String,
		new_world_offset: Vector2,
		other_transition_path: String) -> void:
	var echo_health = echo.health
	get_tree().change_scene_to_file(stage)
	get_tree().scene_changed.connect(func():
		print(get_tree().current_scene.is_node_ready())
		var other_transition := get_tree().current_scene.get_node(other_transition_path)
		echo.global_position = other_transition.global_position + new_world_offset
		echo.health = echo_health
		echo.play_anim("idle")
		camera.recalculate_chunk()
		health_bar.recalculate_health_bar()
		
		var transition := Echo.DeathScreen.instantiate()
		camera.add_child(transition)
		transition.fade_in()
	, ConnectFlags.CONNECT_ONE_SHOT)

func full_respawn():
	get_tree().change_scene_to_file(last_save_stage)
	get_tree().scene_changed.connect(func():
		print(get_tree().current_scene.is_node_ready())
		var save_point := get_node(last_save_path)
		echo.global_position = save_point.global_position
		echo.play_anim("idle")
		camera.recalculate_chunk()
		health_bar.recalculate_health_bar()
		
		var transition := Echo.DeathScreen.instantiate()
		camera.add_child(transition)
		transition.fade_in()
	, ConnectFlags.CONNECT_ONE_SHOT)

func load_abilities(
		load_fireball: bool, 
		load_double_jump: bool, 
		load_sprint: bool, 
		load_crush: bool) -> void:
	has_fireball = load_fireball or Accessibility.fireball
	has_double_jump = load_double_jump or Accessibility.double_jump
	has_sprint = load_sprint or Accessibility.sprint
	has_crush = load_crush or Accessibility.crush
	print(has_fireball, has_double_jump, has_sprint, has_crush)
	weight = ((1 if has_fireball else 0) \
			+ (1 if has_double_jump else 0) \
			+ (1 if has_sprint else 0) \
			+ (1 if has_crush else 0)) as Weight

func play_music(song_stream: AudioStream) -> void:
	if music_player == null:
		music_player = AudioStreamPlayer.new()
		add_child(music_player)
	
	if music_player.stream != song_stream:
		music_player.stop()
		music_player.volume_linear = music_vol * master_vol
		music_player.stream = song_stream
		music_player.play()

func set_node_flag(node: Node, flag: String, value: int = 1) -> void:
	var flag_name := node_flag_name(node, flag)
	flags[flag_name] = value

func has_node_flag(node: Node, flag: String) -> bool:
	var flag_name := node_flag_name(node, flag)
	return flags.has(flag_name)

func load_chunk(cx: int, cy: int) -> void:
	chunk_loaded.emit(cx, cy)

func node_flag_name(node:Node, flag: String) -> String:
	return "{0}|{1}|{2}".format([get_tree().current_scene.scene_file_path, node.get_path(), flag])

static func save_path(path_save_id: int) -> String:
	return "user://save_{0}.json".format([path_save_id])
