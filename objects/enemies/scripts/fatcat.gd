extends CharacterBody2D

const Weight := Global.Weight
const RUN_SPEED := 10. * 8.
const KNOCKBACK_KNOCKUP := Echo.STAGE_HAZARD_BOUNCE
const KNOCKBACK_SPEED_MAP: Dictionary[Weight, float] = {
	Weight.Thin: 60. * 8.,
	Weight.Fat: 60. * 8.,
	Weight.Obese: 50. * 8.,
	Weight.MorObese: 35. * 8.,
	Weight.Blob: 20. * 8.,
}

@export var facing_right := false:
	set(value):
		facing_right = value
		sync_facing_right()


signal whistle()


func _ready() -> void:
	sync_facing_right()

func _physics_process(delta: float) -> void:
	var cur_anim: String = $AnimationPlayer.current_animation
	if cur_anim == "idle":
		if seeing_player($Flip/Front) or seeing_player($Flip/Back):
			$AnimationPlayer.play("attack")
	elif cur_anim == "run_away":
		velocity.x = RUN_SPEED * Util.sign(facing_right)
		velocity.y += Echo.GRAVITY * delta
		move_and_slide()
		if is_on_floor() and (is_on_wall() or Util.off_screen_in_direction(facing_right, $Left, $Right)):
			$AnimationPlayer.play("cower")


func run_away() -> void:
	self.facing_right = !Global.echo_is_right(self)
	$AnimationPlayer.play("run_away")

func emit_whistle() -> void:
	whistle.emit()

func face_player() -> void:
	self.facing_right = Global.echo_is_right(self)

func sync_facing_right() -> void:
	if is_node_ready():
		$Flip.scale.x = Util.sign(!facing_right)

func knockback_player() -> void:
	Global.echo.velocity.x = KNOCKBACK_SPEED_MAP[Global.weight] * Util.sign(facing_right)
	Global.echo.velocity.y = KNOCKBACK_KNOCKUP


static func seeing_player(raycast: RayCast2D) -> bool:
	return raycast.is_colliding() and raycast.get_collider() is Player
