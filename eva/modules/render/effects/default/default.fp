varying mediump vec2 var_texcoord0;

uniform lowp sampler2D original;
// Last value can be used as light of the scene
uniform lowp vec4 tint;

uniform lowp vec4 resolution;

// vec4(grayscale, sepia, blur, scanlines)
// scanlines best on ~ 0.05
uniform lowp vec4 effects;

// vec4(grad_length, border_power, lcd, lcd_alpha)
// center_light ~ [10 - 20], border_power ~ [0..1]. The nice value is 10, 0.1
// lcd ~ 0.1, lcd_alpha ~ [.25, 1]
uniform lowp vec4 effects2;

// vec4(chrom_distance, 0, 0, 0)
uniform lowp vec4 effects3;


void main()
{
	// Pre-multiply alpha since all runtime textures already are
	vec2 uv = var_texcoord0.xy;
	lowp vec4 result = texture2D(original, var_texcoord0.xy);

	// Blur
	if (effects.z > 0.) {
		vec3 irgb = result.rgb;
		float ResS = resolution.x;
		float ResT = resolution.y;

		vec2 stp0 = vec2(1.0/ResS, 0.0);
		vec2 st0p = vec2(0.0, 1.0/ResT);
		vec2 stpp = vec2(1.0/ResS, 1.0/ResT);
		vec2 stpm = vec2(1.0/ResS, -1.0/ResT);

		vec3 i00 = texture2D(original, var_texcoord0).rgb;
		vec3 im1m1 = texture2D(original, var_texcoord0-stpp * effects.z).rgb;
		vec3 ip1p1 = texture2D(original, var_texcoord0+stpp * effects.z).rgb;
		vec3 im1p1 = texture2D(original, var_texcoord0-stpm * effects.z).rgb;
		vec3 ip1m1 = texture2D(original, var_texcoord0+stpm * effects.z).rgb;
		vec3 im10 = texture2D(original, var_texcoord0-stp0 * effects.z).rgb;
		vec3 ip10 = texture2D(original, var_texcoord0+stp0 * effects.z).rgb;
		vec3 i0m1 = texture2D(original, var_texcoord0-st0p * effects.z).rgb;
		vec3 i0p1 = texture2D(original, var_texcoord0+st0p * effects.z).rgb;

		vec3 target = vec3(0.0, 0.0, 0.0);
		target += 1.0*(im1m1+ip1m1+ip1p1+im1p1); 
		target += 2.0*(im10+ip10+i0p1);
		target += 4.0*(i00);
		target /= 16.0;
		result = vec4(target, result.w);
	}

	// Chromatical Abberation
	// If enabled - drop blur effect (choose only one)
	if (effects3.x > 0.) {
		float amount = effects3.x / 100.;

		vec3 col;
		col.r = texture2D(original, vec2(uv.x+amount, uv.y) ).r;
		col.g = texture2D(original, uv ).g;
		col.b = texture2D(original, vec2(uv.x-amount, uv.y) ).b;

		col *= (1.0 - amount * 0.5);

		result = vec4(col, result.w);
	}

	// Tint
	lowp vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
	result = result * tint_pm;

	// Vignette
	if (effects2.y > 0.) {
		vec2 texuv = var_texcoord0.xy;
		texuv.x *= 1. - texuv.x;
		texuv.y *= 1. - texuv.y;

		float vig = texuv.x * texuv.y * effects2.x;
		vig = pow(vig, effects2.y);

		result = result * vig;
	}

	// Grayscale
	if (effects.x > 0.) {
		vec3 grey_xyz = vec3(result.r * 0.3 + result.g * 0.59 + result.b * 0.11);
		result.xyz = mix(result.xyz, grey_xyz, effects.x);
	}

	// Sepia
	if (effects.y > 0.) {
		vec3 sepia;
		sepia.r = dot(result.rgb, vec3(0.393, 0.769, 0.189));
		sepia.g = dot(result.rgb, vec3(0.349, 0.686, 0.168));
		sepia.b = dot(result.rgb, vec3(0.272, 0.534, 0.131));

		result.xyz = mix(result.xyz, sepia, effects.y);
	}

	// Scanlines
	if (effects.w > 0.) {
		float scanline = sin(var_texcoord0.y * resolution.y)* effects.w;
		result -= scanline;
	}

	// LCD
	if (effects2.z != 0.) {
		vec2 fragCoord = vec2(var_texcoord0.x * resolution.x, var_texcoord0.y * resolution.y);
		// Default lcd colour (affects brightness)
		float pb = 1. + effects2.z;
		vec4 lcdColor = vec4(pb, pb, pb, 1.0);

		// Change every 1st, 2nd, and 3rd vertical strip to RGB respectively
		int px = int(mod(fragCoord.x, 3.0));
		if (px == 1) lcdColor.r = 1.0;
		else if (px == 2) lcdColor.g = 1.0;
		else lcdColor.b = 1.0;

		// Darken every 3rd horizontal strip for scanline
		float sclV = effects2.w;
		if (int(mod(fragCoord.y, 3.0)) == 0) lcdColor.rgb = vec3(sclV,sclV,sclV);
		result *= lcdColor;
	}

	gl_FragColor = result;
}
