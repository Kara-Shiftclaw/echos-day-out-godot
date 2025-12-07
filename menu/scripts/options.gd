extends TabContainer

signal closed()

func _ready() -> void:
	$A/MasterVol.grab_focus.call_deferred()
	$B/Fireball.button_pressed = Accessibility.fireball
	$B/DoubleJump.button_pressed = Accessibility.double_jump
	$B/Sprint.button_pressed = Accessibility.sprint
	$B/Crush.button_pressed = Accessibility.crush

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		closed.emit()
		queue_free()

func fireball_pressed() -> void:
	Accessibility.fireball = $B/Fireball.button_pressed

func double_jump_pressed() -> void:
	Accessibility.double_jump = $B/DoubleJump.button_pressed

func sprint_pressed() -> void:
	Accessibility.sprint = $B/Sprint.button_pressed

func crush_pressed() -> void:
	Accessibility.crush = $B/Crush.button_pressed
