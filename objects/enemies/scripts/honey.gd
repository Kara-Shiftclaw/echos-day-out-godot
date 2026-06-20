extends Node2D

var health := 3

func _ready() -> void:
	$Sprite2D.frame = Global.weight as int
	
	var all_honey := get_tree().get_nodes_in_group("Honey")
	if all_honey.size() != 1:
		for other in all_honey:
			if other != self and other.get_parent() == get_parent():
				queue_free()
				return

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and $MinAttackTimer.is_stopped():
		health -= 1
		$MinAttackTimer.start()
		if health < 1:
			$AnimationPlayer.play("break")
		else:
			$AnimationPlayer.play("hit")

func _physics_process(_delta: float) -> void:
	$Sprite2D.flip_h = Global.echo.facing_right
