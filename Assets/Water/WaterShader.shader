
//1. Transparent
//2. Rim
//3. Intersection Highlight
Shader "Custom/Water"
{
	Properties
	{
		_MainColor("Foam Color", Color) = (1,1,1,1)
		_DepthColor("Depth Color", Color) = (0,0,0,1)
		_RimPower("Rim Power", Range(0, 10)) = 1
		[MaterialToggle] _Reflect("Do reflections", Float) = 1
		_IntersectionPower("Intersect Power", Range(0, 1)) = 0


		_IntersectionBias("Intersection Bias", Float) = 1
		_MaxDepth("Max Depth", Float) = 1
		_Refraction("Refraction", Float) = 0.2
		_NormalStrength("Normal Strength", Float) = 1

		_FoamTex("Foam Noise", 2D) = "white"
		_FoamNoiseStrength("Foam Noise Strength", Float) = 1
		_FoamTiling("Foam Tiling", Vector) = (1,1,0,0)
		_NoiseTex("Noise", 2D) = "black"
		_NoiseTiling("Noise Tiling", Vector) = (1,1,0,0)
		_NormTex("Norm", 2D) = "bump"
		_NormTiling("Norm Tiling", Vector) = (1,1,0,0)
		_CausticTex("Caustic Texture", 2D) = "white"
		_CausticTiling("Caustic Tiling", Vector) = (1, 1, 0, 0)
		[HideInInspector] _ReflectionTex("", 2D) = "white"
	}

	CGINCLUDE
	#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "Lighting.cginc"
	ENDCG

			
		SubShader
	{
		GrabPass
	{
		"_BackgroundTexture"
	}
		Pass{
		Tags{ "Queue" = "Opaque" "LightMode" = "ForwardBase" }
		ZWrite On
		Lighting On
		CGPROGRAM


	#pragma vertex vert
	#pragma fragment frag
	
	#pragma multi_compile_fwdbase 
	
		struct appdata
		{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		float3 normal : NORMAL;
		
		};
	struct v2f
	{
		float4 pos : SV_POSITION;
		float3 worldNormal : TEXCOORD0;
		float3 worldViewDir : TEXCOORD1;
		float4 screenPos : TEXCOORD2;
		float eyeZ : TEXCOORD3;
		float2 uv : TEXCOORD4;
		float4 grabPos : TEXCOORD5;
		float4 worldPos : TEXCOORD6;
	};
	

	sampler2D _CameraDepthTexture, _ReflectionTex;
	sampler2D _NoiseTex, _NormTex, _BackgroundTexture, _FoamTex, _CausticTex;
	float4x4 unity_WorldToLight, _ShadowDepthMatrix;
	fixed4 _MainColor, _DepthColor;
	fixed _RimPower;
	fixed _IntersectionPower, _IntersectionBias;
	fixed  _MaxDepth, _Refraction, _NormalStrength, _FoamNoiseStrength, _Reflect;
	fixed2 _NoiseTiling, _NormTiling, _FoamTiling, _CausticTiling;


	


	v2f vert(appdata v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.worldPos = mul(unity_ObjectToWorld, v.vertex);
		o.worldNormal = UnityObjectToWorldDir(v.normal);
		o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
		o.screenPos = ComputeScreenPos(o.pos);
		COMPUTE_EYEDEPTH(o.eyeZ);
		o.uv = v.uv;
		// use ComputeGrabScreenPos function from UnityCG.cginc
		// to get the correct texture coordinate
		o.grabPos = ComputeGrabScreenPos(o.pos);
		return o;
	}

	float3 BoxProjection(
		float3 direction, float3 position,
		float3 cubemapPosition, float3 boxMin, float3 boxMax) {
		float3 factors = ((direction > 0 ? boxMax : boxMin) - position) / direction;
		float scalar = min(min(factors.x, factors.y), factors.z);
		return direction * scalar + (position - cubemapPosition);
	}

	fixed4 frag(v2f i) : SV_Target
	{
		float2 flow = float2(-.1,0.01);
		float wrappedTime = abs(frac(_Time[1] * 0.5) - 0.5)*2;
		float noise = tex2D(_NoiseTex, (i.uv - flow * _Time)*_NoiseTiling).r;
		float3 addNorm = lerp(tex2D(_NormTex, (i.uv - flow * _Time)*_NormTiling), tex2D(_NormTex, (i.uv  - flow * _Time)*_NormTiling + 0.5), wrappedTime) * _NormalStrength;
		float3 foam = 1-tex2D(_FoamTex, (i.uv - flow * _Time * 0.5)*_FoamTiling)*_FoamNoiseStrength;
		addNorm.xy -= fixed2(1, 1)*_NormalStrength;
		float3 worldNormal = normalize(i.worldNormal + (addNorm*noise));
		float3 worldViewDir = normalize(i.worldViewDir);

		float rim = 1 - (dot(worldNormal, worldViewDir)) * _RimPower;
		rim = clamp(rim, 0, 1) * _Reflect;
		half3 worldRefl = reflect(-worldViewDir, i.worldNormal);


		fixed4 skyColor = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(i.screenPos)+ UNITY_PROJ_COORD(float4(addNorm,0)));

		float screenZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));
		float screenZ2 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos) + UNITY_PROJ_COORD(float4(addNorm*_Refraction, 0))));

		float waterDepth = screenZ - i.eyeZ;
		float intersect = (_IntersectionBias - (waterDepth)) * _IntersectionPower;
		intersect = step(0.1, intersect - foam - noise );

		float4 c = 0;
		c.a = 1;
		c.rgb = rim * skyColor + (_MainColor * intersect * _MainColor.a) ;
		//c.rgb = c.rgb * c.a;

		float4 a = float4(tex2Dproj(_BackgroundTexture, i.grabPos));
		i.grabPos.xy += (addNorm)*_Refraction;
		float4 b = float4(tex2Dproj(_BackgroundTexture, i.grabPos));
		fixed refrFix = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.grabPos)));


		if (refrFix < i.eyeZ) {
			b = a;
			screenZ2 = screenZ;
		}
		//c.rgb += b.rgb;
		c.rgb += lerp(b.rgb , _DepthColor.rgb, clamp((screenZ2 - i.eyeZ) / _MaxDepth, 0, 1)) *(1 - rim) * (1 - intersect * _MainColor.a);
		//c = clamp(c, 0, 1);
		//c = c / c.a;
		return c;
	}
	
		
		ENDCG
	}
	}
	
}