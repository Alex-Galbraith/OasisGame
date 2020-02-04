Shader "Custom/PadShader"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "white" {}
		_OffsetTex("Offset Texture", 2D) = "white" {}
		_DelayTex("Delay Texture", 2D) = "white" {}
		_DitherTex("Dither Texture", 2D) = "white" {}
		_DitherRadius("Dither Radius", Float) = 1
		_DropIn("DropIn", Float) = 0
		_GrowScale("Grow scale", Float) = 40
		_Flip("Flip", Float) = -1
		_RippleTex("Ripple Texture", 2D) = "black"
		_RippleHeight("Ripple height", Float) = 1
	}
	SubShader
	{
		
		Pass
		{
			// Setup our pass to use Forward rendering, and only receive
			// data on the main directional light and ambient light.
			Tags
			{
				"LightMode" = "ShadowCaster"
				"PassFlags" = "OnlyDirectional"
				"Queue" = "AlphaTest"
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// Compile multiple versions of this shader depending on lighting settings.
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			// Files below include macros and functions to assist
			// with lighting and shadows.
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "GrowInCommon.cginc"

			struct appdata
			{
				float4 vertex : POSITION;		
				float2 uv : TEXCOORD0;		
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 wpos : TEXCOORD4;
				float3 viewDir : TEXCOORD1;	
			};

			float4x4 _RippleWorldToClip;
			sampler2D _MainTex;
			float4 _MainTex_ST, _DitherAround;
			float _DropIn;
			
			v2f vert (appdata v)
			{
				v2f o;
				v.vertex.xyz = Grow(v.uv, v.vertex, _DropIn);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.viewDir = WorldSpaceViewDir(v.vertex);
				o.wpos =  mul(unity_ObjectToWorld, v.vertex);
				return o;
			}
			
			float4 _Color;

			float4 _AmbientColor;

			float4 _SpecularColor;
			float _Glossiness;		

			float4 _RimColor;
			float _RimAmount;
			float _RimThreshold, _DitherRadius;	

			float4 frag (v2f i) : SV_Target
			{
				float3 viewDir = normalize(i.viewDir);
				float3 dirToPlayer = _DitherAround - _WorldSpaceCameraPos;
				float3 dirToFrag = i.wpos - _WorldSpaceCameraPos;
				float3 fragToPlayer = _DitherAround - i.wpos;
				float3 orthoganal = fragToPlayer - viewDir * dot(viewDir, fragToPlayer);
				fixed doClip = step(length(orthoganal), _DitherRadius + i.wpos.y * _DitherRadius);
				fixed thing = (dot(viewDir.xyz, dirToPlayer) - dot(viewDir.xyz, dirToFrag.xyz)) ;
				//clip(thing * doClip);
				return (1);
			}
			ENDCG
		}

		Pass
		{
			// Setup our pass to use Forward rendering, and only receive
			// data on the main directional light and ambient light.
			Tags
			{
				"LightMode" = "ForwardBase"
				"PassFlags" = "OnlyDirectional"
				"Queue" = "AlphaTest"
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// Compile multiple versions of this shader depending on lighting settings.
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			// Files below include macros and functions to assist
			// with lighting and shadows.
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "GrowInCommon.cginc"

			struct appdata
			{
				float4 vertex : POSITION;				
				float4 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 wpos : TEXCOORD4;
				float3 worldNormal : NORMAL;
				float2 uv : TEXCOORD0;
				float3 viewDir : TEXCOORD1;	
				// Macro found in Autolight.cginc. Declares a vector4
				// into the TEXCOORD2 semantic with varying precision 
				// depending on platform target.
				SHADOW_COORDS(2)
			};

			#include "ToonCommon.cginc"

			sampler2D _RippleTex;
			float4 _DitherAround;
			float _DropIn, _RippleHeight;
			float4x4 _RippleWorldToClip;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.wpos =  mul(unity_ObjectToWorld, v.vertex);

				float4 ripplePos = mul(_RippleWorldToClip, o.wpos);
				float2 rippleUV = ComputeScreenPos(ripplePos).xy / ripplePos.w;
				#if UNITY_UV_STARTS_AT_TOP
				rippleUV. y = 1 - rippleUV.y;
				#endif

				float h = tex2Dlod(_RippleTex, float4(rippleUV,0,0)).r;
				float delay = GrowLerpVal(o.uv, v.vertex, _DropIn);
				v.vertex.xyz = GrowPrecalcLerp(o.uv, v.vertex, delay);
				v.vertex.xyz += mul(unity_WorldToObject,float4(0,1 * _RippleHeight * h * delay,0,0)).xyz;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);		
				o.viewDir = WorldSpaceViewDir(v.vertex);
				o.wpos =  mul(unity_ObjectToWorld, v.vertex);


				// Defined in Autolight.cginc. Assigns the above shadow coordinate
				// by transforming the vertex from world space to shadow-map space.
				TRANSFER_SHADOW(o)
				return o;
			}
			
			float _DitherRadius;	


			float4 frag (v2f i) : SV_Target
			{
				float3 normal = normalize(i.worldNormal);
				float3 viewDir = normalize(i.viewDir);
				float3 dirToPlayer = _DitherAround - _WorldSpaceCameraPos;
				float3 dirToFrag = i.wpos - _WorldSpaceCameraPos;
				float3 fragToPlayer = _DitherAround - i.wpos;
				float3 orthoganal = fragToPlayer - viewDir * dot(viewDir, fragToPlayer);
				fixed doClip = step(length(orthoganal), _DitherRadius + i.wpos.y * _DitherRadius);
				fixed thing = (dot(viewDir.xyz, dirToPlayer) - dot(viewDir.xyz, dirToFrag.xyz)) ;
				//clip(thing * doClip);
				

				float4 col = ToonShade(i);

				return col;
			}
			ENDCG
		}
	}
}