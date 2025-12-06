extends StaticBody2D

const MAX_PX_DOWN := 25
const OPEN_FLAG := "open"

@export var px_down := 0:
	set(value):
		px_down = value
		if is_node_ready():
			var px_up := (MAX_PX_DOWN - px_down)
			$Door.position.y = -px_up / 2.
			$Door.region_rect.size.y = px_up

func _ready() -> void:
	if Global.has_node_flag(self, OPEN_FLAG):
		$AnimationPlayer.play("auto_open")
		$AnimationPlayer.seek(0., true)

func open():
	Global.set_node_flag(self, OPEN_FLAG)
	$AnimationPlayer.play("open")
