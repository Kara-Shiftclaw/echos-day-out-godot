extends CharacterBody2D

const SPEED := 18. * 8.

@export var fire_angle: float

func _ready() -> void:
	var anim_angle := roundi(fire_angle * 4. / PI) % 8
	
	if anim_angle % 2 != 0:
		$AnimationPlayer.play("diagonal")
		if anim_angle < 4:
			$RFSprite2D.flip_v = true
		if anim_angle == 3 or anim_angle == 5:
			$RFSprite2D.flip_h = true
	else:
		$AnimationPlayer.play("non_diagonal")
		match anim_angle:
			2:
				$RFSprite2D.rotation = -PI / 2.
			4:
				$RFSprite2D.flip_h = true
			6:
				$RFSprite2D.rotation = PI / 2.

func _physics_process(delta: float) -> void:
	velocity = SPEED * Vector2.from_angle(fire_angle)
	var collision := move_and_collide(velocity * delta)
	if collision != null:
		queue_free()
