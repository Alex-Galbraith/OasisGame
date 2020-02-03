sampler2D _MainTex;
float4 _MainTex_ST;
float4 _AmbientColor;
float4 _Color;


float4 ToonShade(v2f i){
    float3 normal = normalize(i.worldNormal);
    float3 viewDir = normalize(i.viewDir);
    // Lighting below is calculated using Blinn-Phong,
    // with values thresholded to creat the "toon" look.
    // https://en.wikipedia.org/wiki/Blinn-Phong_shading_model

    // Calculate illumination from directional light.
    // _WorldSpaceLightPos0 is a vector pointing the OPPOSITE
    // direction of the main directional light.
    float NdotL = dot(_WorldSpaceLightPos0, normal);
    float NdotV = dot(viewDir, normal);

    // Samples the shadow map, returning a value in the 0...1 range,
    // where 0 is in the shadow, and 1 is not.
    float shadow = SHADOW_ATTENUATION(i);
    // Partition the intensity into light and dark, smoothly interpolated
    // between the two to avoid a jagged break.
    float LowIntensity = smoothstep(0, 0.001, NdotL * shadow);	
    float MedIntensity = smoothstep(0.5, 0.501, NdotL * shadow);	
    float lightIntensity = (LowIntensity + MedIntensity) * 0.5;
    
    // Multiply by the main directional light's intensity and color.
    float4 light = lightIntensity * _LightColor0;

    float4 sample = tex2D(_MainTex, i.uv);
    float4 col = lerp(_Color, _AmbientColor, saturate(_AmbientColor.a * (1-lightIntensity)));
    col = (saturate(light + _AmbientColor) ) * col * sample;
    col.a = 1;
    return col;
}