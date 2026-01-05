extends Panel

const Weight := Global.Weight
const WEIGHT_NAMES := {
	Weight.Thin: "Thin",
	Weight.Fat: "Fat",
	Weight.Obese: "Obese",
	Weight.MorObese: "VERY Obese",
	Weight.Blob: "FATASS",
}
const WEIGHT_FORMAT := "Weight:\n{0}"
const FOOD_FORMAT := "{0} ({1}/8)"
const HEALTH_UP_FORMAT := "{0}/10"
const NO_ABILITY_TEXT := "???"

func _ready() -> void:
	$Sprite2D.frame = Global.weight as int
	$OtherStatuses/Weight.text = WEIGHT_FORMAT.format([WEIGHT_NAMES[Global.weight]])
	
	maybe_disable($MajorUpgrades/Fireball, Global.has_fireball) 
	maybe_disable($MajorUpgrades/DoubleJump, Global.has_double_jump)
	maybe_disable($MajorUpgrades/Sprint, Global.has_sprint)
	maybe_disable($MajorUpgrades/Crush, Global.has_crush)
	
	$OtherStatuses/FoodIndicator/Label.text = FOOD_FORMAT.format([Global.flags.get("food_on_hand", 0), Global.flags.get("food_collected", 0)])
	$OtherStatuses/HealthUpIndicator/Label.text = HEALTH_UP_FORMAT.format([Global.flags.get("health_up_collected", 0)])

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		$MajorUpgrades/Fireball.find_valid_focus_neighbor(SIDE_TOP).call_deferred("grab_focus")

static func maybe_disable(button: Button, has_ability: bool):
	button.disabled = !has_ability
	if !has_ability:
		button.text = NO_ABILITY_TEXT
