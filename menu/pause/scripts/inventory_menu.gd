class_name InventoryMenu
extends Control

const Metadata := preload("res://menu/pause/scripts/inventory_item.gd").Metadata
const InventoryItem := preload("res://menu/pause/inventory_item.tscn")
const FOOD := "Food"
const PORTAL_CORE := "Portal Core"
const ARTIFACT := "Artifact"
const PYRITE := "Pyrite"
const MUSH := "Mycelium Map"
const INJECTOR := "Portal Injector"

var used_portal_core := Metadata.new("", "Portal Core Scraps", "BROKEN_CORE", 19)
var mush_meal := Metadata.new("has_mush_meal", "Mush-Meal", "MUSH_MEAL", 11)
var mush_in_meal := Metadata.new("", "Mush-Meal (Occupied)", "MUSH_IN_MEAL", 12)
var max_pyrite := Metadata.new("", "Excessive Pyrite", "MAX_PYRITE", 14)
static var all_items_metadata: Array[Metadata] = [
	Metadata.new("res://stages/heftwind_hills.tscn|/root/HeftwindHills/Objects/Food|collected", FOOD, "FOOD_1", 0),
	Metadata.new("res://stages/verdant_cavern.tscn|/root/VerdantCavern/Objects/Food|collected", FOOD, "FOOD_3", 0),
	Metadata.new("res://stages/creaking_depths.tscn|/root/CreakingDepths/Objects/Food|collected", FOOD, "FOOD_4", 0),
	Metadata.new("res://stages/treetop_expanse.tscn|/root/TreetopExpanse/Objects/Food|collected", FOOD, "FOOD_5", 0),
	Metadata.new("res://res://stages/echo_peak.tscn|/root/EchoPeak/Objects/Food|collected", FOOD, "FOOD_7", 0),
	Metadata.new("res://res://stages/billowing_heights.tscn|/root/BillowingHeights/Objects/Food|collected", FOOD, "FOOD_8", 0),
	Metadata.new("res://stages/charred_cavern.tscn|/root/CharredCavern/Objects/Food|collected", FOOD, "FOOD_2", 0), # Actually blocked until Crush
	Metadata.new("res://res://stages/bramble.tscn|/root/Bramble/Objects/Food|collected", FOOD, "FOOD_6", 0), # Bramble, so last
	Metadata.new("res://stages/heftwind_hills.tscn|/root/HeftwindHills/HealthUp|collected", "Draconic Energy", "ENERGY_1", 2),
	Metadata.new("res://stages/sporeways.tscn|/root/Sporeways/Objects/HealthUp|collected", "Draconic Energy", "ENERGY_2", 2),
	Metadata.new("res://stages/creaking_depths.tscn|/root/CreakingDepths/Objects/HealthUp|collected", "Draconic Energy", "ENERGY_3", 2),
	Metadata.new("res://stages/verdant_cavern.tscn|/root/VerdantCavern/Objects/HealthUp|collected", "Draconic Energy", "ENERGY_6", 2), # Was moved earlier
	Metadata.new("res://stages/treetop_expanse.tscn|/root/TreetopExpanse/Objects/HealthUp|collected", "Draconic Energy", "ENERGY_4", 2),
	Metadata.new("res://stages/echo_peak.tscn|/root/EchoPeak/Objects/HealthUp|collected", "Draconic Energy", "ENERGY_5", 2),
	Metadata.new("res://stages/heftwind_hills.tscn|/root/HeftwindHills/Objects/PortalCore|collected", PORTAL_CORE, "CORE_1", 3),
	Metadata.new("res://stages/sporeways.tscn|/root/Sporeways/Objects/PortalCore|collected", PORTAL_CORE, "CORE_3", 3),
	Metadata.new("res://stages/charred_cavern.tscn|/root/CharredCavern/Objects/PortalCore|collected", PORTAL_CORE, "CORE_4", 3),
	Metadata.new("res://stages/treetop_expanse.tscn|/root/TreetopExpanse/Objects/PortalCore|collected", PORTAL_CORE, "CORE_5", 3),
	Metadata.new("res://stages/billowing_heights.tscn|/root/BillowingHeights/Objects/PortalCore|collected", PORTAL_CORE, "CORE_6", 3),
	Metadata.new("res://stages/crater.tscn|/root/Crater/Objects/PortalCore|collected", PORTAL_CORE, "CORE_2", 3), # Moved way later
	Metadata.new("", ARTIFACT, "ARTIFACT", 4),
	Metadata.new("has_journal", "\"Faces of the Valley\"", "JOURNAL_1", 5),
	Metadata.new("has_echo_journal_1", "Echo's Journal", "JOURNAL_2", 6),
	Metadata.new("has_echo_journal_2", "------'s Journal", "JOURNAL_3", 7),
	Metadata.new(Echo.SWORD_BLADE_FLAG, "Legendary Sword Blade", "SWORD_BLADE", 8),
	Metadata.new(Echo.SWORD_HILT_FLAG, "Legendary Sword Hilt", "SWORD_HILT", 9),
	Metadata.new("", MUSH, "MUSH", 10),
	Metadata.new("pyrite", PYRITE, "PYRITE", 13),
	Metadata.new("has_poison", "Poisoned Soup", "POISON", 15),
	Metadata.new("has_crushed_claw", "Crushed Claw", "CRUSHED_CLAW", 16),
	Metadata.new("has_injector", INJECTOR, "INJECTOR", 17),
	Metadata.new("resize_injector", "Portal Injector XL", "INJECTOR_XL", 18),
]
static var foods: Array[Metadata] = all_items_metadata.slice(0, 8)
static var portal_cores: Array[Metadata] = all_items_metadata.slice(14, 20)
var held_items: Array[Button] = []
@export var descriptions: Translation

func _ready() -> void:
	for item in all_items_metadata:
		maybe_add_item(item)
	
	var num_held_items := held_items.size()
	for row_i in range(0, ceili(num_held_items / 8.)):
		var row_item_start := row_i * 8
		var row_item_end := row_item_start + 8
		var row := $VBoxContainer/Panel/Rows.get_child(row_i)
		var true_end := mini(row_item_end, num_held_items)
		for item_i in range(row_item_start, true_end):
			row.add_child(held_items.get(item_i))

func maybe_add_item(metadata: Metadata) -> void:
	var maybe_flag = Global.flags.get(metadata.flag)
	if metadata.flag != "" and maybe_flag != null and (typeof(maybe_flag) != TYPE_BOOL or maybe_flag):
		if metadata.title == PYRITE and roundi(maybe_flag) == 500:
			add_item(max_pyrite)
			return
		if metadata.title == INJECTOR and Global.flags.get("resize_injector", false):
			return
		if metadata.title == FOOD and Global.flags.has(used_flag(metadata)):
			var eaten_metadata := Metadata.new(metadata.flag, metadata.title, metadata.description_translation, 1)
			add_item(eaten_metadata)
			return
		elif metadata.title == PORTAL_CORE and Global.flags.has(used_flag(metadata)):
			add_item(used_portal_core)
			return

		add_item(metadata)
	
	if metadata.title == ARTIFACT:
		add_item(metadata)
	if metadata.title == MUSH:
		if Global.flags.get(Global.MYCELIUM_MAP_FLAG, false):
			if Global.flags.get("has_mush_meal", false):
				add_item(mush_in_meal)
			else:
				add_item(metadata)
		elif Global.flags.get("has_mush_meal", false):
			add_item(mush_meal)

func add_item(metadata: Metadata) -> void:
	var item: Button = InventoryItem.instantiate()
	item.metadata = metadata
	item.focus_entered.connect(func():
		describe_item(metadata)
	)
	held_items.append(item)

func describe_item(metadata: Metadata) -> void:
	$VBoxContainer/ItemName.text = metadata.title
	if metadata.title == PYRITE:
		$VBoxContainer/Description.text = descriptions.get_message(metadata.description_translation) % (Global.flags.get("pyrite", 0) as int)
	else:
		$VBoxContainer/Description.text = descriptions.get_message(metadata.description_translation)

static func get_unused_food() -> Metadata:
	return get_unused_item(foods)

static func get_unused_portal_core() -> Metadata:
	return get_unused_item(portal_cores)

static func get_unused_item(item_set: Array[Metadata]) -> Metadata:
	for item in item_set:
		if !Global.flags.has(used_flag(item)):
			var maybe_flag = Global.flags.get(item.flag)
			if maybe_flag != null and (typeof(maybe_flag) != TYPE_BOOL or maybe_flag):
				return item
	return null

static func used_flag(metadata: Metadata) -> String:
	return metadata.description_translation + "_USED"
