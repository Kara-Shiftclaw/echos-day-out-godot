shader_type canvas_item;

uniform float strength = 0.;
uniform float speed = 3.;

void vertex() {
	VERTEX.y += strength * sin(VERTEX.y + speed * TIME);
}
