extends Area2D

@export var only_smol_echo := false

func _ready() -> void:
	if only_smol_echo != Global.is_smol:
		queue_free()
