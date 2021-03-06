﻿
//1. Transparent
//2. Rim
//3. Intersection Highlight
Shader "Custom/Water"
{
	Properties
	{
		_FoamColor("Foam Color", Color) = (1,1,1,1)
		_DepthColor("Depth Color", Color) = (0,0,0,1)
		_RimPower("Rim Power", Range(0, 10)) = 1
		_Ambient("Ambient", Color) = (1,1,1,1)
		_Shean("Shean", Float) = 0.1
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
		_RippleTex("Ripple Texture", 2D) = "black"
		_RippleHeight("Ripple height", Float) = 1
		_RippleStr("Ripple str", Float) = 1
		[HideInInspector] _ReflectionTex("", 2D) = "white"
	}

	CGINCLUDE
	#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "Lighting.cginc"
	ENDCG

			
		SubShader
	{
		Pass{
			Tags{ "Queue" = "Transparent" "LightMode" = "ForwardBase" }
			ZWrite Off
			Lighting Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag	
			struct appdata{};
			struct v2f{};
		
			v2f vert(appdata a){
				v2f o;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return fixed4(0,0,0,0);
			}
			ENDCG

		}
		GrabPass
		{
			"_BackgroundTexture"
		}
		Pass{
		Tags{ "Queue" = "Transparent" "LightMode" = "ForwardBase" }
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
			float4 screenPos : TEXCOORD7;
			float eyeZ : TEXCOORD3;
			float2 uv : TEXCOORD4;
			float4 grabPos : TEXCOORD5;
			float4 worldPos : TEXCOORD6;
			SHADOW_COORDS(2)

		};
	

	sampler2D _CameraDepthTexture, _ReflectionTex, _RippleTex;
	sampler2D _NoiseTex, _NormTex, _BackgroundTexture, _FoamTex;
	float4x4 unity_WorldToLight, _ShadowDepthMatrix;
	float4x4 _RippleWorldToClip;
	fixed4 _FoamColor, _DepthColor, _Ambient;
	fixed _RimPower;
	fixed _IntersectionPower, _IntersectionBias;
	fixed  _MaxDepth, _Refraction, _NormalStrength, _FoamNoiseStrength, _Reflect, _RippleHeight, _RippleStr;
	fixed2 _NoiseTiling, _NormTiling, _FoamTiling;
	float _Shean;


	
	float3 filterNormalLod(float4 uv, float texelSize)
	{
		float4 h;
		h[0] = tex2Dlod(_RippleTex, uv + float4(texelSize * float2( 0,-1),0,0)).r * _RippleHeight;
		h[1] = tex2Dlod(_RippleTex, uv + float4(texelSize * float2(-1, 0),0,0)).r * _RippleHeight;
		h[2] = tex2Dlod(_RippleTex, uv + float4(texelSize * float2( 1, 0),0,0)).r * _RippleHeight;
		h[3] = tex2Dlod(_RippleTex, uv + float4(texelSize * float2( 0, 1),0,0)).r * _RippleHeight;
		float3 n;
		n.z = h[0] - h[3];
		n.x = h[1] - h[2];
		n.y = 1;
		return normalize(n);
	}

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
		TRANSFER_SHADOW(o)

		return o;
	}


	fixed4 frag(v2f i) : SV_Target
	{
		float shadow = SHADOW_ATTENUATION(i);
		float4 ripplePos = mul(_RippleWorldToClip, i.worldPos);
		float2 rippleUV = ComputeScreenPos(ripplePos).xy / ripplePos.w;
		#if UNITY_UV_STARTS_AT_TOP
		rippleUV. y = 1 - rippleUV.y;
		#endif

		float2 flow = float2(-.1,0.01) * 0.1;
		float wrappedTime = abs((_Time[1] * 0.5));
		float noise = tex2D(_NoiseTex, (i.uv - flow * _Time)*_NoiseTiling).r;
		float3 ripple = filterNormalLod(float4(rippleUV,0,0), 1.0/512.0) * _RippleStr;
		ripple.y = 0;
		float3 addNorm = lerp(tex2D(_NormTex, (i.uv - flow * _Time)*_NormTiling), tex2D(_NormTex, (i.uv  - flow * _Time)*_NormTiling + 0.5), wrappedTime) * _NormalStrength;
		float3 foam = 1-tex2D(_FoamTex, (i.uv - flow * _Time * 0.5)*_FoamTiling)*_FoamNoiseStrength;
		addNorm.xy -= fixed2(1, 1)*_NormalStrength ;
		addNorm += ripple;
		float3 worldNormal = normalize(i.worldNormal + (addNorm*noise));
		float3 worldViewDir = normalize(i.worldViewDir);

		
		half3 worldRefl = reflect(-worldViewDir, i.worldNormal);


		fixed4 skyColor = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(i.screenPos)+ UNITY_PROJ_COORD(float4(addNorm,0)));
		
		float screenZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));
		float waterDepth = screenZ - i.eyeZ;
		float refraction = _Refraction * saturate(waterDepth);

		float screenZ2 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos) + UNITY_PROJ_COORD(float4(addNorm*refraction, 0))));

		float intersect = (_IntersectionBias - (waterDepth)) * _IntersectionPower;
		intersect = step(0.1, intersect - foam - noise );

		float4 c = 0;
		c.a = 1;

		float rimVal = 1 - (dot(worldNormal, worldViewDir)) * _RimPower;
		float rim = clamp(rimVal, 0, 1) * _Reflect * skyColor.a;
		c.rgb = rim * skyColor + (_FoamColor * intersect * _FoamColor.a * (shadow+_Ambient)) ;
		//c.rgb = c.rgb * c.a;

		float4 a = float4(tex2Dproj(_BackgroundTexture, i.grabPos));
		i.grabPos.xy += (addNorm)*refraction;

	
		float4 b = float4(tex2Dproj(_BackgroundTexture, i.grabPos));
		fixed refrFix = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.grabPos)));


		if (refrFix < i.eyeZ) {
			b = a;
			screenZ2 = screenZ;
		}
		//screenZ2 = screenZ;

		//c.rgb += b.rgb;
		c.rgb += lerp(b.rgb , _DepthColor.rgb, clamp((screenZ2 - i.eyeZ) / _MaxDepth, 0, 1)) *(1 - rim) * (1 - intersect * _FoamColor.a ) + _Ambient * _Shean * (rimVal);
		
		//c = tex2D(_RippleTex,rippleUV);
		return c;
	}
	
		
		ENDCG
	}
	}
	
}