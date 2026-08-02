extends CharacterBody2D

const DASH_SPEED := 20. * 8.
const DASH_TIME := 0.2
const DASH_DECELERATION := DASH_SPEED * DASH_TIME

@export var facing_right := false:
	set(value):
		facing_right = value
		sync_facing_right()

@onready var echo_sight: RayCast2D = $FacingHolder/EchoSight

func _ready() -> void:
	sync_facing_right()

func _physics_process(delta: float) -> void:
	if $AnimationPlayer.current_animation == "idle":
		if echo_sight.is_colliding() and echo_sight.get_collider() is Player:
			$AnimationPlayer.play("pre_attack")
	elif $AnimationPlayer.current_animation == "attack":
		print(velocity.x)
		if Util.off_edge_in_direction(facing_right, $Left, $Right):
			velocity.x = 0.
		else:
			velocity.x = move_toward(velocity.x, 0., DASH_DECELERATION * delta)
		move_and_slide()


func dash_forward() -> void:
	velocity.x = DASH_SPEED * Util.sign(facing_right)

func turn() -> void:
	self.facing_right = !facing_right

func on_damage() -> void:
	if Global.echo_is_right(self) != facing_right and $AnimationPlayer.current_animation == "idle":
		$AnimationPlayer.play("turn")

func turn_if_on_edge() -> void:
	if Util.off_edge_in_direction(facing_right, $Left, $Right):
		$AnimationPlayer.play("turn")


func sync_facing_right() -> void:
	if is_node_ready():
		$FacingHolder.scale.x = Util.sign(!facing_right)
