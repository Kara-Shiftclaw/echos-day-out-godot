extends StaticBody2D

@export var sword_spirit: Node
var broken := false

func _ready() -> void:
	if Global.flags.has("sword_broken"):
		queue_free()

func entered(other: Node2D) -> void:
	if other is Player and !broken:
		$AnimationPlayer.play("crack")

func exited(other: Node2D) -> void:
	if other is Player and !broken:
		$AnimationPlayer.pause()

func do_break() -> void:
	$AnimationPlayer.play("break")
	broken = true
	Global.echo.land_on_floor.connect(func():
		Global.echo.play_anim("idle", 99)
		Global.echo.anim_priority = 0
		Global.echo.facing_right = true
		Global.echo.anim_seek(0., true)
		
		process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().paused = true
		Global.flags.set("sword_broken", true)
		sword_spirit.summon()
	, ConnectFlags.CONNECT_ONE_SHOT)
