extends Node2D

var health := 3

func _ready() -> void:
	var all_honey := get_tree().get_nodes_in_group("Honey")
	if all_honey.size() != 1:
		for other in all_honey:
			if other != self and other.get_parent() == get_parent():
				queue_free()
				return
	
	var bees := get_tree().get_nodes_in_group("Bees")
	for bee in bees:
		if bee.has_method("become_hungry"):
			bee.become_hungry()
		if bee.has_signal("ate"):
			bee.ate.connect(queue_free)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and $MinAttackTimer.is_stopped():
		health -= 1
		$MinAttackTimer.start()
		$CPUParticles2D.emitting = true
		if health < 1:
			queue_free()

func destroy() -> void:
	var bees := get_tree().get_nodes_in_group("Bees")
	for bee in bees:
		if bee.has_method("stop_hungry"):
			bee.stop_hungry()
