extends Area2D

@export var flag_needed: String
@export var animation_player: AnimationPlayer
var player_in := false
var open := false

func entered(other: Node2D) -> void:
	if other is Player and open:
		player_in = true

func exited(other: Node2D) -> void:
	if other is Player:
		player_in = false

func _ready() -> void:
	try_open()

func _physics_process(_delta: float) -> void:
	var echo := Global.echo
	if player_in and open and !echo.can_double_jump:
		$Touch.play()
		echo.can_double_jump = true
		open = false
		player_in = false
		animation_player.play("close")
		echo.land_on_floor.connect(try_open, ConnectFlags.CONNECT_ONE_SHOT)

func try_open() -> void:
	if Global.flags.has(flag_needed):
		open = true
		animation_player.play("open")

func slow_try_open() -> void:
	if Global.flags.has(flag_needed):
		open = true
		if animation_player.has_animation("slow_open"):
			animation_player.play("slow_open")
		else:
			animation_player.play("open")
