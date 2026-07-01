extends Control

func _ready() -> void:
	$ACC/VBoxContainer/MaxHealth/HSlider.value = Accessibility.max_hp_offset
	$ACC/VBoxContainer/Smol.button_pressed = Accessibility.is_smol
	$ACC/VBoxContainer/DebugPowers.button_pressed = Accessibility.debug_powers
	set_max_hp_label(Accessibility.max_hp_offset)

func max_hp_offset_changed(value: float) -> void:
	var value_int := floori(value)
	Accessibility.max_hp_offset = value_int
	set_max_hp_label(value_int)

func smol_pressed() -> void:
	Accessibility.is_smol = $ACC/VBoxContainer/Smol.button_pressed

func debug_powers_pressed() -> void:
	Accessibility.debug_powers = $ACC/VBoxContainer/DebugPowers.button_pressed

func set_max_hp_label(value: int) -> void:
	if value >= 0:
		$ACC/VBoxContainer/MaxHealth/Label.text = "+%02d" % value
	else:
		$ACC/VBoxContainer/MaxHealth/Label.text = "%03d" % value
