shader_type canvas_item;

// Controls how much the pixels tear apart
uniform float shake_power : hint_range(0.0, 1.0) = 0.0;
// Controls how much the Red/Blue colors split
uniform float color_rate : hint_range(0.0, 1.0) = 0.0;

float random(float seed) {
	return fract(sin(seed) * 43758.5453123);
}

void fragment() {
	// 1. Randomly slice rows of pixels
	float enable_shift = float(random(floor(UV.y * 40.0) + TIME) < shake_power);
	vec2 fixed_uv = UV;
	fixed_uv.x += (random(floor(UV.y * 40.0) + TIME) - 0.5) * shake_power * enable_shift * 0.1;

	// 2. Split RGB Channels (Chromatic Aberration)
	float r = texture(TEXTURE, fixed_uv + vec2(color_rate * 0.02, 0.0)).r;
	float g = texture(TEXTURE, fixed_uv).g;
	float b = texture(TEXTURE, fixed_uv - vec2(color_rate * 0.02, 0.0)).b;
	float a = texture(TEXTURE, fixed_uv).a;

	// 3. Output the glitch
	COLOR = vec4(r, g, b, a);
}