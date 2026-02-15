extends Node

signal next()
signal before_next(this)

@export var text: String

func render() -> TextBoxView:
	var view := TextBoxView.with_text(text)
	view.close_signaled.connect(func(): on_view_close_signaled(view))
	return view

func on_view_close_signaled(view: TextBoxView) -> void:
	view.queue_free()
	if before_next.has_connections():
		before_next.emit(self)
	else:
		next.emit()
