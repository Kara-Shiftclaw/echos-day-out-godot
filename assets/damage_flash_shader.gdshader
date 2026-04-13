shader_type canvas_item;

uniform vec4 black : source_color;
uniform vec4 flash_color : source_color;
instance uniform int strength = 0;

void fragment() {
	if (strength > 0) {
		vec3 comp = abs(COLOR - black).rgb;
		if (comp.r > 0.0001 || comp.g > 0.0001 || comp.b > 0.0001) {
			COLOR.rgb = mix(COLOR.rgb, flash_color.rgb, float(strength) / 2.);
		}
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
