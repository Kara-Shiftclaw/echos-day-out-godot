class_name FloorDetector
extends VisibleOnScreenNotifier2D

var valid_floor: bool

func _process(_delta: float) -> void:
	valid_floor = $RayCast2D.is_colliding() and is_on_screen()
