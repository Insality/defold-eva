// grade.fp
varying mediump vec4 position;
varying mediump vec2 var_texcoord0;

uniform lowp sampler2D original;

void main()
{
	vec4 color = texture2D(original, var_texcoord0.xy);
	// Desaturate the color sampled from the original texture
	float grey = color.r * 0.3 + color.g * 0.59 + color.b * 0.11;
	gl_FragColor = vec4(grey, grey, grey, 1.0);
}