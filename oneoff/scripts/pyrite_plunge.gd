extends Node2D

func _ready() -> void:
	if Global.flags.has("green_plant_open"):
		$StageTransitions/ToLower.disable()
		$StageTransitions/ToUpper.disable()
