extends Node2D

const BODY_OFS := 4.
const BODY_FULL_WIDTH := 8.
const HEAD_COL_OFS := -8.5
const HEAD_SPRITE_OFS := -8.
const HEAD_RAYCAST_OFS := -12.

@export var load_facing_right: bool

@export var facing_right := false:
	set(value):
		if player_riding and facing_right != value:
			Global.echo.facing_right = !Global.echo.facing_right
		facing_right = value
		extension = 0.
		head_frame_movement = 0.
		shell_frame_movement = 0.
		if is_node_ready():
			var facing_sign := Util.sign(value)
			$Shell/Sprite2D.flip_h = value
			$Shell/Sprite2D.offset.x = 0.5 * facing_sign
			
			$Head.position.x = $Shell.position.x
			$Head/CollisionShape2D.position.x = HEAD_COL_OFS * -facing_sign
			$Head/Sprite2D.position.x = HEAD_SPRITE_OFS * -facing_sign
			$Head/Sprite2D.scale.x = -facing_sign
			$Head/RayCast2D.position.x = HEAD_RAYCAST_OFS * -facing_sign
			$Head/RayCast2D.target_position.x = facing_sign
			$Head/RayCast2D2.position.x = HEAD_RAYCAST_OFS * -facing_sign

@export var extension := 0.:
	set(value):
		if value > extension:
			head_frame_movement = (value - extension) * Util.sign(facing_right)
		else:
			shell_frame_movement = (extension - value) * Util.sign(facing_right)
		extension = value

var source_chunk: Vector2i
var head_frame_movement := 0.
var shell_frame_movement := 0.
var reload_frame := false
var player_riding := false

func _ready() -> void:
	source_chunk = Vector2i(floori(position.x / Util.ROOM_SIZE), floori(position.y / Util.ROOM_SIZE))
	if Global.camera != null:
		var chunk := Global.camera.chunk
		on_chunk_load(chunk.x, chunk.y)
	Global.chunk_loaded.connect(on_chunk_load)

func _physics_process(_delta: float) -> void:
	if $Shell.position.x == 0.:
		$Shell/Sprite2D.position = Vector2.ZERO
	
	if head_frame_movement != 0.:
		$Head.move_and_collide(Vector2(head_frame_movement, 0.))
		head_frame_movement = 0.
	if shell_frame_movement != 0.:
		if head_shell_dist() < absf($Shell.position.x + shell_frame_movement - $Head.position.x):
			$Shell.position.x = $Head.position.x
		else:
			$Shell.position.x += shell_frame_movement
		shell_frame_movement = 0.
	
	if !reload_frame:
		var hs_dist := head_shell_dist()
		$Shell/Body.position.x = (BODY_OFS + hs_dist / 2.) * Util.sign(facing_right)
		$Shell/Body.scale.x = hs_dist / BODY_FULL_WIDTH
	reload_frame = false

func head_shell_dist() -> float:
	return absf($Shell.position.x - $Head.position.x)

func on_chunk_load(cx: int, cy: int) -> void:
	if !player_riding:
		if source_chunk == Vector2i(cx, cy):
			show()
			process_mode = ProcessMode.PROCESS_MODE_INHERIT
			self.facing_right = load_facing_right
			$Shell/Sprite2D.position.x = -$Shell.position.x
			$Shell.position.x = 0.
			$Head.position = Vector2.ZERO
			$Shell/Body.scale.x = 0.
			$AnimationPlayer.play("move")
			$AnimationPlayer.seek(0., true)
			Global.journal_entries.set("snail", true)
			reload_frame = true
		else:
			hide()
			process_mode = ProcessMode.PROCESS_MODE_DISABLED

func maybe_turn() -> void:
	if $Head/RayCast2D.is_colliding() or !$Head/RayCast2D2.is_colliding():
		if facing_right:
			$AnimationPlayer.play("turn_rl")
		else:
			$AnimationPlayer.play("turn_lr")

func riding_enter(_other) -> void:
	player_riding = true

func riding_exit(_other) -> void:
	player_riding = false
