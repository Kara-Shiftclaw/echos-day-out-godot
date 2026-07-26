class_name SaveGameHUD
extends Button

const SCENE := preload("res://menu/save_game.tscn")
const NEW_GAME_SCENE := preload("res://menu/new_game.tscn")
const LOCATION_FROM_SAVED_STAGE := {
	"res://stages/intro_mountain.tscn": Location.MtEcho,
	"res://stages/heftwind_hills.tscn": Location.HeftwindHills,
	"res://stages/charred_cavern.tscn": Location.CharredCavern,
	"res://stages/sporeways.tscn": Location.Sporeways,
	"res://stages/verdant_cavern.tscn": Location.VerdantCavern,
	"res://stages/pyrite_plunge.tscn": Location.PyritePlunge,
	"res://stages/creaking_depths.tscn": Location.DisphoticDepths,
	"res://stages/treetop_expanse.tscn": Location.TreetopExpanse,
	"res://stages/thieves_road.tscn": Location.ThievesRoad,
	"res://stages/billowing_heights.tscn": Location.BillowingHeights,
	"res://stages/crater.tscn": Location.Crater,
	"res://stages/bramble.tscn": Location.Bramble,
}
const FRAME_FROM_WEIGHT := {
	0: 0,
	1: 12,
	2: 14,
	3: 15,
	4: 16,
	5: 17,
}

enum Location {
	MtEcho,
	HeftwindHills,
	CharredCavern,
	Sporeways,
	VerdantCavern,
	PyritePlunge,
	DisphoticDepths,
	TreetopExpanse,
	ThievesRoad,
	BillowingHeights,
	Crater,
	Bramble,
}

var location: Location
var weight: int
var main_percentage: String
var completion_percentage: String
var file_num: int

static func load_from_save(save_dict: Dictionary, load_id: int) -> SaveGameHUD:
	var save_game: SaveGameHUD = SCENE.instantiate()
	
	save_game.location = LOCATION_FROM_SAVED_STAGE[save_dict["stage"]]
	save_game.main_percentage = save_dict.get("main_completion", "??")
	save_game.completion_percentage = save_dict.get("completion", "??")
	save_game.file_num = load_id
	save_game.calculate_weight(save_dict)
	
	return save_game

static func new_game() -> Button:
	return NEW_GAME_SCENE.instantiate() as Button

func _ready() -> void:
	$Profile/Background.frame = location as int
	$Profile/Echo.frame = FRAME_FROM_WEIGHT[weight]
	$MainPercentage.text = "{0}%".format([main_percentage])
	$CompletionPercentage.text = "{0}%".format([completion_percentage])
	$File.text = "File " + str(file_num)

func calculate_weight(save_dict: Dictionary) -> void:
	if save_dict.get("is_smol", false):
		weight = 5
	
	weight = (1 if save_dict.get("fireball", false) else 0) \
			+ (1 if save_dict.get("double_jump", false) else 0) \
			+ (1 if save_dict.get("sprint", false) else 0) \
			+ (1 if save_dict.get("crush", false) else 0)
