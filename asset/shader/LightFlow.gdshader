shader_type canvas_item;

uniform float speed = 1.0;
uniform float strength = 1.0;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	float project_distance = UV.x + UV.y;
	float h = mod(project_distance + TIME * speed, 2.0);
	COLOR.rgb = mix(COLOR.rgb, hsv2rgb(vec3(h, 1, 1)), strength);
	COLOR.a = texture(TEXTURE, UV).a;
}
