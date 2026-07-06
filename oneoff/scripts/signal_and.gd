extends Node

signal both_true()

var a := false
var b := false

func set_a() -> void:
	a = true
	if b:
		both_true.emit()

func unset_a() -> void:
	a = false

func set_b() -> void:
	b = true
	if a:
		both_true.emit()

func unset_b() -> void:
	b = false

func unset() -> void:
	a = false
	b = false
