shader_type canvas_item;
render_mode unshaded;

uniform float circle_size : hint_range(0.0,  1.145);
uniform vec2 center;
uniform float screen_width;
uniform float screen_height;

void fragment() {
	float ratio = screen_width / screen_height;
	float dist = distance(vec2(center.x * ratio, center.y), vec2(UV.x * ratio, UV.y));
	COLOR.a = step(circle_size, dist);
}