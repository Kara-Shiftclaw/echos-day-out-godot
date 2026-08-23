extends Sprite2D

const MAX_MOVEMENT_PER_SECOND := 72.
const ACCELERATION := 192.

const FOREGROUND_ANSWER := 16

var velocity := 0.
var dest_velocity := 0.
var lock_in_tween: Tween = null


func _physics_process(delta: float) -> void:
	if lock_in_tween == null:
		velocity = move_toward(velocity, dest_velocity, ACCELERATION * delta)
		set_region_x(region_rect.position.x + velocity * delta)


func attempt_activation() -> void:
	var current_panel := roundi(region_rect.position.x / 8.) * 8
	if current_panel == FOREGROUND_ANSWER:
		$Switch.confirm_activation()
		$Door.open()
		$Door2.open()


func left_down() -> void:
	dest_velocity = -MAX_MOVEMENT_PER_SECOND
	if lock_in_tween != null:
		lock_in_tween.kill()
		lock_in_tween = null

func right_down() -> void:
	dest_velocity = MAX_MOVEMENT_PER_SECOND
	if lock_in_tween != null:
		lock_in_tween.kill()
		lock_in_tween = null

func button_up() -> void:
	var locks := region_rect.position.x / 8.
	var next_lock := roundf(locks + 0.2 * sign(velocity))
	var lock_pos := next_lock * 8.
	lock_in_tween = create_tween()
	lock_in_tween.tween_method(set_region_x, region_rect.position.x, lock_pos, .2)

	dest_velocity = 0.
	velocity = 0.

func set_region_x(val: float) -> void:
	region_rect.position.x = fposmod(val, texture.get_width())
