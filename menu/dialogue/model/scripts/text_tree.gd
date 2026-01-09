extends Node

signal next()

func _ready() -> void:
	var child_count := get_child_count()
	for i in range(0, child_count - 1):
		var child = get_child(i)
		child.next.connect(func(): render_child(i + 1))
	get_child(child_count - 1).next.connect(func(): next.emit())

func render() -> void:
	render_child(0)

func render_child(idx: int) -> void:
	var text_box: TextBoxView = get_child(idx).render()
	Global.camera.add_child(text_box)
