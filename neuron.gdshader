shader_type canvas_item;

// Base properties
uniform vec4 border_color : source_color = vec4(0.9, 0.4, 0.1, 1.0);
uniform float border_width : hint_range(0, 0.5) = 0.05;
uniform float edge_sharpness : hint_range(1, 10) = 3.0;

// Glow properties
uniform float glow_intensity : hint_range(0, 5) = 1.5;
uniform float glow_radius : hint_range(0, 1) = 0.3;
uniform vec3 glow_color = vec3(1.0, 0.6, 0.3);
uniform float glow_falloff : hint_range(0.1, 5) = 2.0;

// Advanced effects
uniform float distortion_strength : hint_range(0, 0.5) = 0.1;
uniform float noise_speed : hint_range(0, 2) = 0.5;

void fragment() {
    vec2 center = vec2(0.5);
    vec2 uv = UV;

    // Add distortion to UVs for organic effect
    vec2 distorted_uv = uv;
    distorted_uv.x += sin(TIME * 2.0 + uv.y * 10.0) * distortion_strength * 0.01;
    distorted_uv.y += cos(TIME * 1.5 + uv.x * 12.0) * distortion_strength * 0.01;

    float distance = length(distorted_uv - center);
    float radius = 0.35;
    float aa = fwidth(distance) * 2.0;

    // Main circle with sharp edge
    float circle = smoothstep(radius + aa, radius - aa, distance);

    // Dark core with tapered edge
    float core_size = radius - border_width;
    float core = smoothstep(core_size + aa, core_size - aa, distance);
    vec3 dark_core = mix(vec3(0.0), vec3(0.1), pow(core, edge_sharpness));

    // Glow effect calculations (starts at circle edge)
    float edge_distance = distance - radius;
    float glow = exp(-glow_falloff * max(edge_distance, -border_width)) * glow_intensity;

    // Create glowing rim
    float rim = smoothstep(-border_width, 0.0, edge_distance);
    rim *= 1.0 - smoothstep(0.0, glow_radius, edge_distance);

    // Combine elements
    vec3 final_color = dark_core;

    // Add border with glowing edge
    float border_mask = smoothstep(core_size - aa, core_size + aa, distance);
    final_color = mix(final_color, border_color.rgb, border_mask);

    // Add glowing effect that bleeds outward
    vec3 glow_effect = glow_color * glow * rim * (1.0 + sin(TIME * 3.0) * 0.2);
    final_color += glow_effect;

    // Alpha handling allows glow to extend beyond circle
    float base_alpha = circle;
    float glow_alpha = glow * rim * 0.5;
    COLOR = vec4(final_color, base_alpha + glow_alpha);
}