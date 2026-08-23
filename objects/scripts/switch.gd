extends Area2D

const ACTIVATED_FLAG := "activated"

signal activate()
signal already_activated()

@export var maybe_activate := false

var activated := false

func _ready() -> void:
	if Global.has_node_flag(self, ACTIVATED_FLAG):
		activated = true
		$AnimationPlayer.play("auto_activated")
		already_activated.emit()
	if maybe_activate:
		area_entered.disconnect(do_activate)
		body_entered.disconnect(do_activate)
		area_entered.connect(do_maybe_activate.unbind(1))
		body_entered.connect(do_maybe_activate.unbind(1))


func do_activate() -> void:
	if activated:
		$AnimationPlayer.play("hit_after_activated")
	else:
		activate.emit()
		confirm_activation()

func do_maybe_activate() -> void:
	if activated:
		$AnimationPlayer.play("hit_after_activated")
	else:
		$AnimationPlayer.play("fail_activate")
		activate.emit()

func confirm_activation() -> void:
	activated = true
	Global.set_node_flag(self, ACTIVATED_FLAG)
	$AnimationPlayer.play("activate")
