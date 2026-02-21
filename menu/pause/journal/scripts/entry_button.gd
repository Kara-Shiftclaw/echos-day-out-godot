extends Button

@export_file_path("*.tscn") var entry_path

func load_page() -> CanvasItem:
	return load(entry_path).instantiate()
