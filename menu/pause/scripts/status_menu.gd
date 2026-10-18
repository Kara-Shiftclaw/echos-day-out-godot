extends Control

const Weight := Global.Weight
const WEIGHT_NAMES := {
	Weight.Thin: "STATUS_WEIGHT_THIN",
	Weight.Fat: "STATUS_WEIGHT_FAT",
	Weight.Obese: "STATUS_WEIGHT_OBESE",
	Weight.MorObese: "STATUS_WEIGHT_MOROBESE",
	Weight.Blob: "STATUS_WEIGHT_BLOB",
}
const SMOL_NAME := "STATUS_WEIGHT_SMOL"
const NO_ABILITY_TEXT := "???"

@onready var description: Label = $OtherStatuses/PauseScroll/VBoxContainer/Description
@onready var flavor_text: Label = $OtherStatuses/PauseScroll/VBoxContainer/FlavorText

func _ready() -> void:
	if Global.is_smol:
		$Sprite2D.frame = 5
		$OtherStatuses/Weight.text = tr("STATUS_WEIGHT") + tr("STATUS_WEIGHT_SMOL")
		$MajorUpgrades/Fireball.text = "SMOL_UP_BONK_CAPS"
		$MajorUpgrades/DoubleJump.text = "SMOL_UP_HIGH_JUMP_CAPS"
		$MajorUpgrades/Sprint.text = "UPGRADE_SPRINT_CAPS"
		$MajorUpgrades/Crush.text = "SMOL_UP_SQUEEZE_CAPS"
	else:
		$Sprite2D.frame = Global.weight as int
		$OtherStatuses/Weight.text = tr("STATUS_WEIGHT") + tr(WEIGHT_NAMES[Global.weight])
	
		maybe_disable($MajorUpgrades/Fireball, Global.has_fireball) 
		maybe_disable($MajorUpgrades/DoubleJump, Global.has_double_jump)
		maybe_disable($MajorUpgrades/Sprint, Global.has_sprint)
		maybe_disable($MajorUpgrades/Crush, Global.has_crush)
	
	#$OtherStatuses/FoodIndicator/Label.text = FOOD_FORMAT.format([Global.flags.get("food_on_hand", 0) as int, Global.flags.get("food_collected", 0) as int])
	#$OtherStatuses/HealthUpIndicator/Label.text = HEALTH_UP_FORMAT.format([Global.flags.get("health_up_collected", 0) as int])
	#$OtherStatuses/PortalCoreIndicator/Label.text = PORTAL_CORE_FORMAT.format([Global.flags.get("core_on_hand", 0) as int, Global.flags.get("core_collected", 0) as int])
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		$MajorUpgrades/Fireball.find_valid_focus_neighbor(SIDE_TOP).call_deferred("grab_focus")

func set_description(upgrade: Button) -> void:
	if upgrade.disabled:
		description.text = "UPGRADE_DESC_NOT_FOUND"
		flavor_text.text = ""
	elif Global.is_smol:
		description.text = upgrade.smol_description
		flavor_text.text = upgrade.smol_flavor
	else:
		description.text = upgrade.description
		flavor_text.text = upgrade.flavor
	$OtherStatuses/PauseScroll.reset()

static func maybe_disable(button: Button, has_ability: bool):
	button.disabled = !has_ability
	if !has_ability:
		button.text = NO_ABILITY_TEXT
