extends Node

signal both_true()

var a := false
var b := false

func set_a() -> void:
	a = true
	if b:
		both_true.emit()

func set_b() -> void:
	b = true
	if a:
		both_true.emit()
