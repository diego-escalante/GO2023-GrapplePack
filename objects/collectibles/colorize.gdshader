shader_type canvas_item;
render_mode unshaded;

uniform vec3 color : source_color;
uniform float percentage : hint_range(0, 1);

void fragment() {
	vec4 col = COLOR;
	if (COLOR.a != 0.0) {
		COLOR = vec4(mix(COLOR.rgb, color, percentage), 1);
	}
}