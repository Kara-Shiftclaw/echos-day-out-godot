extends VBoxContainer

@export var map_tab_icon: Texture2D
@export var stat_tab_icon: Texture2D
@export var jnl_tab_icon: Texture2D
@export var opt_tab_icon: Texture2D
@export var acc_tab_icon: Texture2D

func _ready() -> void:
	Global.music_player.volume_linear = 0.7
	
	if !Global.flags.has("has_journal"):
		$IconTabs/Journal.queue_free()
	
	$IconTabs/Map.button_pressed = true

func _input(event: InputEvent) -> void:
	if event.is_action("pause") and event.is_pressed():
		unpause()

func unpause() -> void:
	queue_free()
	Global.call_deferred("unpause")
	Global.music_player.volume_linear = 1.

func save_options() -> void:
	Options.save()
	Global.recalculate_weight()
	Global.recalculate_max_hp()
