extends AnimatableBody2D

signal on_press()
@export var pressed := false

func stood_on(other: Node2D) -> void:
	if other is Player and !pressed:
		$AnimationPlayer.play("start_press")

func not_stood_on(other: Node2D) -> void:
	if other is Player and $AnimationPlayer.current_animation == "start_press":
		$AnimationPlayer.play("RESET")

func force_press() -> void:
	$AnimationPlayer.play("force_press")

func emit_press() -> void:
	on_press.emit()
