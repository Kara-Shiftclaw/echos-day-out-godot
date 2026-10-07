extends AbstractTextScript

const UPGRADE_TEXTBOX_PATH := "res://menu/dialogue/view/textengine_upgrade.tscn"
const ICON_SIZE := 40.

@export var choose_icon_by_weight := true
@export var text_translation := "ANTI_SOFTLOCK"
@export var icon_texture: Texture

func script() -> void:
	var wrapper := load_textbox(UPGRADE_TEXTBOX_PATH)
	wrapper.textbox.icon_texture = icon_texture
	if choose_icon_by_weight:
		wrapper.textbox.region = Rect2(ICON_SIZE * Global.weight as int, 0, ICON_SIZE, ICON_SIZE)
	
	await wrapper.txt(self, text_translation)
