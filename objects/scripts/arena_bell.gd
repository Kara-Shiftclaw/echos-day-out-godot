extends Area2D

signal start()
signal failed()
signal succeeded()
signal already_succeeded()

var chunk: Vector2i
var active := false

func _ready() -> void:
	chunk = Vector2i(global_position / Vector2(Util.ROOM_SIZE, Util.ROOM_SIZE))
	Global.echo.respawned.connect(on_echo_respawn)
	if Global.has_node_flag(self, "succeeded"):
		already_succeeded.emit()

func on_hit(_other: Node2D) -> void:
	if !active && Global.camera.chunk == chunk && !Global.has_node_flag(self, "succeeded"):
		$AnimationPlayer.play("ring")
		active = true
		start.emit()

func on_echo_respawn() -> void:
	if active:
		active = false
		failed.emit()

func succeed() -> void:
	if active:
		active = false
		succeeded.emit()
		Global.set_node_flag(self, "succeeded")
