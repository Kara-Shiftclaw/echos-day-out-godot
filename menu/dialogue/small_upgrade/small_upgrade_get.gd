extends TextBoxView

func _ready() -> void:
	super._ready()
	$Sprite2D.frame = Global.weight as int
	$Label.text = tr($Label.text)
