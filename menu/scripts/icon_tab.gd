class_name IconTab
extends Button

@export var selected_icon: Texture2D
@export var show_when_selected: CanvasItem
var unselected_icon: Texture2D

func _ready() -> void:
	unselected_icon = icon

func on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if show_when_selected != null:
			show_when_selected.show()
		if selected_icon != null:
			icon = selected_icon
		for icon_tabs: IconTab in get_tree().get_nodes_in_group("IconTabs"):
			if icon_tabs != self and icon_tabs.button_pressed:
				icon_tabs.unselect()
	else:
		button_pressed = true

func unselect() -> void:
	set_pressed_no_signal(false)
	icon = unselected_icon
	if show_when_selected != null:
		show_when_selected.hide()

func on_focus_entered() -> void:
	z_index = 1

func on_focus_exited() -> void:
	z_index = 0

static func get_current() -> IconTab:
	for icon_tab: IconTab in Global.get_tree().get_nodes_in_group("IconTabs"):
		if icon_tab.button_pressed:
			return icon_tab
	return null
