extends TabContainer

signal closed()

func _ready() -> void:
	$A/MasterVol.grab_focus.call_deferred()
	$H/VBoxContainer/Fireball.button_pressed = Accessibility.fireball
	$H/VBoxContainer/DoubleJump.button_pressed = Accessibility.double_jump
	$H/VBoxContainer/Sprint.button_pressed = Accessibility.sprint
	$H/VBoxContainer/Crush.button_pressed = Accessibility.crush

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		closed.emit()
		queue_free()

func fireball_pressed() -> void:
	Accessibility.fireball = $H/VBoxContainer/Fireball.button_pressed

func double_jump_pressed() -> void:
	Accessibility.double_jump = $H/VBoxContainer/DoubleJump.button_pressed

func sprint_pressed() -> void:
	Accessibility.sprint = $H/VBoxContainer/Sprint.button_pressed

func crush_pressed() -> void:
	Accessibility.crush = $H/VBoxContainer/Crush.button_pressed
