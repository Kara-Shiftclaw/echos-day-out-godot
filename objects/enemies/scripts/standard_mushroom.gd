extends StaticBody2D

const SPORE_SPAWN_OFFSET := Vector2(0., -15.)
const NORMAL_SPORE_SPRITE_OFFSET := Vector2(0.5, 0.5)

func spread_left() -> void:
	var left := copy_spore()
	var left_far := copy_spore()
	set_spore_anim(left, "left")
	set_spore_anim(left_far, "left_far")

func spread_right() -> void:
	var right := copy_spore()
	var right_far := copy_spore()
	set_spore_anim(right, "right")
	set_spore_anim(right_far, "right_far")

func copy_spore() -> Node2D:
	var copy: Node2D = $SporeModel.duplicate()
	get_parent().add_child(copy)
	copy.global_position = global_position + SPORE_SPAWN_OFFSET
	copy.process_mode = Node.PROCESS_MODE_INHERIT
	copy.show()
	
	var player: AnimationPlayer = copy.get_node("AnimationPlayer")
	player.animation_finished.connect(func(_anim):
		var sprite_offset: Vector2 = copy.get_node("Sprite2D").offset - NORMAL_SPORE_SPRITE_OFFSET
		copy.position += sprite_offset
		set_spore_anim(copy, "fall")
	, ConnectFlags.CONNECT_ONE_SHOT)
	
	var screen_notifier: VisibleOnScreenNotifier2D = copy.get_node("ScreenNotifier")
	screen_notifier.screen_exited.connect(copy.queue_free)
	
	return copy

func reload() -> void:
	if $EnemyManager.health > 0:
		$AnimationPlayer.play("idle")
		$AnimationPlayer.seek(0., true)

static func set_spore_anim(spore: Node, anim: StringName):
	var player: AnimationPlayer = spore.get_node("AnimationPlayer")
	player.play(anim)
	player.seek(0., true)
