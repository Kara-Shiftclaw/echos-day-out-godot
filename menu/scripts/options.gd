class_name Options
extends TabContainer

signal closed()

const OPTIONS_FILE := "user://options.json"

func _ready() -> void:
	$AUDIO/MasterVol.grab_focus.call_deferred()
	
	$AUDIO/MasterVol.value = 100. * AudioServer.get_bus_volume_linear(0)
	$AUDIO/Music.value = 100. * AudioServer.get_bus_volume_linear(1)
	$AUDIO/Sfx.value = 100. * AudioServer.get_bus_volume_linear(2)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		save()
		closed.emit()
		queue_free()

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
	}
	var save_file := FileAccess.open(OPTIONS_FILE, FileAccess.WRITE)
	save_file.store_line(JSON.stringify(options_dict))

func master_vol_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0, value / 100.)

func music_vol_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(1, value / 100.)

func sfx_vol_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(2, value / 100.)
