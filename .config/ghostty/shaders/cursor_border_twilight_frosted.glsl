float sdRectangle(vec2 point, vec2 center, vec2 halfSize) {
    vec2 d = abs(point - center) - halfSize;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

vec4 blurInput(vec2 uv, vec2 px) {
    vec4 sum = vec4(0.0);

    sum += texture(iChannel0, uv + px * vec2(-2.0, -1.0)) * 0.06;
    sum += texture(iChannel0, uv + px * vec2(-1.0, -2.0)) * 0.06;
    sum += texture(iChannel0, uv + px * vec2( 1.0, -2.0)) * 0.06;
    sum += texture(iChannel0, uv + px * vec2( 2.0, -1.0)) * 0.06;

    sum += texture(iChannel0, uv + px * vec2(-2.0,  1.0)) * 0.06;
    sum += texture(iChannel0, uv + px * vec2(-1.0,  2.0)) * 0.06;
    sum += texture(iChannel0, uv + px * vec2( 1.0,  2.0)) * 0.06;
    sum += texture(iChannel0, uv + px * vec2( 2.0,  1.0)) * 0.06;

    sum += texture(iChannel0, uv + px * vec2(-1.0,  0.0)) * 0.10;
    sum += texture(iChannel0, uv + px * vec2( 1.0,  0.0)) * 0.10;
    sum += texture(iChannel0, uv + px * vec2( 0.0, -1.0)) * 0.10;
    sum += texture(iChannel0, uv + px * vec2( 0.0,  1.0)) * 0.10;

    sum += texture(iChannel0, uv) * 0.20;
    return sum;
}

float noise(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 base = texture(iChannel0, uv);

    vec2 cursorCenter = iCurrentCursor.xy + vec2(iCurrentCursor.z * 0.5, -iCurrentCursor.w * 0.5);
    vec2 halfSize = iCurrentCursor.zw * 0.5;

    float sdf = sdRectangle(fragCoord, cursorCenter, halfSize);

    float borderWidth = max(2.0, min(iCurrentCursor.z, iCurrentCursor.w) * 0.18);
    float outerGlowWidth = borderWidth * 5.5;

    float border = 1.0 - smoothstep(0.0, borderWidth, abs(sdf));
    float outerGlow = 1.0 - smoothstep(borderWidth, outerGlowWidth, max(sdf, 0.0));
    float innerFrost = 1.0 - smoothstep(-borderWidth * 2.5, -borderWidth * 0.4, sdf);

    vec4 blurred = blurInput(uv, 1.0 / iResolution.xy);
    vec3 twilightPrimary = vec3(0.97, 0.60, 0.49);
    vec3 twilightLavender = vec3(0.82, 0.68, 1.0);
    vec3 twilightFrost = vec3(0.51, 0.75, 1.0);
    vec3 twilightDeep = vec3(0.15, 0.10, 0.20);

    float grain = noise(fragCoord * 0.75 + iTime * 8.0) - 0.5;
    vec3 frosted = mix(blurred.rgb, twilightFrost, 0.18);
    frosted = mix(frosted, twilightLavender, 0.12) + grain * 0.03;

    vec3 color = base.rgb;
    color = mix(color, frosted, innerFrost * 0.34);
    color = mix(color, twilightLavender, outerGlow * 0.12);
    color = mix(color, twilightPrimary, outerGlow * 0.08);

    vec3 borderColor = mix(twilightPrimary, twilightLavender, 0.25);
    borderColor = mix(borderColor, twilightFrost, 0.12);
    color = mix(color, mix(borderColor, twilightDeep, 0.08), border * 0.82);

    fragColor = vec4(color, base.a);
}
