extends Node2D

var walk_speed: float
@export var x_destination: float
@export var face_right_on_deletion: bool
@export var show_echo_on_relocate := true

signal dest_reached()

func _ready() -> void:
	$Sprite2D.texture = (Global.echo.get_node("Sprite2D") as Sprite2D).texture
	walk_speed = Echo.SPEED_MAP[Global.weight]
	global_position = Global.echo.global_position
	$Sprite2D.flip_h = x_destination < position.x
	Global.echo.hide()
	tree_exiting.connect(relocate_echo)

func _physics_process(delta: float) -> void:
	position.x = move_toward(position.x, x_destination, delta * walk_speed)
	if position.x == x_destination:
		dest_reached.emit()
		queue_free()

func relocate_echo() -> void:
	Global.echo.global_position = global_position
	Global.echo.facing_right = face_right_on_deletion
	Global.echo.velocity = Vector2.ZERO
	Global.echo.play_anim("idle")
	Global.echo.anim_seek(0., true)
	if show_echo_on_relocate:
		Global.echo.show()
	hide()
