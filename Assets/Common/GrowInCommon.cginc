// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

#include "UnityCG.cginc"

sampler2D _OffsetTex;
sampler2D _DelayTex;
float _GrowScale;
fixed _Flip;



float GrowLerpVal(float2 uv, float4 posIn, fixed time){
    float delay = tex2Dlod(_DelayTex, float4(uv,0,0)).r * _Flip - _Flip ;
    return saturate(time - delay);
}

float3 GrowPrecalcLerp(float2 uv, float4 posIn, float lerpVal){
    float3 val = tex2Dlod(_OffsetTex, float4(uv,0,0)).xyz ;

    val.x -=0.5;
    val.z -=0.5;

    val.x *=-1;
    val.z *=-1;
    //val.y -=0.5;
    return lerp(val * _GrowScale * posIn.w, posIn.xyz * posIn.w, lerpVal);
}

float3 Grow(float2 uv, float4 posIn, fixed time){
    float delay = GrowLerpVal(uv, posIn, time);
    return GrowPrecalcLerp(uv, posIn, delay);
}
