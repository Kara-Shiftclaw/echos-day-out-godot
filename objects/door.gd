extends StaticBody2D

const MAX_PX_DOWN := 25

@export var px_down := 0:
	set(value):
		px_down = value
		if is_node_ready():
			var px_up := (MAX_PX_DOWN - px_down)
			$Door.position.y = -px_up / 2.
			$Door.region_rect.size.y = px_up

func open():
	$AnimationPlayer.play("open")
