// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/GrowToon"
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

		
		// Ambient light is applied uniformly to all surfaces on the object.
		//[HDR]
		//_AmbientColor("Ambient Color", Color) = (0.4,0.4,0.4,1)
		[HDR]
		_SpecularColor("Specular Color", Color) = (0.9,0.9,0.9,1)
		// Controls the size of the specular reflection.
		_Glossiness("Glossiness", Float) = 3200
		[HDR]
		_RimColor("Rim Color", Color) = (0,0,0,0)
		_RimAmount("Rim Amount", Range(0, 1)) = 1
		// Control how smoothly the rim blends when approaching unlit
		// parts of the surface.
		_RimThreshold("Rim Threshold", Range(0, 1)) = 0.1		
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
				float3 wpos : TEXCOORD4;
				float3 worldNormal : NORMAL;
				float2 uv : TEXCOORD0;
				float3 viewDir : TEXCOORD1;	
				// Macro found in Autolight.cginc. Declares a vector4
				// into the TEXCOORD2 semantic with varying precision 
				// depending on platform target.
				SHADOW_COORDS(2)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST, _DitherAround;
			float _DropIn;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				v.vertex.xyz = Grow(o.uv, v.vertex, _DropIn);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);		
				o.viewDir = WorldSpaceViewDir(v.vertex);
				o.wpos =  mul(unity_ObjectToWorld, v.vertex);
				// Defined in Autolight.cginc. Assigns the above shadow coordinate
				// by transforming the vertex from world space to shadow-map space.
				TRANSFER_SHADOW(o)
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
				float3 normal = normalize(i.worldNormal);
				float3 viewDir = normalize(i.viewDir);
				float3 dirToPlayer = _DitherAround - _WorldSpaceCameraPos;
				float3 dirToFrag = i.wpos - _WorldSpaceCameraPos;
				float3 fragToPlayer = _DitherAround - i.wpos;
				float3 orthoganal = fragToPlayer - viewDir * dot(viewDir, fragToPlayer);
				fixed doClip = step(length(orthoganal), _DitherRadius + i.wpos.y * _DitherRadius);
				fixed thing = (dot(viewDir.xyz, dirToPlayer) - dot(viewDir.xyz, dirToFrag.xyz)) ;
				//clip(thing * doClip);

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

				// Calculate specular reflection.
				float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
				float NdotH = dot(normal, halfVector);
				// Multiply _Glossiness by itself to allow artist to use smaller
				// glossiness values in the inspector.
				float specularIntensity = pow(NdotH * lightIntensity, _Glossiness * _Glossiness);
				float specularIntensitySmooth = smoothstep(0.005, 0.006, specularIntensity);
				float4 specular = specularIntensitySmooth * _SpecularColor;				

				// Calculate rim lighting.
				float rimDot = 1 - dot(viewDir, normal);
				// We only want rim to appear on the lit side of the surface,
				// so multiply it by NdotL, raised to a power to smoothly blend it.
				float rimIntensity = rimDot * pow((NdotL), _RimThreshold);
				rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
				float4 rim = rimIntensity * _RimColor;

				float4 sample = tex2D(_MainTex, i.uv);
                float4 col = lerp(_Color, _AmbientColor, saturate(_AmbientColor.a * (1-lightIntensity)));

				return (saturate(light + _AmbientColor) ) * col * sample + saturate(specular + rim);
			}
			ENDCG
		}
	}
}