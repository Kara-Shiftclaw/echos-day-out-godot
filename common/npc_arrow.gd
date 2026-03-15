extends Sprite2D

@export var activation_area: Area2D
var echo_inside := false

signal activated()

func _ready() -> void:
	if activation_area == null:
		activation_area = get_parent() as Area2D
	activation_area.area_entered.connect(entered)
	activation_area.body_entered.connect(entered)
	activation_area.area_exited.connect(exited)
	activation_area.body_exited.connect(exited)

func entered(other: Node2D):
	if other is Player:
		show()
		echo_inside = true

func exited(other: Node2D):
	if other is Player:
		hide()
		echo_inside = false

func generic_pause() -> void:
	get_tree().paused = true

func generic_unpause() -> void:
	get_tree().paused = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up", false) \
			and echo_inside \
			and Global.echo.is_on_floor() \
			and !get_tree().paused:
		activated.emit()
