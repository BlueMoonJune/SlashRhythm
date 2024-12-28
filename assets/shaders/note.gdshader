shader_type canvas_item;

uniform vec4 color : source_color;
uniform vec2 slicePoint;
uniform vec2 sliceDir;
uniform float sliceDist;

void vertex() {
	float sliceDistw = mod(TIME * 1.0, 2.0);
	VERTEX *= sliceDist + 1.0;
}

void fragment() {
	float sliceDistw = mod(TIME * 1.0, 2.0);
	vec2 sd = normalize(sliceDir).yx * vec2(-1, 1);
	vec2 norUV = (UV - 0.5) * (sliceDist + 1.0) + 0.5;
	float side = dot(norUV - 0.5 - slicePoint, sd);
	norUV -= sd * sign(side) * sliceDist / 2.0;
	float side2 = dot(norUV - 0.5 - slicePoint, sd);
	if (sign(side2) != sign(side)) {
		COLOR.a = 0.0;
	} else {
		if (abs(side) < sliceDist) {
			float val = abs(side) - sliceDist;
			//if (abs(side2) / sliceDist == 0.0);
			COLOR.rgb = color.rgb * 5.0 + vec3(1.0);
			COLOR.a = color.a * 2.0 + abs(side) - sliceDist * 2.0;
			COLOR.a *= texture(TEXTURE, norUV).a;
		} else {
			COLOR.rgba = texture(TEXTURE, norUV);
			COLOR.rgb += color.rgb;
			COLOR.a *= color.a;
		}
	}
	COLOR.a = clamp(COLOR.a, 0.0, 1.0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
