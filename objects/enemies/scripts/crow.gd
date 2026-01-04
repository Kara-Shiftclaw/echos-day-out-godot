extends Node2D

const Arrow := preload("res://objects/enemies/arrow.tscn")

class Interrupt:
	extends RefCounted
	
	func _init(anim_player: AnimationPlayer, sprite: Sprite2D) -> void:
		anim = anim_player.current_animation
		anim_pos = anim_player.current_animation_position
		sprite_frame = sprite.frame
	
	func restore(anim_player: AnimationPlayer, sprite: Sprite2D) -> void:
		anim_player.play(anim)
		anim_player.seek(anim_pos)
		sprite.frame = sprite_frame
	
	var anim: String
	var anim_pos: float
	var sprite_frame: int

@export var facing_right := false:
	set(value):
		facing_right = value
		if is_node_ready():
			sync_facing_right()
var interrupt: Interrupt = null

func _ready() -> void:
	sync_facing_right()

func sync_facing_right() -> void:
	$Crow.flip_h = facing_right

func start_fire_arrow() -> void:
	$AnimationPlayer.play("fire_arrow")

func fire_arrow() -> void:
	var arrow := Arrow.instantiate()
	arrow.moving_right = facing_right
	get_parent().add_child(arrow)
	arrow.global_position = global_position

func decision_point() -> void:
	if $EnemyManager.health > 0:
		if $PlayerDetectArea.get_overlapping_bodies().size() > 0:
			$AnimationPlayer.play("knife_attack")
			if interrupt != null:
				$AnimationPlayer.seek(0., true)
				interrupt = Interrupt.new($AnimationPlayer, $Crow)
		else:
			$AnimationPlayer.play("shoot_delay")

func reload() -> void:
	if $EnemyManager.health > 0:
		$AnimationPlayer.play("initial_shoot_delay")
		$AnimationPlayer.seek(0.)

func die() -> void:
	$AnimationPlayer.play("die")
	$EnemyDieSound.play()

func hit() -> void:
	if interrupt == null:
		interrupt = Interrupt.new($AnimationPlayer, $Crow)
	$AnimationPlayer.play("hit")

func pop_interrupt() -> void:
	if interrupt != null:
		interrupt.restore($AnimationPlayer, $Crow)
		interrupt = null
	else:
		push_warning("Attempt to restore Crow from interrupt without interrupt set")

func reset_knife() -> void:
	$KnifeArea/CollisionShape2D.set_deferred("disabled", true)
