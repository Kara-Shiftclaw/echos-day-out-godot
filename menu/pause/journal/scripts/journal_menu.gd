extends Panel

const EntryButton := preload("res://menu/pause/journal/entry_button.tscn")

const ENTRY_FORMAT := "res://menu/pause/journal/entry/{0}.tscn"
const ENTRY_NOT_OPEN := ""

enum Entry {
	journalist,
	artifact,
	scare_dragon,
	hedgehog,
	wolf,
	crow,
	fatbat,
	spike_hedgehog,
	small_lizard,
	big_lizard,
	mongoose,
	lil_mushroom,
	standard_mushroom,
	spider,
	hugehog,
}

var menu_node: VBoxContainer
var cur_entry := ENTRY_NOT_OPEN

func get_entry_name(entry: Entry) -> String:
	match entry:
		Entry.journalist:
			return "Maxwell Flinthelm II"
		Entry.artifact:
			return "Artifact of Echo"
		Entry.scare_dragon:
			return "Scaredrake"
		Entry.hedgehog:
			return "Hedgehog"
		Entry.wolf:
			return "Hefthire Wolf"
		Entry.crow:
			return "Corvid Pawn"
		Entry.fatbat:
			return "Fat Bat"
		Entry.spike_hedgehog:
			return "Spike-hog"
		Entry.small_lizard:
			return "Geckito"
		Entry.big_lizard:
			return "Geckordo"
		Entry.mongoose:
			return "- Edgar -"
		Entry.lil_mushroom:
			return "Sporeling"
		Entry.standard_mushroom:
			return "Sporecap"
		Entry.spider:
			return "Spider"
		Entry.hugehog:
			return "Huge-hog"
	return "UNKNOWN"

func _ready() -> void:
	menu_node = $Menu/VBoxContainer
	setup_buttons()

func setup_buttons() -> void:
	for code_name in Entry:
		if Global.journal_entries.has(code_name):
			var entry_name := get_entry_name(Entry[code_name])
			var entry_button: Button = EntryButton.instantiate()
			entry_button.text = entry_name
			entry_button.pressed.connect(func(): load_from_button(code_name))
			menu_node.add_child(entry_button)
			entry_button.name = code_name

func _input(event: InputEvent) -> void:
	if cur_entry != ENTRY_NOT_OPEN:
		if event.is_action_pressed("ui_cancel"):
			clear_entry_container()
			$Menu.show()
			menu_node.get_node(cur_entry).grab_focus.call_deferred()
			cur_entry = ENTRY_NOT_OPEN
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down"):
			next_page()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up"):
			prev_page()
			get_viewport().set_input_as_handled()

func prev_page() -> void:
	var cur_entry_button := menu_node.get_node(cur_entry)
	if cur_entry_button.get_index() != 0:
		var prev := menu_node.get_child(cur_entry_button.get_index() - 1)
		load_from_button(prev.name)

func next_page() -> void:
	var cur_entry_button := menu_node.get_node(cur_entry)
	if cur_entry_button.get_index() != menu_node.get_child_count() - 1:
		var next := menu_node.get_child(cur_entry_button.get_index() + 1)
		load_from_button(next.name)

func clear_entry_container() -> void:
	for child in $EntryContainer.get_children():
		child.queue_free()

func load_from_button(code_name: String) -> void:
	clear_entry_container()
	var path := ENTRY_FORMAT.format([code_name])
	var entry := load(path).instantiate() as Control
	cur_entry = code_name
	$EntryContainer.add_child(entry)
	$Menu.hide()
