extends StaticBody2D

@export var save_open_flag := false
@export var start_open := false

var is_open := false

func _ready() -> void:
	if (save_open_flag and Global.has_node_flag(self, "open")) or start_open:
		$AnimationPlayer.play("auto_open")
		is_open = true

func open():
	if !is_open:
		$AnimationPlayer.play("open")
		is_open = true
		if save_open_flag:
			Global.set_node_flag(self, "open")

func close():
	if is_open:
		$AnimationPlayer.play_backwards("open")
		is_open = false
		if save_open_flag:
			Global.unset_node_flag(self, "open")
	else:
		push_warning("close() called but already closing")
