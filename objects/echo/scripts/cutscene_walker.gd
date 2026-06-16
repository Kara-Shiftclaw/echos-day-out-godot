class_name CutsceneWalker
extends Node2D

const SCENE := preload("res://objects/echo/cutscene_walker.tscn")

var walk_speed: float
@export var x_destination: float
@export var face_right_on_deletion: bool
@export var show_echo_on_relocate := true

signal dest_reached()

static func instantiate() -> CutsceneWalker:
	return SCENE.instantiate()

func _ready() -> void:
	$Sprite2D.texture = (Global.echo.get_node("Sprite2D") as Sprite2D).texture
	walk_speed = Echo.SPEED_MAP[Global.weight]
	global_position = Global.echo.global_position
	$Sprite2D.flip_h = x_destination < position.x
	Global.echo.hide()
	tree_exiting.connect(relocate_echo)

func load_alt_texture(texture: Texture, region = null) -> void:
	$Sprite2D.texture = texture
	$Sprite2D.hframes = 4
	$Sprite2D.vframes = 1
	if region != null and region is Rect2:
		$Sprite2D.region_enabled = true
		$Sprite2D.region_rect = region
	$AnimationPlayer.play("alt_walk")

func _physics_process(delta: float) -> void:
	position.x = move_toward(position.x, x_destination, delta * walk_speed)
	if position.x == x_destination:
		dest_reached.emit()
		queue_free()
	print(position, visible, $Sprite2D.region_rect)

func relocate_echo() -> void:
	Global.echo.global_position = global_position
	Global.echo.facing_right = face_right_on_deletion
	Global.echo.velocity = Vector2.ZERO
	Global.echo.play_anim("idle")
	Global.echo.anim_seek(0., true)
	if show_echo_on_relocate:
		Global.echo.show()
	hide()
