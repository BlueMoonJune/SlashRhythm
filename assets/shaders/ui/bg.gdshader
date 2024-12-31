shader_type canvas_item;

void vertex() {
}

void fragment() {
	vec2 uv = FRAGCOORD.xy;
	COLOR.rgb = vec3(length(mod(uv, 50) - 25.0 + sin(uv / 50.0 + TIME * .7128347) * 5.0) < sin((uv.x + uv.y) / 10.0) + 1.0 ? 0.1 : 0.0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
