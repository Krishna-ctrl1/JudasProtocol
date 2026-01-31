shader_type canvas_item;

// Sexy Neon Grid Shader
uniform vec4 grid_color : source_color = vec4(1.0, 0.0, 1.0, 0.5); // Neon Pink
uniform float grid_size = 50.0;
uniform float speed = 0.5;

void fragment() {
    vec2 uv = UV * (1.0 / TEXTURE_PIXEL_SIZE); 
    uv.y += TIME * speed * 20.0; // Move it down
    
    // Draw Lines
    bool line_x = mod(uv.x, grid_size) < 1.0;
    bool line_y = mod(uv.y, grid_size) < 1.0;
    
    // Background Color (Deep Dark Blue)
    vec4 bg_color = vec4(0.05, 0.05, 0.1, 1.0);
    
    if (line_x || line_y) {
        COLOR = grid_color; // Draw Grid
    } else {
        COLOR = bg_color; // Draw Background
    }
    
    // Fade out at top (Horizon effect)
    COLOR.a *= UV.y * 1.5; 
}