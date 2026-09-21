extends Control

func _ready() -> void:
	$ACC/ScrollContainer/VBoxContainer/MaxHealth/HSlider.value = Accessibility.max_hp_offset
	$ACC/ScrollContainer/VBoxContainer/Energy/HSlider.value = Accessibility.energy_strength
	$ACC/ScrollContainer/VBoxContainer/Smol.button_pressed = Accessibility.is_smol
	$ACC/ScrollContainer/VBoxContainer/DebugPowers.button_pressed = Accessibility.debug_powers
	set_max_hp_label(Accessibility.max_hp_offset)
	set_energy_strength_label(Accessibility.energy_strength)
	if Global.IS_DEMO_BUILD:
		$ACC/ScrollContainer/VBoxContainer/Smol.queue_free()
		$ACC/ScrollContainer/VBoxContainer/DebugPowers.queue_free()

func max_hp_offset_changed(value: float) -> void:
	var value_int := floori(value)
	Accessibility.max_hp_offset = value_int
	set_max_hp_label(value_int)

func energy_strength_changed(value: float) -> void:
	var value_int := floori(value)
	Accessibility.energy_strength = value_int
	set_energy_strength_label(value_int)

func smol_pressed() -> void:
	Accessibility.is_smol = $ACC/ScrollContainer/VBoxContainer/Smol.button_pressed

func debug_powers_pressed() -> void:
	Accessibility.debug_powers = $ACC/ScrollContainer/VBoxContainer/DebugPowers.button_pressed

func set_max_hp_label(value: int) -> void:
	if value >= 0:
		$ACC/ScrollContainer/VBoxContainer/MaxHealth/Label.text = "+%02d" % value
	else:
		$ACC/ScrollContainer/VBoxContainer/MaxHealth/Label.text = "%03d" % value

func set_energy_strength_label(value: int) -> void:
	$ACC/ScrollContainer/VBoxContainer/Energy/Label.text = " +%01d " % value
