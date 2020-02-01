// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

#include "UnityCG.cginc"

sampler2D _OffsetTex;
sampler2D _DelayTex;

float3 Grow(float2 uv, float4 posIn, fixed time){
    float3 val = tex2Dlod(_OffsetTex, float4(uv,0,0)).xyz ;
    float delay = tex2Dlod(_DelayTex, float4(uv,0,0)).r ;
    
    val.x -=0.5;
    val.z -=0.5;

    val.x *=-1;
    val.z *=-1;
    //val.y -=0.5;
    return lerp(val * .4 * posIn.w, posIn.xyz * posIn.w, saturate(time - delay));
}