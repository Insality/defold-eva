varying mediump vec2 var_texcoord0;
varying lowp vec4 var_color;
varying lowp float var_saturate_adjust;

uniform lowp sampler2D texture_sampler;

// FROM: https://github.com/AnalyticalGraphicsInc/cesium/blob/master/Source/Shaders/Builtin/Functions/saturation.glsl
vec3 czm_saturation(vec3 rgb, float adjustment)
{
    // Algorithm from Chapter 16 of OpenGL Shading Language
    const vec3 W = vec3(0.2125, 0.7154, 0.0721);
    vec3 intensity = vec3(dot(rgb, W));
    return mix(intensity, rgb, adjustment);
}

void main()
{
    lowp vec4 tex = texture2D(texture_sampler, var_texcoord0.xy);
    vec4 c = tex * var_color;
    c.rgb = czm_saturation(c.rgb, var_saturate_adjust);
    gl_FragColor = c;
}
