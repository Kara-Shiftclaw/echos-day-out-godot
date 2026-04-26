extends Node

enum Weight {
	Thin = 0,
	Fat = 1,
	Obese = 2,
	MorObese = 3,
	Blob = 4
}
const STARTING_MAX_HEALTH := 15.
const MUSH_CURSE := 5.
const PauseMenu := preload("res://menu/pause/pause_menu.tscn")

const MONGOOSE_COMPLETED_FLAG := "mongoose_boss_completed"

signal save()
signal chunk_loaded(cx: int, cy: int)
signal echo_health_changed(value: float)
signal echo_died()

var echo: Player
var camera: FollowCamera
var health_bar: HealthBar
var save_id := 1
var last_save_path := ^"/root/IntroMountain/SavePoint"
var last_save_stage := "res://stages/intro_mountain.tscn"

var _fireball := false
var _double_jump := false
var _sprint := false
var _crush := false
var _smol := false
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
var is_smol:
	get:
		return _smol or Accessibility.is_smol
	set(value):
		_smol = value

var weight := Weight.Thin
var max_health := STARTING_MAX_HEALTH:
	set(value):
		var offset := value - max_health
		max_health = value
		if offset > 0:
			self.health += offset
		else:
			self.health = clamp(health, 1., max_health)
		if health_bar != null:
			health_bar.recalculate_max_health()
var health := 0.:
	set(value):
		var clamped_health := clampf(value, 0., max_health_mush_adjusted())
		if clamped_health != health:
			echo_health_changed.emit(clamped_health)
		health = clamped_health
		if health == 0.:
			echo_died.emit()

var music_player: AudioStreamPlayer

var flags := {}
var explored_spaces := {}
var journal_entries := {"journalist": true, "artifact": true, "hugehog": true}
var portals := {}

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.finished.connect(music_player.play)
	music_player.bus = "Music"
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(music_player)

func save_data(save_point: Node) -> void:
	var save_dict := {
		"stage": save_point.get_tree().current_scene.scene_file_path,
		"explored_spaces": compress_explored_spaces(),
		"save_point": save_point.get_path(),
		"flags": flags,
		"journal_entries": journal_entries,
		"portals": portals,
		"max_health": max_health,
		"fireball": _fireball,
		"double_jump": _double_jump,
		"sprint": _sprint,
		"crush": _crush,
		"is_smol": _smol,
	}
	var save_file := FileAccess.open(save_path(save_id), FileAccess.WRITE)
	save_file.store_line(JSON.stringify(save_dict, "\t"))
	save.emit()

func has_saved_data(load_id: int) -> bool:
	return FileAccess.file_exists(save_path(load_id))

func load_data(load_id: int) -> void:
	save_id = load_id
	var load_file := FileAccess.open(save_path(load_id), FileAccess.READ)
	var load_json: Dictionary = JSON.parse_string(load_file.get_as_text())
	flags = load_json["flags"]
	if load_json.has("journal_entries"):
		journal_entries = load_json["journal_entries"]
	portals = load_json.get("portals", {})
	
	explored_spaces = {}
	var load_explored_spaces: Dictionary = load_json.get("explored_spaces", {})
	for stage in load_explored_spaces:
		var stage_explored_spaces := {}
		for explored_space in load_explored_spaces[stage]:
			stage_explored_spaces[explored_space] = true
		explored_spaces[stage] = stage_explored_spaces
	
	if flags.has(MONGOOSE_COMPLETED_FLAG):
		_fireball = true
	
	get_tree().scene_changed.connect(func():
		var save_point_path: String = load_json["save_point"]
		var save_point: Node2D = get_tree().current_scene.get_node_or_null(save_point_path)
		if save_point == null:
			push_error("Save point {0} not found".format([save_point_path]))
		
		echo.global_position = save_point.global_position
		load_abilities(load_json["fireball"],
				load_json["double_jump"],
				load_json["sprint"],
				load_json["crush"],
				load_json.get("is_smol", false))
		echo.play_anim("idle")
		echo.anim_seek(0.)
		
		camera.recalculate_chunk()
		recalculate_max_hp()
		max_health = load_json["max_health"]
		health = max_health
	, ConnectFlags.CONNECT_ONE_SHOT)
	get_tree().change_scene_to_file(load_json["stage"])

func load_new_stage(stage: String,
		new_world_offset: Vector2,
		transition_chunk_offset: Vector2i,
		other_transition_path: String,
		jumping_up: bool) -> void:
	var echo_dir := echo.facing_right
	get_tree().change_scene_to_file(stage)
	get_tree().scene_changed.connect(func():
		var other_transition := get_tree().current_scene.get_node(other_transition_path)
		echo.global_position = other_transition.global_position + new_world_offset
		echo.facing_right = echo_dir
		echo.play_anim("idle")
		echo.anim_seek(0.)
		if jumping_up:
			echo.new_stage_jump()
		camera.recalculate_chunk()
		health_bar.recalculate_health_bar(health)
		
		var other_transition_chunk := (other_transition.global_position / Util.ROOM_SIZE).floor() as Vector2i + transition_chunk_offset
		add_explored_space(other_transition_chunk.x, other_transition_chunk.y)
		
		var transition := Echo.DeathScreen.instantiate()
		camera.add_child(transition)
		transition.fade_in()
	, ConnectFlags.CONNECT_ONE_SHOT)

func portal_to_new_stage(dest_name: String):
	var portal_details: Dictionary = portals[dest_name]
	var stage: String = portal_details["scene_file_path"]
	var path: String = portal_details["path"]
	
	get_tree().change_scene_to_file(stage)
	get_tree().scene_changed.connect(func():
		var other_portal: Node2D = get_tree().current_scene.get_node(path)
		echo.global_position = other_portal.global_position
		echo.facing_right = true
		echo.play_anim("idle")
		echo.anim_seek(0.)
		
		camera.recalculate_chunk()
		health_bar.recalculate_health_bar(health)
		
		var transition := Echo.DeathScreen.instantiate()
		camera.add_child(transition)
		transition.fade_in()
		get_tree().paused = false
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

func grant_abilities(
		grant_fireball: bool, 
		grant_double_jump: bool, 
		grant_sprint: bool, 
		grant_crush: bool) -> void:
	load_abilities(
		grant_fireball or _fireball,
		grant_double_jump or _double_jump,
		grant_sprint or _sprint,
		grant_crush or _crush,
		_smol,
	)

func load_abilities(
		load_fireball: bool, 
		load_double_jump: bool, 
		load_sprint: bool, 
		load_crush: bool,
		load_smol: bool) -> void:
	has_fireball = load_fireball
	has_double_jump = load_double_jump
	has_sprint = load_sprint
	has_crush = load_crush
	is_smol = load_smol
	recalculate_weight()

func recalculate_weight() -> void:
	if false:
		weight = Weight.Thin
	else:
		weight = ((1 if has_fireball else 0) \
				+ (1 if has_double_jump else 0) \
				+ (1 if has_sprint else 0) \
				+ (1 if has_crush else 0)) as Weight

	if echo != null:
		echo.play_anim("idle")

func recalculate_max_hp() -> void:
	var gained_hp := flags.get("health_up_collected", 0) as int * 3
	max_health = clampf(STARTING_MAX_HEALTH + gained_hp + Accessibility.max_hp_offset, 1, 999)

func max_health_mush_adjusted() -> float:
	if has_mush_curse():
		return maxf(max_health - MUSH_CURSE, 1)
	else:
		return max_health

func has_mush_curse() -> bool:
	return flags.get("has_mycelium_map", false) and !flags.has("has_mush_meal")

func play_music(song_stream: AudioStream) -> void:
	if music_player.stream != song_stream:
		music_player.stop()
		music_player.stream = song_stream
		music_player.play()

func _input(event: InputEvent) -> void:
	if echo != null and !get_tree().paused and event.is_action("pause") and event.is_pressed():
		camera.add_child(PauseMenu.instantiate())
		get_tree().paused = true

func _notification(what: int) -> void:
	if music_player != null:
		if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
			music_player.process_mode = Node.PROCESS_MODE_DISABLED
		elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
			music_player.process_mode = Node.PROCESS_MODE_ALWAYS

func unpause() -> void:
	get_tree().paused = false

func set_node_flag(node: Node, flag: String, value: int = 1) -> void:
	var flag_name := node_flag_name(node, flag)
	flags[flag_name] = value

func unset_node_flag(node: Node, flag: String) -> void:
	var flag_name := node_flag_name(node, flag)
	flags.erase(flag_name)

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
