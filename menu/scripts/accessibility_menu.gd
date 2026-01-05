extends Panel

func _ready() -> void:
	$ACC/VBoxContainer/Fireball.button_pressed = Accessibility.fireball
	$ACC/VBoxContainer/DoubleJump.button_pressed = Accessibility.double_jump
	$ACC/VBoxContainer/Sprint.button_pressed = Accessibility.sprint
	$ACC/VBoxContainer/Crush.button_pressed = Accessibility.crush

func fireball_pressed() -> void:
	Accessibility.fireball = $ACC/VBoxContainer/Fireball.button_pressed

func double_jump_pressed() -> void:
	Accessibility.double_jump = $ACC/VBoxContainer/DoubleJump.button_pressed

func sprint_pressed() -> void:
	Accessibility.sprint = $ACC/VBoxContainer/Sprint.button_pressed

func crush_pressed() -> void:
	Accessibility.crush = $ACC/VBoxContainer/Crush.button_pressed
