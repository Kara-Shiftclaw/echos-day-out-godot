class_name Upgrade
extends Area2D

const FIREBALL_POPUP_PATH := "res://menu/dialogue/major_upgrade/fireball.tscn"
const DOUBLE_JUMP_POPUP_PATH := "res://menu/dialogue/major_upgrade/double_jump.tscn"
const SCENE := preload("res://objects/echo/upgrade.tscn")

var grant_fireball := false
var grant_double_jump := false
var grant_sprint := false
var grant_crush := false

signal collected()

static func instantiate() -> Upgrade:
	return SCENE.instantiate()

func move_from_to(global_from: Vector2, global_to: Vector2) -> void:
	global_position = global_from
	var move_tween := create_tween()
	move_tween.tween_property(self, "global_position", global_to, 1.0).set_ease(Tween.EASE_IN)
	move_tween.tween_callback(enable)

func enable() -> void:
	$CollisionShape2D.set_deferred("disabled", false)

func on_entered(other: Node2D) -> void:
	if other is Player:
		var echo: Player = other
		echo.hide()
		echo.can_move = false
		
		$EchoGain.global_position = echo.global_position
		$EchoGain.flip_h = !echo.facing_right
		match Global.weight:
			Global.Weight.Thin:
				$EchoGain.frame = 0
			Global.Weight.Fat:
				$EchoGain.frame = 2
			Global.Weight.Obese:
				$EchoGain.frame = 4
			Global.Weight.MorObese:
				$EchoGain.frame = 6
			Global.Weight.Blob:
				$EchoGain.frame = 6
		
		var echo_move_tween := create_tween()
		echo_move_tween.tween_property($EchoGain, "global_position", global_position, 0.1)
		
		$AnimationPlayer.play("grant")
		$CollisionShape2D.set_deferred("disabled", true)

func begin_gain() -> void:
	match Global.weight:
		Global.Weight.Thin:
			$AnimationPlayer.play("gain_1")
		Global.Weight.Fat:
			$AnimationPlayer.play("gain_2")
		Global.Weight.Obese:
			$AnimationPlayer.play("gain_3")
		Global.Weight.MorObese:
			$AnimationPlayer.play("gain_4")
		Global.Weight.Blob:
			$AnimationPlayer.play("gain_4")
	
	Global.grant_abilities(grant_fireball, grant_double_jump, grant_sprint, grant_crush)
	Global.echo.play_anim("idle", 99)
	Global.echo.anim_priority = 1

func spawn_energy_orbs(amt: int):
	EnergyOrb.create_n(amt, global_position, $EchoGain/EnergyOrbCollector)

func conclude() -> void:
	Global.echo.show()
	Global.echo.global_position = global_position
	Global.echo.play_anim("jump", 1)
	Global.echo.velocity = Vector2(0., Echo.STAGE_HAZARD_BOUNCE)
	Global.echo.land_on_floor.connect(upgrade_popup, ConnectFlags.CONNECT_ONE_SHOT)
	Global.echo.can_move = true
	EnergyOrb.create_n(6, global_position, Global.echo)
	
	hide()

func upgrade_popup() -> void:
	get_tree().paused = true
	
	var popup_path := FIREBALL_POPUP_PATH
	if grant_double_jump:
		popup_path = DOUBLE_JUMP_POPUP_PATH
	
	var upgrade_get_popup: TextBoxView = load(popup_path).instantiate()
	Global.camera.add_child(upgrade_get_popup)
	upgrade_get_popup.close_signaled.connect(Global.unpause)
	collected.emit()
	queue_free()
