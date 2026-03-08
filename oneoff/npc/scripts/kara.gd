extends Area2D

const InjectorGet := preload("res://menu/dialogue/small_upgrade/injector_get.tscn")
const InjectorXlGet := preload("res://menu/dialogue/small_upgrade/injector_xl_get.tscn")

const HAS_INJECTOR_FLAG := "has_injector"
const RESIZE_INJECTOR_FLAG := "resize_injector"
const CHAT_FLAG := "kara_chat"

var echo_inside := false

func entered(other: Node2D):
	if other is Echo:
		$UpArrow.show()
		echo_inside = true

func exited(other: Node2D):
	if other is Echo:
		$UpArrow.hide()
		echo_inside = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up", false) and echo_inside and Global.echo.is_on_floor():
		get_tree().paused = true
		if !Global.flags.has(HAS_INJECTOR_FLAG):
			Global.flags[HAS_INJECTOR_FLAG] = true
			$Text/PortalGet.render()
		elif Global.weight == Global.Weight.Blob and !Global.flags.has(RESIZE_INJECTOR_FLAG):
			Global.flags[RESIZE_INJECTOR_FLAG] = true
			$Text/ResizePortal.render()
		else:
			var cur_chat: int = Global.flags.get_or_add(CHAT_FLAG, 0)
			match cur_chat:
				0:
					$Text/Chat.render()
				1:
					$Text/Chat2.render()
				2:
					$Text/Chat3.render()
				3:
					$Text/Chat4.render()
				4:
					$Text/Chat5.render()
				_:
					push_error("Kara chat ran out!")
					Global.flags[CHAT_FLAG] = 1
					$Text/Chat.render()

func unpause() -> void:
	get_tree().paused = false

func update_chat() -> void:
	var next_chat: int = Global.flags[CHAT_FLAG] + 1
	if Global.weight == Global.Weight.Blob:
		Global.flags[CHAT_FLAG] = next_chat % 5
	else:
		Global.flags[CHAT_FLAG] = next_chat % 4
	unpause()

func injector_get_popup(text_model: Node) -> void:
	var popup: TextBoxView = InjectorGet.instantiate()
	Global.camera.add_child(popup)
	popup.close_signaled.connect(text_model.emit_next)

func injector_xl_get_popup(text_model: Node) -> void:
	var popup: TextBoxView = InjectorXlGet.instantiate()
	Global.camera.add_child(popup)
	popup.close_signaled.connect(text_model.emit_next)
