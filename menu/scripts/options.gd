class_name Options
extends ScrollContainer

signal closed()

const QuitDialogue := preload("res://menu/pause/really_quit.tscn")
const OPTIONS_FILE := "user://options.json"

@export var is_title_screen := false

func _ready() -> void:
	$VBoxContainer/MasterVol.value = 100. * AudioServer.get_bus_volume_linear(0)
	$VBoxContainer/Music.value = 100. * AudioServer.get_bus_volume_linear(1)
	$VBoxContainer/Sfx.value = 100. * AudioServer.get_bus_volume_linear(2)
	
	if is_title_screen:
		$VBoxContainer/MasterVol.grab_focus.call_deferred()
		$VBoxContainer/QuitToMenu.queue_free()

func _process(_delta: float) -> void:
	if is_title_screen and Input.is_action_just_pressed("ui_cancel"):
		save()
		closed.emit()
		get_parent().queue_free()

static func load_options() -> void:
	var options_file := FileAccess.open(OPTIONS_FILE, FileAccess.READ)
	if options_file != null:
		var options: Dictionary = JSON.parse_string(options_file.get_line())
		AudioServer.set_bus_volume_linear(0, options["master_vol"])
		AudioServer.set_bus_volume_linear(1, options["music_vol"])
		AudioServer.set_bus_volume_linear(2, options["sfx_vol"])
		Accessibility.fireball = options["accessibility_fireball"]
		Accessibility.double_jump = options["accessibility_double_jump"]
		Accessibility.sprint = options["accessibility_sprint"]
		Accessibility.crush = options["accessibility_crush"]
		Accessibility.max_hp_offset = options["accessibility_max_hp_offset"] as int
		Accessibility.is_smol = options.get("accessibility_is_smol", false)
	else:
		print("No options file to load")

static func save() -> void:
	var options_dict := {
		master_vol = AudioServer.get_bus_volume_linear(0),
		music_vol = AudioServer.get_bus_volume_linear(1),
		sfx_vol = AudioServer.get_bus_volume_linear(2),
		accessibility_fireball = Accessibility.fireball,
		accessibility_double_jump = Accessibility.double_jump,
		accessibility_sprint = Accessibility.sprint,
		accessibility_crush = Accessibility.crush,
		accessibility_max_hp_offset = Accessibility.max_hp_offset,
		accessibility_is_smol = Accessibility.is_smol,
	}
	var save_file := FileAccess.open(OPTIONS_FILE, FileAccess.WRITE)
	save_file.store_line(JSON.stringify(options_dict))

func master_vol_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0, value / 100.)

func music_vol_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(1, value / 100.)

func sfx_vol_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(2, value / 100.)

func try_quit() -> void:
	(get_parent().get_parent() as Control).focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
	var quit_dialogue: Control = QuitDialogue.instantiate()
	quit_dialogue.not_quitting.connect(on_not_quitting)
	Global.camera.add_child(quit_dialogue)

func on_not_quitting() -> void:
	(get_parent().get_parent() as Control).focus_behavior_recursive = Control.FOCUS_BEHAVIOR_INHERITED
	$VBoxContainer/QuitToMenu.call_deferred("grab_focus")
