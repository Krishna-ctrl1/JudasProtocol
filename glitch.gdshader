shader_type canvas_item;

uniform float shake_power : hint_range(0.0, 0.5) = 0.03;
uniform float color_bleed : hint_range(0.0, 1.0) = 0.5;
uniform bool is_active = false;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	if (is_active) {
		vec2 uv = SCREEN_UV;
		// Shake
		uv.x += sin(TIME * 200.0) * shake_power;
		uv.y += cos(TIME * 150.0) * shake_power;
		
		// RGB Split
		float r = texture(SCREEN_TEXTURE, uv - vec2(color_bleed * 0.05, 0.0)).r;
		float g = texture(SCREEN_TEXTURE, uv).g;
		float b = texture(SCREEN_TEXTURE, uv + vec2(color_bleed * 0.05, 0.0)).b;
		
		COLOR = vec4(r, g, b, 1.0);
	} else {
		COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	}
}