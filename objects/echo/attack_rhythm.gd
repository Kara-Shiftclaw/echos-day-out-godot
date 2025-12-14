class_name AttackRhythm
extends Node

const SCENE := preload("res://objects/echo/attack_rhythm.tscn")

static func instantiate(edit_state := 0) -> AttackRhythm:
	return SCENE.instantiate(edit_state)

var valid := false
var crit_dash := false

func validate():
	valid = true

func check_validation():
	print("Checking validation")
	if valid:
		$EarlyBound.start()
		$LateBound.start()
		$CritSound.play()
	else:
		queue_free()

func in_rhythm():
	return $EarlyBound.is_stopped() and not $LateBound.is_stopped()
