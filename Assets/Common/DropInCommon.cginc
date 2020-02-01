// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

#include "UnityCG.cginc"

sampler2D _OffsetTex;

float4 Offset(float2 uv, float4 posIn, fixed time){
    float val = tex2Dlod(_OffsetTex, float4(uv,0,0)).r;
    float deltaScale = max(0,val - time);
    return posIn + deltaScale * mul(unity_WorldToObject,float4(0,-10,0,0));
}