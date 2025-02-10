shader_type canvas_item;

// Custom HSV to RGB conversion function
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    vec2 uv = UV;
    float time = TIME * 0.6;
    
    // Perspective effect (more intense at the bottom)
    float perspective = 1.0 - uv.y;
    
    // Create multiple wave layers
    float wave1 = sin(uv.x * 15.0 + time * 3.0) * 0.03 * perspective;
    float wave2 = cos(uv.x * 12.0 - time * 2.5) * 0.02 * perspective;
    float wave3 = sin(uv.x * 8.0 + time * 4.0) * 0.04 * perspective;
    
    // Combine waves
    float combined_wave = (wave1 + wave2 + wave3) * 2.0;
    float wave_position = 0.5 + combined_wave;
    
    // Calculate distance to wave and intensity
    float dist = abs(uv.y - wave_position);
    float intensity = pow(1.0 - smoothstep(0.0, 0.5 * perspective, dist), 2.0);
    
    // Create color gradients
    float hue = time * 0.1 + uv.y * 0.2 + intensity * 0.3;
    float saturation = 0.7 + intensity * 0.3;
    float value = intensity * 1.2;
    
    // Convert HSV to RGB
    vec3 color = hsv2rgb(vec3(hue, saturation, value));
    
    // Add blue/purple tint
    color = mix(color, vec3(0.4, 0.6, 1.0), 0.8);
    
    // Final color output with alpha
    COLOR = vec4(color, intensity * 1.0);
}