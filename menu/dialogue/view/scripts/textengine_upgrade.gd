extends TextBox

const NULL_REGION := Rect2(Vector2.INF, Vector2.INF)

@export var icon_texture: Texture:
	get():
		if is_node_ready():
			return $Sprite2D.texture
		return null
	set(value):
		if is_node_ready():
			$Sprite2D.texture = value
		else:
			self.set_deferred("icon_texture", value)
@export var region: Rect2 = NULL_REGION:
	set(value):
		region = value
		if is_node_ready():
			if value == NULL_REGION:
				$Sprite2D.region_enabled = false
			else:
				$Sprite2D.region_enabled = true
				$Sprite2D.region_rect = value
