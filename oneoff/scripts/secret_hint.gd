extends Area2D

func entered(_other) -> void:
	$EchoInTimer.start()

func exited(_other) -> void:
	$EchoInTimer.stop()

func display() -> void:
	get_tree().paused = true
	$TextTree.render()

func after_display() -> void:
	get_tree().paused = false
	queue_free()
