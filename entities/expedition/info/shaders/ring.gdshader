shader_type canvas_item;

uniform int num_colors: hint_range(1, 9, 1) = 1;
uniform vec4 colors[9] : source_color;
uniform float shares[8];  // The last color gets the remainder
uniform float relative_size : hint_range(0.0, 1.0, 0.1) = 1.;
uniform float blur_strength : hint_range(0., .1, .005) = .00;

void fragment() {
	float angle = (atan(.5-UV.y, UV.x-.5) + PI)/(2.*PI);
	float r = length(UV-vec2(.5));
	float tot_shares = 0.;
	
	COLOR = mix(colors[num_colors - 1],colors[0], smoothstep(blur_strength, .0, 1. - angle));
	for (int i = 0; i < num_colors-1; i++) {
		tot_shares += shares[i];
		if (angle  < tot_shares) {
			COLOR = mix(colors[i],colors[i+1], smoothstep(blur_strength, .0, abs(angle-tot_shares)));
			break;
		}
	}
	COLOR.a = min(COLOR.a, smoothstep(0, blur_strength*2., relative_size*.5 - r));
}
