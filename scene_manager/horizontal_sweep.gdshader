shader_type canvas_item;

uniform float progress: hint_range(0, 1);
uniform bool fill = false;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

void fragment() {
	// Called for every pixel the material is visible on.
	float x = UV.x - 0.5;
	float y = UV.y - 0.5;
	if ((x * x + y * y) > (progress / 2.0)) {
		if (fill) {
			discard;
		}
	} else if (!fill) {
		discard;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
