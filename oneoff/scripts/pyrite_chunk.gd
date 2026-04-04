extends RigidBody2D

const MAX_PYRITE := 500

@export var value := 1

signal collected(full: bool)

func _physics_process(_delta: float) -> void:
	var closest_rotation := roundi(rotation_degrees / 90.) * 90
	$Sprite2D.rotation_degrees = -rotation_degrees + closest_rotation

func entered(other: Node2D) -> void:
	var count: int = Global.flags.get("pyrite", 0)
	if other is Player and count < MAX_PYRITE:
		Global.flags["pyrite"] = clampi(count + value, 0, MAX_PYRITE)
		collected.emit(false)
		queue_free()
	else:
		collected.emit(true)
