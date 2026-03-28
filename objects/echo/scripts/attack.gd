extends Area2D

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		$CollisionShape2D.set_deferred("disabled", true)
