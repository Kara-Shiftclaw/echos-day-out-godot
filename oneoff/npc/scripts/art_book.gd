extends Area2D

func choose_option() -> void:
	var choice = randi() % 3
	match choice:
		0:
			$Options/Cer.render()
		1:
			$Options/Toxen.render()
		2:
			$Options/Echo.render()
