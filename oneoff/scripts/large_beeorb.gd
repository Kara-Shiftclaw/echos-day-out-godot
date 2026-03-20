extends Sprite2D

@export var switch: Node2D

func _ready() -> void:
	call_deferred("check_switch")

func check_switch() -> void:
	if switch.activated:
		get_fat()

func get_fat() -> void:
	$AnimationPlayer.play("after")
