extends Node

signal next()
signal before_next(this)

@export_multiline var text: String
@export var move_always := false

func render() -> TextBoxView:
	var view := TextBoxView.with_text(text)
	view.move_always = move_always
	view.close_signaled.connect(func(): on_view_close_signaled(view))
	return view

func on_view_close_signaled(view: TextBoxView) -> void:
	view.queue_free()
	if before_next.has_connections():
		before_next.emit(self)
	else:
		next.emit()

func emit_next() -> void:
	next.emit()
