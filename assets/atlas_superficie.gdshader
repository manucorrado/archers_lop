shader_type canvas_item;
render_mode unshaded;

uniform bool walnut = true;
uniform vec4 ground : source_color;
uniform vec2 dimensions;

void fragment() {
	vec2 p = UV * dimensions;
	vec3 color = ground.rgb;
	if (walnut) {
		float bend = 3.8 * sin(p.x * .008 + p.y * .023) + 1.7 * sin(p.x * .017 + p.y * .041);
		float fibre = sin((p.y + bend) * 1.9) * sin((p.y + bend * .7) * .63);
		float rings = sin((p.y + bend * 2.0) * .12 + sin(p.y * .03));
		float light = .92 + .16 * (1.0 - smoothstep(.08, .75, distance(UV, vec2(.54, .46))));
		color *= light + fibre * .035 - pow(max(rings, 0.), 14.) * .055;
	} else {
		vec2 thread = vec2(p.x + p.y * .13, p.y - p.x * .13);
		vec2 weave = cos(thread * 1.33);
		color *= .994 + .010 * weave.x + .014 * weave.y + .005 * weave.x * weave.y;
	}
	COLOR = vec4(color, 1.);
}
