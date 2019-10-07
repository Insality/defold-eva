varying mediump vec2 var_texcoord0;

uniform lowp sampler2D original;
uniform lowp vec4 light;
uniform lowp vec4 tint;

void main()
{
	// Pre-multiply alpha since all runtime textures already are
	// lowp vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);

	// Desaturate the color sampled from the original texture
	vec4 color = texture2D(original, var_texcoord0.xy);
	gl_FragColor = vec4(color.r * light.x, color.g * light.x, color.b * light.x, 1.0);

	// gl_FragColor = texture2D(original, var_texcoord0.xy) * tint_pm;
}
