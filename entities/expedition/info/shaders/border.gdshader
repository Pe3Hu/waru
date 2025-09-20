shader_type canvas_item;

uniform float density: hint_range(4.0, 25.0) = 7.5;


void fragment() {
	float dist = distance(UV, vec2(0.5,0.5));
	float x = (UV.x-.5);
	float y = (UV.y-.5);
	float v = (sqrt((x*x)+(y*y)) * density);
	float can_color = mod(v, 1.25);
	vec4 color;
	if (can_color > 1.0) {
		color.a = 1.0;
	}else{
		color.a = 0.0;
	}
	if (dist > 0.5) {
		color.a = 0.0;
	}
	COLOR = vec4(color.rgba);
}