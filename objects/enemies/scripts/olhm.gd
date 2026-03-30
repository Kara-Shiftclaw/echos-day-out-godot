@tool
extends CharacterBody2D

const DASH_SPEED := 18. * 8.
enum Size {
	Thin = 0,
	Fat,
	Obese
}

@export var size := Size.Thin:
	set(value):
		size = value
		if is_node_ready():
			sync_size()

@export var facing_right := false:
	set(value):
		facing_right = value
		if is_node_ready():
			sync_facing_right()

@export var use_dash_hitbox := false:
	set(value):
		use_dash_hitbox = value
		if is_node_ready():
			if use_dash_hitbox:
				set_hitbox(dash_hitbox)
			else:
				set_hitbox(normal_hitbox)

@export var normal_hitbox: RectangleShape2D
@export var dash_hitbox: RectangleShape2D

func sync_size() -> void:
	$AnimationPlayer.play("sync_size_{0}".format([size as int]))
	$AnimationPlayer.seek(0., true)

func sync_facing_right() -> void:
	$Sprite2D.flip_h = facing_right

func set_hitbox(hitbox: RectangleShape2D) -> void:
	$CollisionShape2D.shape = hitbox
	$DamageBox/CollisionShape2D.shape = hitbox
	$Hurtbox/CollisionShape2D.shape = hitbox

func _ready() -> void:
	sync_size()
	sync_facing_right()

func _physics_process(delta: float) -> void:
	if !Engine.is_editor_hint():
		if $AnimationPlayer.current_animation == "dash":
			var col := move_and_collide(velocity * delta)
			if col != null or Util.off_screen_in_direction(facing_right, $Left, $Right):
				facing_right = !facing_right
				$AnimationPlayer.play("charge")

func do_dash() -> void:
	if !Engine.is_editor_hint():
		velocity.x = DASH_SPEED * Util.sign(facing_right)
		$AnimationPlayer.play("dash")
		$Dash.play()
