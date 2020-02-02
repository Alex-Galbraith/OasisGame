// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

#include "UnityCG.cginc"

sampler2D _Dissolve;
sampler2D _OffsetTex;
sampler2D _Ramp;
float _DissolveScale;
float _DissolveVal;
float4 _DropDir;

float4 Dissolve(float2 uv, float4 oldColor){
        fixed off = tex2D(_OffsetTex, uv);
        fixed d = tex2D(_Dissolve, uv*_DissolveScale).r + 1;
        clip(d - max(0,_DissolveVal-off));
        float rd = saturate(d - _DissolveVal + off);
        fixed4 dcolor = tex2D(_Ramp, float2(1- (rd), 0));
        //oldColor = lerp(oldColor, float4(dcolor.rgb * 2,1), 1-saturate(rd*5));
        return oldColor;
}