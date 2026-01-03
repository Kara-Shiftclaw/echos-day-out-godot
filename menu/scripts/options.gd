class_name Options
extends TabContainer

signal closed()

const OPTIONS_FILE := "options.json"

func _ready() -> void:
	$A/MasterVol.grab_focus.call_deferred()
	
	$A/MasterVol.value = 100. * AudioServer.get_bus_volume_linear(0)
	$A/Music.value = 100. * AudioServer.get_bus_volume_linear(1)
	$A/Sfx.value = 100. * AudioServer.get_bus_volume_linear(2)
	
	$H/VBoxContainer/Fireball.button_pressed = Accessibility.fireball
	$H/VBoxContainer/DoubleJump.button_pressed = Accessibility.double_jump
	$H/VBoxContainer/Sprint.button_pressed = Accessibility.sprint
	$H/VBoxContainer/Crush.button_pressed = Accessibility.crush

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
	else:
		print("No options file to load")

func save() -> void:
	var options_dict := {
		master_vol = AudioServer.get_bus_volume_linear(0),
		music_vol = AudioServer.get_bus_volume_linear(1),
		sfx_vol = AudioServer.get_bus_volume_linear(2),
		accessibility_fireball = Accessibility.fireball,
		accessibility_double_jump = Accessibility.double_jump,
		accessibility_sprint = Accessibility.sprint,
		accessibility_crush = Accessibility.crush,
	}
	var save_file := FileAccess.open(OPTIONS_FILE, FileAccess.WRITE)
	save_file.store_line(JSON.stringify(options_dict))

func master_vol_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0, value / 100.)

func music_vol_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(1, value / 100.)

func sfx_vol_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(2, value / 100.)

func fireball_pressed() -> void:
	Accessibility.fireball = $H/VBoxContainer/Fireball.button_pressed

func double_jump_pressed() -> void:
	Accessibility.double_jump = $H/VBoxContainer/DoubleJump.button_pressed

func sprint_pressed() -> void:
	Accessibility.sprint = $H/VBoxContainer/Sprint.button_pressed

func crush_pressed() -> void:
	Accessibility.crush = $H/VBoxContainer/Crush.button_pressed
