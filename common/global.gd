extends Node

enum Weight {
	Thin = 0,
	Fat = 1,
	Obese = 2,
	MorObese = 3,
	Blob = 4
}
const STARTING_MAX_HEALTH := 15.
const PauseMenu := preload("res://menu/pause/pause_menu.tscn")

signal save()
signal chunk_loaded(cx: int, cy: int)
signal echo_health_changed(value: float)
signal echo_died()

var echo: Echo
var camera: FollowCamera
var health_bar: HealthBar
var save_id := 1
var last_save_path := ^"/root/IntroMountain/SavePoint"
var last_save_stage := "res://stages/intro_mountain.tscn"

var _fireball := false
var _double_jump := false
var _sprint := false
var _crush := false
var has_fireball:
	get:
		return _fireball or Accessibility.fireball
	set(value):
		_fireball = value
var has_double_jump := false:
	get:
		return _double_jump or Accessibility.double_jump
	set(value):
		_double_jump = value
var has_sprint:
	get:
		return _sprint or Accessibility.sprint
	set(value):
		_sprint = value
var has_crush:
	get:
		return _crush or Accessibility.crush
	set(value):
		_crush = value

var weight := Weight.Thin
var max_health := STARTING_MAX_HEALTH
var health := 0.:
	set(value):
		var clamped_health := clampf(value, 0., max_health)
		if clamped_health != health:
			echo_health_changed.emit(clamped_health)
		health = clamped_health
		if health == 0.:
			echo_died.emit()

var music_player: AudioStreamPlayer = null

var flags := {}
var explored_spaces := {}

func save_data(save_point: Node) -> void:
	var save_dict := {
		"stage": save_point.get_tree().current_scene.scene_file_path,
		"explored_spaces": compress_explored_spaces(),
		"save_point": save_point.get_path(),
		"flags": flags,
		"max_health": max_health,
		"fireball": _fireball,
		"double_jump": _double_jump,
		"sprint": _sprint,
		"crush": _crush,
	}
	var save_file := FileAccess.open(save_path(save_id), FileAccess.WRITE)
	save_file.store_line(JSON.stringify(save_dict))
	save.emit()

func load_data(load_id: int) -> void:
	save_id = load_id
	var load_file := FileAccess.open(save_path(load_id), FileAccess.READ)
	var load_json: Dictionary = JSON.parse_string(load_file.get_line())
	flags = load_json["flags"]
	
	explored_spaces = {}
	var load_explored_spaces: Dictionary = load_json.get("explored_spaces", {})
	for stage in load_explored_spaces:
		var stage_explored_spaces := {}
		for explored_space in load_explored_spaces[stage]:
			stage_explored_spaces[explored_space] = true
		explored_spaces[stage] = stage_explored_spaces
	
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
		max_health = load_json["max_health"]
		health = max_health
	, ConnectFlags.CONNECT_ONE_SHOT)
	get_tree().change_scene_to_file(load_json["stage"])

func load_new_stage(stage: String,
		new_world_offset: Vector2,
		other_transition_path: String) -> void:
	get_tree().change_scene_to_file(stage)
	get_tree().scene_changed.connect(func():
		print(get_tree().current_scene.is_node_ready())
		var other_transition := get_tree().current_scene.get_node(other_transition_path)
		echo.global_position = other_transition.global_position + new_world_offset
		echo.play_anim("idle")
		camera.recalculate_chunk()
		health_bar.recalculate_health_bar(health)
		
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
		health_bar.recalculate_health_bar(max_health)
		
		var transition := Echo.DeathScreen.instantiate()
		camera.add_child(transition)
		transition.fade_in()
	, ConnectFlags.CONNECT_ONE_SHOT)

func restore_health():
	health = max_health

func load_abilities(
		load_fireball: bool, 
		load_double_jump: bool, 
		load_sprint: bool, 
		load_crush: bool) -> void:
	has_fireball = load_fireball
	has_double_jump = load_double_jump
	has_sprint = load_sprint
	has_crush = load_crush
	recalculate_weight()

func recalculate_weight() -> void:
	weight = ((1 if has_fireball else 0) \
			+ (1 if has_double_jump else 0) \
			+ (1 if has_sprint else 0) \
			+ (1 if has_crush else 0)) as Weight
	if echo != null:
		echo.play_anim("idle")

func play_music(song_stream: AudioStream) -> void:
	if music_player == null:
		music_player = AudioStreamPlayer.new()
		music_player.finished.connect(music_player.play)
		music_player.bus = "Music"
		add_child(music_player)
	
	if music_player.stream != song_stream:
		music_player.stop()
		music_player.stream = song_stream
		music_player.play()

func _input(event: InputEvent) -> void:
	if echo != null and !get_tree().paused and event.is_action("pause") and event.is_pressed():
		camera.add_child(PauseMenu.instantiate())
		get_tree().paused = true

func unpause() -> void:
	get_tree().paused = false

func set_node_flag(node: Node, flag: String, value: int = 1) -> void:
	var flag_name := node_flag_name(node, flag)
	flags[flag_name] = value

func has_node_flag(node: Node, flag: String) -> bool:
	var flag_name := node_flag_name(node, flag)
	return flags.has(flag_name)

func load_chunk(cx: int, cy: int) -> void:
	chunk_loaded.emit(cx, cy)
	add_explored_space(cx, cy)

func add_explored_space(cx: int, cy: int) -> void:
	var stage := get_tree().current_scene.name
	var stage_explored_spaces: Dictionary = explored_spaces.get(stage, {})
	stage_explored_spaces.set(explored_space_str(cx, cy), true)
	explored_spaces.set(stage, stage_explored_spaces)

func compress_explored_spaces() -> Dictionary[String, Array]:
	var compressed_explored_spaces: Dictionary[String, Array] = {}
	for stage in explored_spaces:
		compressed_explored_spaces.set(stage, explored_spaces[stage].keys())
	return compressed_explored_spaces

func explored_space_str(cx: int, cy: int) -> String:
	return "{0} {1}".format([cx, cy])

func node_flag_name(node:Node, flag: String) -> String:
	return "{0}|{1}|{2}".format([get_tree().current_scene.scene_file_path, node.get_path(), flag])

static func save_path(path_save_id: int) -> String:
	return "user://save_{0}.json".format([path_save_id])
