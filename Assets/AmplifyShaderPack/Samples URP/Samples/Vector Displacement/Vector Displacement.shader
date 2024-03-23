// Made with Amplify Shader Editor v1.9.3.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AmplifyShaderPack/Vector Displacement"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_ScreenToggle("Screen Toggle", Range( 0 , 1)) = 0
		_HandIntensity("Hand Intensity", Range( 0 , 3)) = 0
		_SkullIntensity("Skull Intensity", Range( 0 , 1.5)) = 0
		_SideHandIntensity("Side Hand Intensity", Range( 0 , 1.5)) = 0
		_NoiseTiling("Noise Tiling", Float) = 1
		_TilingGlow("Tiling Glow", Float) = 1
		_NormalHands("Normal Hands", 2D) = "bump" {}
		_Albedo("Albedo", 2D) = "white" {}
		_Masks("Masks", 2D) = "white" {}
		_NormalTopSkull("Normal Top Skull", 2D) = "bump" {}
		_TopSkullTint("Top Skull Tint", Color) = (0,0,0,0)
		_SideHandTint("Side Hand Tint", Color) = (0,0,0,0)
		_Normal("Normal", 2D) = "bump" {}
		_NormalsLeftHand("Normals Left Hand", 2D) = "bump" {}
		_TV_MetallicSmoothness("TV_MetallicSmoothness", 2D) = "white" {}
		_BaseSmoothness("Base Smoothness", Range( 0 , 1)) = 0
		_NoiseFlipbook("Noise Flipbook", 2D) = "white" {}
		[HDR]_GlowIntensity("Glow Intensity", Float) = 0
		[HDR]_NoiseTint("Noise Tint", Color) = (0,0,0,0)
		_TVHandsTint("TV Hands Tint", Color) = (0,0,0,0)
		_ScreenHandsVDM("Screen Hands VDM", 2D) = "white" {}
		_TopSkullVDM("Top Skull VDM", 2D) = "white" {}
		_LeftHandVDM("Left Hand VDM", 2D) = "white" {}
		_ScreenColorTintBlend("Screen Color Tint Blend", Range( 0 , 1)) = 0
		_DisplacementMultiplier("Displacement Multiplier", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}


		//_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		//_TransStrength( "Trans Strength", Range( 0, 50 ) ) = 1
		//_TransNormal( "Trans Normal Distortion", Range( 0, 1 ) ) = 0.5
		//_TransScattering( "Trans Scattering", Range( 1, 50 ) ) = 2
		//_TransDirect( "Trans Direct", Range( 0, 1 ) ) = 0.9
		//_TransAmbient( "Trans Ambient", Range( 0, 1 ) ) = 0.1
		//_TransShadow( "Trans Shadow", Range( 0, 1 ) ) = 0.5
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector][ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[HideInInspector][ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0
		[HideInInspector][ToggleOff] _ReceiveShadows("Receive Shadows", Float) = 1.0

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" "UniversalMaterialType"="Lit" }

		Cull Back
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 4.5
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120113


			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _LIGHT_LAYERS
			#pragma multi_compile_fragment _ _LIGHT_COOKIES
			#pragma multi_compile _ _CLUSTERED_RENDERING

            #pragma multi_compile _ DOTS_INSTANCING_ON

			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fragment _ DEBUG_DISPLAY

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_FORWARD

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#define ASE_NEEDS_VERT_TANGENT
			#define ASE_NEEDS_VERT_NORMAL


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float4 lightmapUVOrVertexSH : TEXCOORD1;
				half4 fogFactorAndVertexLight : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					float4 shadowCoord : TEXCOORD6;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					float2 dynamicLightmapUV : TEXCOORD7;
				#endif
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _ScreenHandsVDM_ST;
			float4 _NoiseTint;
			float4 _NormalHands_ST;
			float4 _Normal_ST;
			float4 _TVHandsTint;
			float4 _TV_MetallicSmoothness_ST;
			float4 _TopSkullTint;
			float4 _SideHandTint;
			float4 _Masks_ST;
			float4 _Albedo_ST;
			float _DisplacementMultiplier;
			float _SideHandIntensity;
			float _SkullIntensity;
			float _ScreenColorTintBlend;
			float _ScreenToggle;
			float _HandIntensity;
			float _NoiseTiling;
			float _GlowIntensity;
			float _TilingGlow;
			float _BaseSmoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _ScreenHandsVDM;
			sampler2D _Masks;
			sampler2D _TopSkullVDM;
			sampler2D _LeftHandVDM;
			sampler2D _Albedo;
			sampler2D _NoiseFlipbook;
			sampler2D _Normal;
			sampler2D _NormalHands;
			sampler2D _NormalTopSkull;
			sampler2D _NormalsLeftHand;
			sampler2D _TV_MetallicSmoothness;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 uv_ScreenHandsVDM = v.texcoord.xy * _ScreenHandsVDM_ST.xy + _ScreenHandsVDM_ST.zw;
				float4 tex2DNode6 = tex2Dlod( _ScreenHandsVDM, float4( uv_ScreenHandsVDM, 0, 0.0) );
				float4 appendResult5 = (float4(tex2DNode6.r , tex2DNode6.b , tex2DNode6.g , 0.0));
				float2 temp_cast_0 = (_NoiseTiling).xx;
				float2 texCoord13 = v.texcoord.xy * temp_cast_0 + float2( 0,0 );
				float simplePerlin2D11 = snoise( texCoord13*sin( _TimeParameters.x * 0.25 ) );
				simplePerlin2D11 = simplePerlin2D11*0.5 + 0.5;
				float BasicNoise116 = simplePerlin2D11;
				float2 uv_Masks = v.texcoord.xy * _Masks_ST.xy + _Masks_ST.zw;
				float4 tex2DNode45 = tex2Dlod( _Masks, float4( uv_Masks, 0, 0.0) );
				float MaskR15 = tex2DNode45.r;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.tangentOS.xyz);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.normalOS);
				float ase_vertexTangentSign = v.tangentOS.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentTobjectDir4 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( ( appendResult5 * BasicNoise116 ) * MaskR15 ).xyz ), 0 ) ).xyz;
				float2 appendResult171 = (float2(( 0.11 * BasicNoise116 ) , ( BasicNoise116 * 0.04 )));
				float2 texCoord172 = v.texcoord.xy * float2( 1,1 ) + appendResult171;
				float2 SkullWave175 = texCoord172;
				float4 tex2DNode35 = tex2Dlod( _TopSkullVDM, float4( SkullWave175, 0, 0.0) );
				float4 appendResult36 = (float4(tex2DNode35.r , tex2DNode35.b , tex2DNode35.g , 0.0));
				float MaskG63 = tex2DNode45.g;
				float3 tangentTobjectDir38 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( appendResult36 * MaskG63 ).xyz ), 0 ) ).xyz;
				float3 lerpResult72 = lerp( ( tangentTobjectDir4 * _HandIntensity ) , ( tangentTobjectDir38 * _SkullIntensity ) , MaskG63);
				float2 appendResult110 = (float2(( -0.01 * BasicNoise116 ) , ( simplePerlin2D11 * 0.04 )));
				float2 texCoord99 = v.texcoord.xy * float2( 1,1 ) + appendResult110;
				float2 LeftHandWave103 = texCoord99;
				float4 tex2DNode77 = tex2Dlod( _LeftHandVDM, float4( LeftHandWave103, 0, 0.0) );
				float4 appendResult78 = (float4(tex2DNode77.r , tex2DNode77.b , tex2DNode77.g , 0.0));
				float MaskB84 = tex2DNode45.b;
				float3 tangentTobjectDir82 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( ( appendResult78 * BasicNoise116 ) * MaskB84 ).xyz ), 0 ) ).xyz;
				float3 lerpResult85 = lerp( lerpResult72 , ( tangentTobjectDir82 * _SideHandIntensity ) , MaskB84);
				float3 FinalVertexOffset318 = ( lerpResult85 * _DisplacementMultiplier );
				
				o.ase_texcoord8.xy = v.texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord8.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = FinalVertexOffset318;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif
				v.normalOS = v.normalOS;
				v.tangentOS = v.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( v.positionOS.xyz );
				VertexNormalInputs normalInput = GetVertexNormalInputs( v.normalOS, v.tangentOS );

				o.tSpace0 = float4( normalInput.normalWS, vertexInput.positionWS.x );
				o.tSpace1 = float4( normalInput.tangentWS, vertexInput.positionWS.y );
				o.tSpace2 = float4( normalInput.bitangentWS, vertexInput.positionWS.z );

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				#endif

				#if !defined(LIGHTMAP_ON)
					OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					o.dynamicLightmapUV.xy = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord.xy;
					o.lightmapUVOrVertexSH.xy = v.texcoord.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( vertexInput.positionWS, normalInput.normalWS );

				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( vertexInput.positionCS.z );
				#else
					half fogFactor = 0;
				#endif

				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.positionCS = vertexInput.positionCS;
				o.clipPosV = vertexInput.positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.tangentOS = v.tangentOS;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.positionCS.xyz, unity_LODFade.x );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif

				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				float2 NormalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.positionCS);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif

				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float2 uv_Albedo = IN.ase_texcoord8.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				float SkullIntensity51 = _SkullIntensity;
				float2 temp_cast_0 = (_NoiseTiling).xx;
				float2 texCoord13 = IN.ase_texcoord8.xy * temp_cast_0 + float2( 0,0 );
				float simplePerlin2D11 = snoise( texCoord13*sin( _TimeParameters.x * 0.25 ) );
				simplePerlin2D11 = simplePerlin2D11*0.5 + 0.5;
				float BasicNoise116 = simplePerlin2D11;
				float2 appendResult171 = (float2(( 0.11 * BasicNoise116 ) , ( BasicNoise116 * 0.04 )));
				float2 texCoord172 = IN.ase_texcoord8.xy * float2( 1,1 ) + appendResult171;
				float2 SkullWave175 = texCoord172;
				float4 tex2DNode35 = tex2D( _TopSkullVDM, SkullWave175 );
				float TopSkullColorMask66 = tex2DNode35.g;
				float clampResult59 = clamp( ( ( SkullIntensity51 * 0.5 ) * TopSkullColorMask66 ) , 0.0 , 0.5 );
				float4 lerpResult56 = lerp( tex2D( _Albedo, uv_Albedo ) , _TopSkullTint , clampResult59);
				float SideHandIntensity75 = _SideHandIntensity;
				float2 appendResult110 = (float2(( -0.01 * BasicNoise116 ) , ( simplePerlin2D11 * 0.04 )));
				float2 texCoord99 = IN.ase_texcoord8.xy * float2( 1,1 ) + appendResult110;
				float2 LeftHandWave103 = texCoord99;
				float4 tex2DNode77 = tex2D( _LeftHandVDM, LeftHandWave103 );
				float SideHandColorMask80 = tex2DNode77.g;
				float clampResult93 = clamp( ( ( SideHandIntensity75 * 0.5 ) * SideHandColorMask80 ) , 0.0 , 0.5 );
				float4 lerpResult94 = lerp( lerpResult56 , _SideHandTint , clampResult93);
				float2 texCoord206 = IN.ase_texcoord8.xy * float2( 3,3 ) + float2( 0,0 );
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles205 = 2.0 * 2.0;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset205 = 1.0f / 2.0;
				float fbrowsoffset205 = 1.0f / 2.0;
				// Speed of animation
				float fbspeed205 = _TimeParameters.x * 12.0;
				// UV Tiling (col and row offset)
				float2 fbtiling205 = float2(fbcolsoffset205, fbrowsoffset205);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex205 = round( fmod( fbspeed205 + 0.0, fbtotaltiles205) );
				fbcurrenttileindex205 += ( fbcurrenttileindex205 < 0) ? fbtotaltiles205 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox205 = round ( fmod ( fbcurrenttileindex205, 2.0 ) );
				// Multiply Offset X by coloffset
				float fboffsetx205 = fblinearindextox205 * fbcolsoffset205;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy205 = round( fmod( ( fbcurrenttileindex205 - fblinearindextox205 ) / 2.0, 2.0 ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy205 = (int)(2.0-1) - fblinearindextoy205;
				// Multiply Offset Y by rowoffset
				float fboffsety205 = fblinearindextoy205 * fbrowsoffset205;
				// UV Offset
				float2 fboffset205 = float2(fboffsetx205, fboffsety205);
				// Flipbook UV
				half2 fbuv205 = texCoord206 * fbtiling205 + fboffset205;
				// *** END Flipbook UV Animation vars ***
				float2 uv_Masks = IN.ase_texcoord8.xy * _Masks_ST.xy + _Masks_ST.zw;
				float4 tex2DNode45 = tex2D( _Masks, uv_Masks );
				float MaskR15 = tex2DNode45.r;
				float4 temp_output_209_0 = ( tex2D( _NoiseFlipbook, fbuv205 ) * MaskR15 );
				float2 uv_ScreenHandsVDM = IN.ase_texcoord8.xy * _ScreenHandsVDM_ST.xy + _ScreenHandsVDM_ST.zw;
				float4 tex2DNode6 = tex2D( _ScreenHandsVDM, uv_ScreenHandsVDM );
				float myVarName244 = tex2DNode6.g;
				float HandIntensity29 = _HandIntensity;
				float clampResult259 = clamp( saturate( ( myVarName244 * ( HandIntensity29 * 0.7 ) ) ) , 0.0 , 0.9 );
				float4 lerpResult252 = lerp( temp_output_209_0 , _TVHandsTint , ( clampResult259 * _ScreenColorTintBlend ));
				float ScreenToggle242 = _ScreenToggle;
				float ScreenToggleSlider283 = ( MaskR15 * ScreenToggle242 );
				float4 lerpResult213 = lerp( lerpResult94 , lerpResult252 , ScreenToggleSlider283);
				float4 FinalBaseColor314 = lerpResult213;
				
				float MaskG63 = tex2DNode45.g;
				float MaskB84 = tex2DNode45.b;
				float3 appendResult20 = (float3(MaskR15 , MaskG63 , MaskB84));
				float2 uv_Normal = IN.ase_texcoord8.xy * _Normal_ST.xy + _Normal_ST.zw;
				float2 uv_NormalHands = IN.ase_texcoord8.xy * _NormalHands_ST.xy + _NormalHands_ST.zw;
				float clampResult32 = clamp( HandIntensity29 , 0.0 , 1.0 );
				float3 unpack21 = UnpackNormalScale( tex2D( _NormalHands, uv_NormalHands ), clampResult32 );
				unpack21.z = lerp( 1, unpack21.z, saturate(clampResult32) );
				float clampResult53 = clamp( SkullIntensity51 , 0.0 , 1.0 );
				float3 unpack50 = UnpackNormalScale( tex2D( _NormalTopSkull, SkullWave175 ), clampResult53 );
				unpack50.z = lerp( 1, unpack50.z, saturate(clampResult53) );
				float clampResult98 = clamp( SideHandIntensity75 , 0.0 , 1.0 );
				float3 unpack96 = UnpackNormalScale( tex2D( _NormalsLeftHand, LeftHandWave103 ), clampResult98 );
				unpack96.z = lerp( 1, unpack96.z, saturate(clampResult98) );
				float3 layeredBlendVar18 = appendResult20;
				float3 layeredBlend18 = ( lerp( lerp( lerp( UnpackNormalScale( tex2D( _Normal, uv_Normal ), 1.0f ) , unpack21 , layeredBlendVar18.x ) , unpack50 , layeredBlendVar18.y ) , unpack96 , layeredBlendVar18.z ) );
				float3 normalizeResult19 = normalize( layeredBlend18 );
				float3 FinalNormal315 = normalizeResult19;
				
				float4 TVNoise214 = temp_output_209_0;
				float2 temp_cast_2 = (_TilingGlow).xx;
				float2 texCoord235 = IN.ase_texcoord8.xy * temp_cast_2 + float2( 0,0 );
				float simplePerlin2D237 = snoise( texCoord235*_TimeParameters.y );
				simplePerlin2D237 = simplePerlin2D237*0.5 + 0.5;
				float HandMaskNoiseEmission263 = clampResult259;
				float4 FinalEmission316 = ( ( ( ( TVNoise214 * _NoiseTint * _GlowIntensity ) * simplePerlin2D237 ) * ( 1.0 - HandMaskNoiseEmission263 ) ) * ScreenToggle242 );
				
				float2 uv_TV_MetallicSmoothness = IN.ase_texcoord8.xy * _TV_MetallicSmoothness_ST.xy + _TV_MetallicSmoothness_ST.zw;
				float FinalSmoothness317 = ( tex2D( _TV_MetallicSmoothness, uv_TV_MetallicSmoothness ).a * _BaseSmoothness );
				

				float3 BaseColor = FinalBaseColor314.rgb;
				float3 Normal = FinalNormal315;
				float3 Emission = FinalEmission316.rgb;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = FinalSmoothness317;
				float Occlusion = 1;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.positionCS.z;
				#endif

				#ifdef _CLEARCOAT
					float CoatMask = 0;
					float CoatSmoothness = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;

				#ifdef _NORMALMAP
						#if _NORMAL_DROPOFF_TS
							inputData.normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
						#elif _NORMAL_DROPOFF_OS
							inputData.normalWS = TransformObjectToWorldNormal(Normal);
						#elif _NORMAL_DROPOFF_WS
							inputData.normalWS = Normal;
						#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = WorldNormal;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					inputData.shadowCoord = ShadowCoords;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
				#else
					inputData.shadowCoord = float4(0, 0, 0, 0);
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				#endif
					inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, IN.dynamicLightmapUV.xy, SH, inputData.normalWS);
				#else
					inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS);
				#endif

				#ifdef ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif

				inputData.normalizedScreenSpaceUV = NormalizedScreenSpaceUV;
				inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUVOrVertexSH.xy);

				#if defined(DEBUG_DISPLAY)
					#if defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = IN.dynamicLightmapUV.xy;
					#endif
					#if defined(LIGHTMAP_ON)
						inputData.staticLightmapUV = IN.lightmapUVOrVertexSH.xy;
					#else
						inputData.vertexSH = SH;
					#endif
				#endif

				SurfaceData surfaceData;
				surfaceData.albedo              = BaseColor;
				surfaceData.metallic            = saturate(Metallic);
				surfaceData.specular            = Specular;
				surfaceData.smoothness          = saturate(Smoothness),
				surfaceData.occlusion           = Occlusion,
				surfaceData.emission            = Emission,
				surfaceData.alpha               = saturate(Alpha);
				surfaceData.normalTS            = Normal;
				surfaceData.clearCoatMask       = 0;
				surfaceData.clearCoatSmoothness = 1;

				#ifdef _CLEARCOAT
					surfaceData.clearCoatMask       = saturate(CoatMask);
					surfaceData.clearCoatSmoothness = saturate(CoatSmoothness);
				#endif

				#ifdef _DBUFFER
					ApplyDecalToSurfaceData(IN.positionCS, surfaceData, inputData);
				#endif

				half4 color = UniversalFragmentPBR( inputData, surfaceData);

				#ifdef ASE_TRANSMISSION
				{
					float shadow = _TransmissionShadow;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );
					half3 mainTransmission = max(0 , -dot(inputData.normalWS, mainLight.direction)) * mainAtten * Transmission;
					color.rgb += BaseColor * mainTransmission;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 transmission = max(0 , -dot(inputData.normalWS, light.direction)) * atten * Transmission;
							color.rgb += BaseColor * transmission;
						}
					#endif
				}
				#endif

				#ifdef ASE_TRANSLUCENCY
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );

					half3 mainLightDir = mainLight.direction + inputData.normalWS * normal;
					half mainVdotL = pow( saturate( dot( inputData.viewDirectionWS, -mainLightDir ) ), scattering );
					half3 mainTranslucency = mainAtten * ( mainVdotL * direct + inputData.bakedGI * ambient ) * Translucency;
					color.rgb += BaseColor * mainTranslucency * strength;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 lightDir = light.direction + inputData.normalWS * normal;
							half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );
							half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;
							color.rgb += BaseColor * translucency * strength;
						}
					#endif
				}
				#endif

				#ifdef ASE_REFRACTION
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, float4( WorldNormal,0 ) ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
					projScreenPos.xy += refractionOffset.xy;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos.xy ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return color;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120113


			#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #pragma multi_compile _ DOTS_INSTANCING_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_NORMAL


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 positionWS : TEXCOORD1;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD2;
				#endif				
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _ScreenHandsVDM_ST;
			float4 _NoiseTint;
			float4 _NormalHands_ST;
			float4 _Normal_ST;
			float4 _TVHandsTint;
			float4 _TV_MetallicSmoothness_ST;
			float4 _TopSkullTint;
			float4 _SideHandTint;
			float4 _Masks_ST;
			float4 _Albedo_ST;
			float _DisplacementMultiplier;
			float _SideHandIntensity;
			float _SkullIntensity;
			float _ScreenColorTintBlend;
			float _ScreenToggle;
			float _HandIntensity;
			float _NoiseTiling;
			float _GlowIntensity;
			float _TilingGlow;
			float _BaseSmoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _ScreenHandsVDM;
			sampler2D _Masks;
			sampler2D _TopSkullVDM;
			sampler2D _LeftHandVDM;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			float3 _LightDirection;
			float3 _LightPosition;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float2 uv_ScreenHandsVDM = v.ase_texcoord.xy * _ScreenHandsVDM_ST.xy + _ScreenHandsVDM_ST.zw;
				float4 tex2DNode6 = tex2Dlod( _ScreenHandsVDM, float4( uv_ScreenHandsVDM, 0, 0.0) );
				float4 appendResult5 = (float4(tex2DNode6.r , tex2DNode6.b , tex2DNode6.g , 0.0));
				float2 temp_cast_0 = (_NoiseTiling).xx;
				float2 texCoord13 = v.ase_texcoord.xy * temp_cast_0 + float2( 0,0 );
				float simplePerlin2D11 = snoise( texCoord13*sin( _TimeParameters.x * 0.25 ) );
				simplePerlin2D11 = simplePerlin2D11*0.5 + 0.5;
				float BasicNoise116 = simplePerlin2D11;
				float2 uv_Masks = v.ase_texcoord.xy * _Masks_ST.xy + _Masks_ST.zw;
				float4 tex2DNode45 = tex2Dlod( _Masks, float4( uv_Masks, 0, 0.0) );
				float MaskR15 = tex2DNode45.r;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.normalOS);
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentTobjectDir4 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( ( appendResult5 * BasicNoise116 ) * MaskR15 ).xyz ), 0 ) ).xyz;
				float2 appendResult171 = (float2(( 0.11 * BasicNoise116 ) , ( BasicNoise116 * 0.04 )));
				float2 texCoord172 = v.ase_texcoord.xy * float2( 1,1 ) + appendResult171;
				float2 SkullWave175 = texCoord172;
				float4 tex2DNode35 = tex2Dlod( _TopSkullVDM, float4( SkullWave175, 0, 0.0) );
				float4 appendResult36 = (float4(tex2DNode35.r , tex2DNode35.b , tex2DNode35.g , 0.0));
				float MaskG63 = tex2DNode45.g;
				float3 tangentTobjectDir38 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( appendResult36 * MaskG63 ).xyz ), 0 ) ).xyz;
				float3 lerpResult72 = lerp( ( tangentTobjectDir4 * _HandIntensity ) , ( tangentTobjectDir38 * _SkullIntensity ) , MaskG63);
				float2 appendResult110 = (float2(( -0.01 * BasicNoise116 ) , ( simplePerlin2D11 * 0.04 )));
				float2 texCoord99 = v.ase_texcoord.xy * float2( 1,1 ) + appendResult110;
				float2 LeftHandWave103 = texCoord99;
				float4 tex2DNode77 = tex2Dlod( _LeftHandVDM, float4( LeftHandWave103, 0, 0.0) );
				float4 appendResult78 = (float4(tex2DNode77.r , tex2DNode77.b , tex2DNode77.g , 0.0));
				float MaskB84 = tex2DNode45.b;
				float3 tangentTobjectDir82 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( ( appendResult78 * BasicNoise116 ) * MaskB84 ).xyz ), 0 ) ).xyz;
				float3 lerpResult85 = lerp( lerpResult72 , ( tangentTobjectDir82 * _SideHandIntensity ) , MaskB84);
				float3 FinalVertexOffset318 = ( lerpResult85 * _DisplacementMultiplier );
				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = FinalVertexOffset318;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				float3 positionWS = TransformObjectToWorld( v.positionOS.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.positionWS = positionWS;
				#endif

				float3 normalWS = TransformObjectToWorldDir(v.normalOS);

				#if _CASTING_PUNCTUAL_LIGHT_SHADOW
					float3 lightDirectionWS = normalize(_LightPosition - positionWS);
				#else
					float3 lightDirectionWS = _LightDirection;
				#endif

				float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

				#if UNITY_REVERSED_Z
					positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
				#else
					positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.positionCS = positionCS;
				o.clipPosV = positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(	VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				

				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.positionCS.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM

            #define _NORMAL_DROPOFF_TS 1
            #pragma multi_compile_instancing
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            #define ASE_FOG 1
            #define _EMISSION
            #define _NORMALMAP 1
            #define ASE_SRP_VERSION 120113


            #pragma multi_compile _ DOTS_INSTANCING_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_NORMAL


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 positionWS : TEXCOORD1;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD2;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _ScreenHandsVDM_ST;
			float4 _NoiseTint;
			float4 _NormalHands_ST;
			float4 _Normal_ST;
			float4 _TVHandsTint;
			float4 _TV_MetallicSmoothness_ST;
			float4 _TopSkullTint;
			float4 _SideHandTint;
			float4 _Masks_ST;
			float4 _Albedo_ST;
			float _DisplacementMultiplier;
			float _SideHandIntensity;
			float _SkullIntensity;
			float _ScreenColorTintBlend;
			float _ScreenToggle;
			float _HandIntensity;
			float _NoiseTiling;
			float _GlowIntensity;
			float _TilingGlow;
			float _BaseSmoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _ScreenHandsVDM;
			sampler2D _Masks;
			sampler2D _TopSkullVDM;
			sampler2D _LeftHandVDM;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 uv_ScreenHandsVDM = v.ase_texcoord.xy * _ScreenHandsVDM_ST.xy + _ScreenHandsVDM_ST.zw;
				float4 tex2DNode6 = tex2Dlod( _ScreenHandsVDM, float4( uv_ScreenHandsVDM, 0, 0.0) );
				float4 appendResult5 = (float4(tex2DNode6.r , tex2DNode6.b , tex2DNode6.g , 0.0));
				float2 temp_cast_0 = (_NoiseTiling).xx;
				float2 texCoord13 = v.ase_texcoord.xy * temp_cast_0 + float2( 0,0 );
				float simplePerlin2D11 = snoise( texCoord13*sin( _TimeParameters.x * 0.25 ) );
				simplePerlin2D11 = simplePerlin2D11*0.5 + 0.5;
				float BasicNoise116 = simplePerlin2D11;
				float2 uv_Masks = v.ase_texcoord.xy * _Masks_ST.xy + _Masks_ST.zw;
				float4 tex2DNode45 = tex2Dlod( _Masks, float4( uv_Masks, 0, 0.0) );
				float MaskR15 = tex2DNode45.r;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.normalOS);
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentTobjectDir4 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( ( appendResult5 * BasicNoise116 ) * MaskR15 ).xyz ), 0 ) ).xyz;
				float2 appendResult171 = (float2(( 0.11 * BasicNoise116 ) , ( BasicNoise116 * 0.04 )));
				float2 texCoord172 = v.ase_texcoord.xy * float2( 1,1 ) + appendResult171;
				float2 SkullWave175 = texCoord172;
				float4 tex2DNode35 = tex2Dlod( _TopSkullVDM, float4( SkullWave175, 0, 0.0) );
				float4 appendResult36 = (float4(tex2DNode35.r , tex2DNode35.b , tex2DNode35.g , 0.0));
				float MaskG63 = tex2DNode45.g;
				float3 tangentTobjectDir38 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( appendResult36 * MaskG63 ).xyz ), 0 ) ).xyz;
				float3 lerpResult72 = lerp( ( tangentTobjectDir4 * _HandIntensity ) , ( tangentTobjectDir38 * _SkullIntensity ) , MaskG63);
				float2 appendResult110 = (float2(( -0.01 * BasicNoise116 ) , ( simplePerlin2D11 * 0.04 )));
				float2 texCoord99 = v.ase_texcoord.xy * float2( 1,1 ) + appendResult110;
				float2 LeftHandWave103 = texCoord99;
				float4 tex2DNode77 = tex2Dlod( _LeftHandVDM, float4( LeftHandWave103, 0, 0.0) );
				float4 appendResult78 = (float4(tex2DNode77.r , tex2DNode77.b , tex2DNode77.g , 0.0));
				float MaskB84 = tex2DNode45.b;
				float3 tangentTobjectDir82 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( ( appendResult78 * BasicNoise116 ) * MaskB84 ).xyz ), 0 ) ).xyz;
				float3 lerpResult85 = lerp( lerpResult72 , ( tangentTobjectDir82 * _SideHandIntensity ) , MaskB84);
				float3 FinalVertexOffset318 = ( lerpResult85 * _DisplacementMultiplier );
				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = FinalVertexOffset318;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( v.positionOS.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.positionWS = vertexInput.positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.positionCS = vertexInput.positionCS;
				o.clipPosV = vertexInput.positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(	VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				

				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.positionCS.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120113


			#pragma vertex vert
			#pragma fragment frag

			#pragma shader_feature EDITOR_VISUALIZATION

			#define SHADERPASS SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_NORMAL


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 texcoord0 : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 positionWS : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef EDITOR_VISUALIZATION
					float4 VizUV : TEXCOORD2;
					float4 LightCoord : TEXCOORD3;
				#endif
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _ScreenHandsVDM_ST;
			float4 _NoiseTint;
			float4 _NormalHands_ST;
			float4 _Normal_ST;
			float4 _TVHandsTint;
			float4 _TV_MetallicSmoothness_ST;
			float4 _TopSkullTint;
			float4 _SideHandTint;
			float4 _Masks_ST;
			float4 _Albedo_ST;
			float _DisplacementMultiplier;
			float _SideHandIntensity;
			float _SkullIntensity;
			float _ScreenColorTintBlend;
			float _ScreenToggle;
			float _HandIntensity;
			float _NoiseTiling;
			float _GlowIntensity;
			float _TilingGlow;
			float _BaseSmoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _ScreenHandsVDM;
			sampler2D _Masks;
			sampler2D _TopSkullVDM;
			sampler2D _LeftHandVDM;
			sampler2D _Albedo;
			sampler2D _NoiseFlipbook;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 uv_ScreenHandsVDM = v.texcoord0.xy * _ScreenHandsVDM_ST.xy + _ScreenHandsVDM_ST.zw;
				float4 tex2DNode6 = tex2Dlod( _ScreenHandsVDM, float4( uv_ScreenHandsVDM, 0, 0.0) );
				float4 appendResult5 = (float4(tex2DNode6.r , tex2DNode6.b , tex2DNode6.g , 0.0));
				float2 temp_cast_0 = (_NoiseTiling).xx;
				float2 texCoord13 = v.texcoord0.xy * temp_cast_0 + float2( 0,0 );
				float simplePerlin2D11 = snoise( texCoord13*sin( _TimeParameters.x * 0.25 ) );
				simplePerlin2D11 = simplePerlin2D11*0.5 + 0.5;
				float BasicNoise116 = simplePerlin2D11;
				float2 uv_Masks = v.texcoord0.xy * _Masks_ST.xy + _Masks_ST.zw;
				float4 tex2DNode45 = tex2Dlod( _Masks, float4( uv_Masks, 0, 0.0) );
				float MaskR15 = tex2DNode45.r;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.normalOS);
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentTobjectDir4 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( ( appendResult5 * BasicNoise116 ) * MaskR15 ).xyz ), 0 ) ).xyz;
				float2 appendResult171 = (float2(( 0.11 * BasicNoise116 ) , ( BasicNoise116 * 0.04 )));
				float2 texCoord172 = v.texcoord0.xy * float2( 1,1 ) + appendResult171;
				float2 SkullWave175 = texCoord172;
				float4 tex2DNode35 = tex2Dlod( _TopSkullVDM, float4( SkullWave175, 0, 0.0) );
				float4 appendResult36 = (float4(tex2DNode35.r , tex2DNode35.b , tex2DNode35.g , 0.0));
				float MaskG63 = tex2DNode45.g;
				float3 tangentTobjectDir38 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( appendResult36 * MaskG63 ).xyz ), 0 ) ).xyz;
				float3 lerpResult72 = lerp( ( tangentTobjectDir4 * _HandIntensity ) , ( tangentTobjectDir38 * _SkullIntensity ) , MaskG63);
				float2 appendResult110 = (float2(( -0.01 * BasicNoise116 ) , ( simplePerlin2D11 * 0.04 )));
				float2 texCoord99 = v.texcoord0.xy * float2( 1,1 ) + appendResult110;
				float2 LeftHandWave103 = texCoord99;
				float4 tex2DNode77 = tex2Dlod( _LeftHandVDM, float4( LeftHandWave103, 0, 0.0) );
				float4 appendResult78 = (float4(tex2DNode77.r , tex2DNode77.b , tex2DNode77.g , 0.0));
				float MaskB84 = tex2DNode45.b;
				float3 tangentTobjectDir82 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( ( appendResult78 * BasicNoise116 ) * MaskB84 ).xyz ), 0 ) ).xyz;
				float3 lerpResult85 = lerp( lerpResult72 , ( tangentTobjectDir82 * _SideHandIntensity ) , MaskB84);
				float3 FinalVertexOffset318 = ( lerpResult85 * _DisplacementMultiplier );
				
				o.ase_texcoord4.xy = v.texcoord0.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = FinalVertexOffset318;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				float3 positionWS = TransformObjectToWorld( v.positionOS.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.positionWS = positionWS;
				#endif

				o.positionCS = MetaVertexPosition( v.positionOS, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );

				#ifdef EDITOR_VISUALIZATION
					float2 VizUV = 0;
					float4 LightCoord = 0;
					UnityEditorVizData(v.positionOS.xyz, v.texcoord0.xy, v.texcoord1.xy, v.texcoord2.xy, VizUV, LightCoord);
					o.VizUV = float4(VizUV, 0, 0);
					o.LightCoord = LightCoord;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 texcoord0 : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.texcoord0 = v.texcoord0;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.texcoord0 = patch[0].texcoord0 * bary.x + patch[1].texcoord0 * bary.y + patch[2].texcoord0 * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_Albedo = IN.ase_texcoord4.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				float SkullIntensity51 = _SkullIntensity;
				float2 temp_cast_0 = (_NoiseTiling).xx;
				float2 texCoord13 = IN.ase_texcoord4.xy * temp_cast_0 + float2( 0,0 );
				float simplePerlin2D11 = snoise( texCoord13*sin( _TimeParameters.x * 0.25 ) );
				simplePerlin2D11 = simplePerlin2D11*0.5 + 0.5;
				float BasicNoise116 = simplePerlin2D11;
				float2 appendResult171 = (float2(( 0.11 * BasicNoise116 ) , ( BasicNoise116 * 0.04 )));
				float2 texCoord172 = IN.ase_texcoord4.xy * float2( 1,1 ) + appendResult171;
				float2 SkullWave175 = texCoord172;
				float4 tex2DNode35 = tex2D( _TopSkullVDM, SkullWave175 );
				float TopSkullColorMask66 = tex2DNode35.g;
				float clampResult59 = clamp( ( ( SkullIntensity51 * 0.5 ) * TopSkullColorMask66 ) , 0.0 , 0.5 );
				float4 lerpResult56 = lerp( tex2D( _Albedo, uv_Albedo ) , _TopSkullTint , clampResult59);
				float SideHandIntensity75 = _SideHandIntensity;
				float2 appendResult110 = (float2(( -0.01 * BasicNoise116 ) , ( simplePerlin2D11 * 0.04 )));
				float2 texCoord99 = IN.ase_texcoord4.xy * float2( 1,1 ) + appendResult110;
				float2 LeftHandWave103 = texCoord99;
				float4 tex2DNode77 = tex2D( _LeftHandVDM, LeftHandWave103 );
				float SideHandColorMask80 = tex2DNode77.g;
				float clampResult93 = clamp( ( ( SideHandIntensity75 * 0.5 ) * SideHandColorMask80 ) , 0.0 , 0.5 );
				float4 lerpResult94 = lerp( lerpResult56 , _SideHandTint , clampResult93);
				float2 texCoord206 = IN.ase_texcoord4.xy * float2( 3,3 ) + float2( 0,0 );
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles205 = 2.0 * 2.0;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset205 = 1.0f / 2.0;
				float fbrowsoffset205 = 1.0f / 2.0;
				// Speed of animation
				float fbspeed205 = _TimeParameters.x * 12.0;
				// UV Tiling (col and row offset)
				float2 fbtiling205 = float2(fbcolsoffset205, fbrowsoffset205);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex205 = round( fmod( fbspeed205 + 0.0, fbtotaltiles205) );
				fbcurrenttileindex205 += ( fbcurrenttileindex205 < 0) ? fbtotaltiles205 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox205 = round ( fmod ( fbcurrenttileindex205, 2.0 ) );
				// Multiply Offset X by coloffset
				float fboffsetx205 = fblinearindextox205 * fbcolsoffset205;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy205 = round( fmod( ( fbcurrenttileindex205 - fblinearindextox205 ) / 2.0, 2.0 ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy205 = (int)(2.0-1) - fblinearindextoy205;
				// Multiply Offset Y by rowoffset
				float fboffsety205 = fblinearindextoy205 * fbrowsoffset205;
				// UV Offset
				float2 fboffset205 = float2(fboffsetx205, fboffsety205);
				// Flipbook UV
				half2 fbuv205 = texCoord206 * fbtiling205 + fboffset205;
				// *** END Flipbook UV Animation vars ***
				float2 uv_Masks = IN.ase_texcoord4.xy * _Masks_ST.xy + _Masks_ST.zw;
				float4 tex2DNode45 = tex2D( _Masks, uv_Masks );
				float MaskR15 = tex2DNode45.r;
				float4 temp_output_209_0 = ( tex2D( _NoiseFlipbook, fbuv205 ) * MaskR15 );
				float2 uv_ScreenHandsVDM = IN.ase_texcoord4.xy * _ScreenHandsVDM_ST.xy + _ScreenHandsVDM_ST.zw;
				float4 tex2DNode6 = tex2D( _ScreenHandsVDM, uv_ScreenHandsVDM );
				float myVarName244 = tex2DNode6.g;
				float HandIntensity29 = _HandIntensity;
				float clampResult259 = clamp( saturate( ( myVarName244 * ( HandIntensity29 * 0.7 ) ) ) , 0.0 , 0.9 );
				float4 lerpResult252 = lerp( temp_output_209_0 , _TVHandsTint , ( clampResult259 * _ScreenColorTintBlend ));
				float ScreenToggle242 = _ScreenToggle;
				float ScreenToggleSlider283 = ( MaskR15 * ScreenToggle242 );
				float4 lerpResult213 = lerp( lerpResult94 , lerpResult252 , ScreenToggleSlider283);
				float4 FinalBaseColor314 = lerpResult213;
				
				float4 TVNoise214 = temp_output_209_0;
				float2 temp_cast_2 = (_TilingGlow).xx;
				float2 texCoord235 = IN.ase_texcoord4.xy * temp_cast_2 + float2( 0,0 );
				float simplePerlin2D237 = snoise( texCoord235*_TimeParameters.y );
				simplePerlin2D237 = simplePerlin2D237*0.5 + 0.5;
				float HandMaskNoiseEmission263 = clampResult259;
				float4 FinalEmission316 = ( ( ( ( TVNoise214 * _NoiseTint * _GlowIntensity ) * simplePerlin2D237 ) * ( 1.0 - HandMaskNoiseEmission263 ) ) * ScreenToggle242 );
				

				float3 BaseColor = FinalBaseColor314.rgb;
				float3 Emission = FinalEmission316.rgb;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = BaseColor;
				metaInput.Emission = Emission;
				#ifdef EDITOR_VISUALIZATION
					metaInput.VizUV = IN.VizUV.xy;
					metaInput.LightCoord = IN.LightCoord;
				#endif

				return UnityMetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120113


			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_2D

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_NORMAL


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 positionWS : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _ScreenHandsVDM_ST;
			float4 _NoiseTint;
			float4 _NormalHands_ST;
			float4 _Normal_ST;
			float4 _TVHandsTint;
			float4 _TV_MetallicSmoothness_ST;
			float4 _TopSkullTint;
			float4 _SideHandTint;
			float4 _Masks_ST;
			float4 _Albedo_ST;
			float _DisplacementMultiplier;
			float _SideHandIntensity;
			float _SkullIntensity;
			float _ScreenColorTintBlend;
			float _ScreenToggle;
			float _HandIntensity;
			float _NoiseTiling;
			float _GlowIntensity;
			float _TilingGlow;
			float _BaseSmoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _ScreenHandsVDM;
			sampler2D _Masks;
			sampler2D _TopSkullVDM;
			sampler2D _LeftHandVDM;
			sampler2D _Albedo;
			sampler2D _NoiseFlipbook;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float2 uv_ScreenHandsVDM = v.ase_texcoord.xy * _ScreenHandsVDM_ST.xy + _ScreenHandsVDM_ST.zw;
				float4 tex2DNode6 = tex2Dlod( _ScreenHandsVDM, float4( uv_ScreenHandsVDM, 0, 0.0) );
				float4 appendResult5 = (float4(tex2DNode6.r , tex2DNode6.b , tex2DNode6.g , 0.0));
				float2 temp_cast_0 = (_NoiseTiling).xx;
				float2 texCoord13 = v.ase_texcoord.xy * temp_cast_0 + float2( 0,0 );
				float simplePerlin2D11 = snoise( texCoord13*sin( _TimeParameters.x * 0.25 ) );
				simplePerlin2D11 = simplePerlin2D11*0.5 + 0.5;
				float BasicNoise116 = simplePerlin2D11;
				float2 uv_Masks = v.ase_texcoord.xy * _Masks_ST.xy + _Masks_ST.zw;
				float4 tex2DNode45 = tex2Dlod( _Masks, float4( uv_Masks, 0, 0.0) );
				float MaskR15 = tex2DNode45.r;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.normalOS);
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentTobjectDir4 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( ( appendResult5 * BasicNoise116 ) * MaskR15 ).xyz ), 0 ) ).xyz;
				float2 appendResult171 = (float2(( 0.11 * BasicNoise116 ) , ( BasicNoise116 * 0.04 )));
				float2 texCoord172 = v.ase_texcoord.xy * float2( 1,1 ) + appendResult171;
				float2 SkullWave175 = texCoord172;
				float4 tex2DNode35 = tex2Dlod( _TopSkullVDM, float4( SkullWave175, 0, 0.0) );
				float4 appendResult36 = (float4(tex2DNode35.r , tex2DNode35.b , tex2DNode35.g , 0.0));
				float MaskG63 = tex2DNode45.g;
				float3 tangentTobjectDir38 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( appendResult36 * MaskG63 ).xyz ), 0 ) ).xyz;
				float3 lerpResult72 = lerp( ( tangentTobjectDir4 * _HandIntensity ) , ( tangentTobjectDir38 * _SkullIntensity ) , MaskG63);
				float2 appendResult110 = (float2(( -0.01 * BasicNoise116 ) , ( simplePerlin2D11 * 0.04 )));
				float2 texCoord99 = v.ase_texcoord.xy * float2( 1,1 ) + appendResult110;
				float2 LeftHandWave103 = texCoord99;
				float4 tex2DNode77 = tex2Dlod( _LeftHandVDM, float4( LeftHandWave103, 0, 0.0) );
				float4 appendResult78 = (float4(tex2DNode77.r , tex2DNode77.b , tex2DNode77.g , 0.0));
				float MaskB84 = tex2DNode45.b;
				float3 tangentTobjectDir82 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( ( appendResult78 * BasicNoise116 ) * MaskB84 ).xyz ), 0 ) ).xyz;
				float3 lerpResult85 = lerp( lerpResult72 , ( tangentTobjectDir82 * _SideHandIntensity ) , MaskB84);
				float3 FinalVertexOffset318 = ( lerpResult85 * _DisplacementMultiplier );
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = FinalVertexOffset318;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( v.positionOS.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.positionWS = vertexInput.positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.positionCS = vertexInput.positionCS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_Albedo = IN.ase_texcoord2.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				float SkullIntensity51 = _SkullIntensity;
				float2 temp_cast_0 = (_NoiseTiling).xx;
				float2 texCoord13 = IN.ase_texcoord2.xy * temp_cast_0 + float2( 0,0 );
				float simplePerlin2D11 = snoise( texCoord13*sin( _TimeParameters.x * 0.25 ) );
				simplePerlin2D11 = simplePerlin2D11*0.5 + 0.5;
				float BasicNoise116 = simplePerlin2D11;
				float2 appendResult171 = (float2(( 0.11 * BasicNoise116 ) , ( BasicNoise116 * 0.04 )));
				float2 texCoord172 = IN.ase_texcoord2.xy * float2( 1,1 ) + appendResult171;
				float2 SkullWave175 = texCoord172;
				float4 tex2DNode35 = tex2D( _TopSkullVDM, SkullWave175 );
				float TopSkullColorMask66 = tex2DNode35.g;
				float clampResult59 = clamp( ( ( SkullIntensity51 * 0.5 ) * TopSkullColorMask66 ) , 0.0 , 0.5 );
				float4 lerpResult56 = lerp( tex2D( _Albedo, uv_Albedo ) , _TopSkullTint , clampResult59);
				float SideHandIntensity75 = _SideHandIntensity;
				float2 appendResult110 = (float2(( -0.01 * BasicNoise116 ) , ( simplePerlin2D11 * 0.04 )));
				float2 texCoord99 = IN.ase_texcoord2.xy * float2( 1,1 ) + appendResult110;
				float2 LeftHandWave103 = texCoord99;
				float4 tex2DNode77 = tex2D( _LeftHandVDM, LeftHandWave103 );
				float SideHandColorMask80 = tex2DNode77.g;
				float clampResult93 = clamp( ( ( SideHandIntensity75 * 0.5 ) * SideHandColorMask80 ) , 0.0 , 0.5 );
				float4 lerpResult94 = lerp( lerpResult56 , _SideHandTint , clampResult93);
				float2 texCoord206 = IN.ase_texcoord2.xy * float2( 3,3 ) + float2( 0,0 );
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles205 = 2.0 * 2.0;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset205 = 1.0f / 2.0;
				float fbrowsoffset205 = 1.0f / 2.0;
				// Speed of animation
				float fbspeed205 = _TimeParameters.x * 12.0;
				// UV Tiling (col and row offset)
				float2 fbtiling205 = float2(fbcolsoffset205, fbrowsoffset205);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex205 = round( fmod( fbspeed205 + 0.0, fbtotaltiles205) );
				fbcurrenttileindex205 += ( fbcurrenttileindex205 < 0) ? fbtotaltiles205 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox205 = round ( fmod ( fbcurrenttileindex205, 2.0 ) );
				// Multiply Offset X by coloffset
				float fboffsetx205 = fblinearindextox205 * fbcolsoffset205;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy205 = round( fmod( ( fbcurrenttileindex205 - fblinearindextox205 ) / 2.0, 2.0 ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy205 = (int)(2.0-1) - fblinearindextoy205;
				// Multiply Offset Y by rowoffset
				float fboffsety205 = fblinearindextoy205 * fbrowsoffset205;
				// UV Offset
				float2 fboffset205 = float2(fboffsetx205, fboffsety205);
				// Flipbook UV
				half2 fbuv205 = texCoord206 * fbtiling205 + fboffset205;
				// *** END Flipbook UV Animation vars ***
				float2 uv_Masks = IN.ase_texcoord2.xy * _Masks_ST.xy + _Masks_ST.zw;
				float4 tex2DNode45 = tex2D( _Masks, uv_Masks );
				float MaskR15 = tex2DNode45.r;
				float4 temp_output_209_0 = ( tex2D( _NoiseFlipbook, fbuv205 ) * MaskR15 );
				float2 uv_ScreenHandsVDM = IN.ase_texcoord2.xy * _ScreenHandsVDM_ST.xy + _ScreenHandsVDM_ST.zw;
				float4 tex2DNode6 = tex2D( _ScreenHandsVDM, uv_ScreenHandsVDM );
				float myVarName244 = tex2DNode6.g;
				float HandIntensity29 = _HandIntensity;
				float clampResult259 = clamp( saturate( ( myVarName244 * ( HandIntensity29 * 0.7 ) ) ) , 0.0 , 0.9 );
				float4 lerpResult252 = lerp( temp_output_209_0 , _TVHandsTint , ( clampResult259 * _ScreenColorTintBlend ));
				float ScreenToggle242 = _ScreenToggle;
				float ScreenToggleSlider283 = ( MaskR15 * ScreenToggle242 );
				float4 lerpResult213 = lerp( lerpResult94 , lerpResult252 , ScreenToggleSlider283);
				float4 FinalBaseColor314 = lerpResult213;
				

				float3 BaseColor = FinalBaseColor314.rgb;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				half4 color = half4(BaseColor, Alpha );

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				return color;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthNormals"
			Tags { "LightMode"="DepthNormals" }

			ZWrite On
			Blend One Zero
			ZTest LEqual
			ZWrite On

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120113


			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_TANGENT
			#define ASE_NEEDS_VERT_NORMAL


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float4 worldTangent : TEXCOORD2;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 positionWS : TEXCOORD3;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD4;
				#endif
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _ScreenHandsVDM_ST;
			float4 _NoiseTint;
			float4 _NormalHands_ST;
			float4 _Normal_ST;
			float4 _TVHandsTint;
			float4 _TV_MetallicSmoothness_ST;
			float4 _TopSkullTint;
			float4 _SideHandTint;
			float4 _Masks_ST;
			float4 _Albedo_ST;
			float _DisplacementMultiplier;
			float _SideHandIntensity;
			float _SkullIntensity;
			float _ScreenColorTintBlend;
			float _ScreenToggle;
			float _HandIntensity;
			float _NoiseTiling;
			float _GlowIntensity;
			float _TilingGlow;
			float _BaseSmoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _ScreenHandsVDM;
			sampler2D _Masks;
			sampler2D _TopSkullVDM;
			sampler2D _LeftHandVDM;
			sampler2D _Normal;
			sampler2D _NormalHands;
			sampler2D _NormalTopSkull;
			sampler2D _NormalsLeftHand;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 uv_ScreenHandsVDM = v.ase_texcoord.xy * _ScreenHandsVDM_ST.xy + _ScreenHandsVDM_ST.zw;
				float4 tex2DNode6 = tex2Dlod( _ScreenHandsVDM, float4( uv_ScreenHandsVDM, 0, 0.0) );
				float4 appendResult5 = (float4(tex2DNode6.r , tex2DNode6.b , tex2DNode6.g , 0.0));
				float2 temp_cast_0 = (_NoiseTiling).xx;
				float2 texCoord13 = v.ase_texcoord.xy * temp_cast_0 + float2( 0,0 );
				float simplePerlin2D11 = snoise( texCoord13*sin( _TimeParameters.x * 0.25 ) );
				simplePerlin2D11 = simplePerlin2D11*0.5 + 0.5;
				float BasicNoise116 = simplePerlin2D11;
				float2 uv_Masks = v.ase_texcoord.xy * _Masks_ST.xy + _Masks_ST.zw;
				float4 tex2DNode45 = tex2Dlod( _Masks, float4( uv_Masks, 0, 0.0) );
				float MaskR15 = tex2DNode45.r;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.tangentOS.xyz);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.normalOS);
				float ase_vertexTangentSign = v.tangentOS.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentTobjectDir4 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( ( appendResult5 * BasicNoise116 ) * MaskR15 ).xyz ), 0 ) ).xyz;
				float2 appendResult171 = (float2(( 0.11 * BasicNoise116 ) , ( BasicNoise116 * 0.04 )));
				float2 texCoord172 = v.ase_texcoord.xy * float2( 1,1 ) + appendResult171;
				float2 SkullWave175 = texCoord172;
				float4 tex2DNode35 = tex2Dlod( _TopSkullVDM, float4( SkullWave175, 0, 0.0) );
				float4 appendResult36 = (float4(tex2DNode35.r , tex2DNode35.b , tex2DNode35.g , 0.0));
				float MaskG63 = tex2DNode45.g;
				float3 tangentTobjectDir38 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( appendResult36 * MaskG63 ).xyz ), 0 ) ).xyz;
				float3 lerpResult72 = lerp( ( tangentTobjectDir4 * _HandIntensity ) , ( tangentTobjectDir38 * _SkullIntensity ) , MaskG63);
				float2 appendResult110 = (float2(( -0.01 * BasicNoise116 ) , ( simplePerlin2D11 * 0.04 )));
				float2 texCoord99 = v.ase_texcoord.xy * float2( 1,1 ) + appendResult110;
				float2 LeftHandWave103 = texCoord99;
				float4 tex2DNode77 = tex2Dlod( _LeftHandVDM, float4( LeftHandWave103, 0, 0.0) );
				float4 appendResult78 = (float4(tex2DNode77.r , tex2DNode77.b , tex2DNode77.g , 0.0));
				float MaskB84 = tex2DNode45.b;
				float3 tangentTobjectDir82 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( ( appendResult78 * BasicNoise116 ) * MaskB84 ).xyz ), 0 ) ).xyz;
				float3 lerpResult85 = lerp( lerpResult72 , ( tangentTobjectDir82 * _SideHandIntensity ) , MaskB84);
				float3 FinalVertexOffset318 = ( lerpResult85 * _DisplacementMultiplier );
				
				o.ase_texcoord5.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord5.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = FinalVertexOffset318;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;
				v.tangentOS = v.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( v.positionOS.xyz );

				float3 normalWS = TransformObjectToWorldNormal( v.normalOS );
				float4 tangentWS = float4( TransformObjectToWorldDir( v.tangentOS.xyz ), v.tangentOS.w );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.positionWS = vertexInput.positionWS;
				#endif

				o.worldNormal = normalWS;
				o.worldTangent = tangentWS;

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.positionCS = vertexInput.positionCS;
				o.clipPosV = vertexInput.positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.tangentOS = v.tangentOS;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(	VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.positionWS;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float3 WorldNormal = IN.worldNormal;
				float4 WorldTangent = IN.worldTangent;

				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_Masks = IN.ase_texcoord5.xy * _Masks_ST.xy + _Masks_ST.zw;
				float4 tex2DNode45 = tex2D( _Masks, uv_Masks );
				float MaskR15 = tex2DNode45.r;
				float MaskG63 = tex2DNode45.g;
				float MaskB84 = tex2DNode45.b;
				float3 appendResult20 = (float3(MaskR15 , MaskG63 , MaskB84));
				float2 uv_Normal = IN.ase_texcoord5.xy * _Normal_ST.xy + _Normal_ST.zw;
				float2 uv_NormalHands = IN.ase_texcoord5.xy * _NormalHands_ST.xy + _NormalHands_ST.zw;
				float HandIntensity29 = _HandIntensity;
				float clampResult32 = clamp( HandIntensity29 , 0.0 , 1.0 );
				float3 unpack21 = UnpackNormalScale( tex2D( _NormalHands, uv_NormalHands ), clampResult32 );
				unpack21.z = lerp( 1, unpack21.z, saturate(clampResult32) );
				float2 temp_cast_0 = (_NoiseTiling).xx;
				float2 texCoord13 = IN.ase_texcoord5.xy * temp_cast_0 + float2( 0,0 );
				float simplePerlin2D11 = snoise( texCoord13*sin( _TimeParameters.x * 0.25 ) );
				simplePerlin2D11 = simplePerlin2D11*0.5 + 0.5;
				float BasicNoise116 = simplePerlin2D11;
				float2 appendResult171 = (float2(( 0.11 * BasicNoise116 ) , ( BasicNoise116 * 0.04 )));
				float2 texCoord172 = IN.ase_texcoord5.xy * float2( 1,1 ) + appendResult171;
				float2 SkullWave175 = texCoord172;
				float SkullIntensity51 = _SkullIntensity;
				float clampResult53 = clamp( SkullIntensity51 , 0.0 , 1.0 );
				float3 unpack50 = UnpackNormalScale( tex2D( _NormalTopSkull, SkullWave175 ), clampResult53 );
				unpack50.z = lerp( 1, unpack50.z, saturate(clampResult53) );
				float2 appendResult110 = (float2(( -0.01 * BasicNoise116 ) , ( simplePerlin2D11 * 0.04 )));
				float2 texCoord99 = IN.ase_texcoord5.xy * float2( 1,1 ) + appendResult110;
				float2 LeftHandWave103 = texCoord99;
				float SideHandIntensity75 = _SideHandIntensity;
				float clampResult98 = clamp( SideHandIntensity75 , 0.0 , 1.0 );
				float3 unpack96 = UnpackNormalScale( tex2D( _NormalsLeftHand, LeftHandWave103 ), clampResult98 );
				unpack96.z = lerp( 1, unpack96.z, saturate(clampResult98) );
				float3 layeredBlendVar18 = appendResult20;
				float3 layeredBlend18 = ( lerp( lerp( lerp( UnpackNormalScale( tex2D( _Normal, uv_Normal ), 1.0f ) , unpack21 , layeredBlendVar18.x ) , unpack50 , layeredBlendVar18.y ) , unpack96 , layeredBlendVar18.z ) );
				float3 normalizeResult19 = normalize( layeredBlend18 );
				float3 FinalNormal315 = normalizeResult19;
				

				float3 Normal = FinalNormal315;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.positionCS.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				#if defined(_GBUFFER_NORMALS_OCT)
					float2 octNormalWS = PackNormalOctQuadEncode(WorldNormal);
					float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);
					half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);
					return half4(packedNormalWS, 0.0);
				#else
					#if defined(_NORMALMAP)
						#if _NORMAL_DROPOFF_TS
							float crossSign = (WorldTangent.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
							float3 bitangent = crossSign * cross(WorldNormal.xyz, WorldTangent.xyz);
							float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent.xyz, bitangent, WorldNormal.xyz));
						#elif _NORMAL_DROPOFF_OS
							float3 normalWS = TransformObjectToWorldNormal(Normal);
						#elif _NORMAL_DROPOFF_WS
							float3 normalWS = Normal;
						#endif
					#else
						float3 normalWS = WorldNormal;
					#endif
					return half4(NormalizeNormalPerPixel(normalWS), 0.0);
				#endif
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "GBuffer"
			Tags { "LightMode"="UniversalGBuffer" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120113


			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _LIGHT_LAYERS
			#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED

			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_GBUFFER

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#define ASE_NEEDS_VERT_TANGENT
			#define ASE_NEEDS_VERT_NORMAL


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float4 lightmapUVOrVertexSH : TEXCOORD1;
				half4 fogFactorAndVertexLight : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD6;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
				float2 dynamicLightmapUV : TEXCOORD7;
				#endif
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _ScreenHandsVDM_ST;
			float4 _NoiseTint;
			float4 _NormalHands_ST;
			float4 _Normal_ST;
			float4 _TVHandsTint;
			float4 _TV_MetallicSmoothness_ST;
			float4 _TopSkullTint;
			float4 _SideHandTint;
			float4 _Masks_ST;
			float4 _Albedo_ST;
			float _DisplacementMultiplier;
			float _SideHandIntensity;
			float _SkullIntensity;
			float _ScreenColorTintBlend;
			float _ScreenToggle;
			float _HandIntensity;
			float _NoiseTiling;
			float _GlowIntensity;
			float _TilingGlow;
			float _BaseSmoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _ScreenHandsVDM;
			sampler2D _Masks;
			sampler2D _TopSkullVDM;
			sampler2D _LeftHandVDM;
			sampler2D _Albedo;
			sampler2D _NoiseFlipbook;
			sampler2D _Normal;
			sampler2D _NormalHands;
			sampler2D _NormalTopSkull;
			sampler2D _NormalsLeftHand;
			sampler2D _TV_MetallicSmoothness;


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"

			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 uv_ScreenHandsVDM = v.texcoord.xy * _ScreenHandsVDM_ST.xy + _ScreenHandsVDM_ST.zw;
				float4 tex2DNode6 = tex2Dlod( _ScreenHandsVDM, float4( uv_ScreenHandsVDM, 0, 0.0) );
				float4 appendResult5 = (float4(tex2DNode6.r , tex2DNode6.b , tex2DNode6.g , 0.0));
				float2 temp_cast_0 = (_NoiseTiling).xx;
				float2 texCoord13 = v.texcoord.xy * temp_cast_0 + float2( 0,0 );
				float simplePerlin2D11 = snoise( texCoord13*sin( _TimeParameters.x * 0.25 ) );
				simplePerlin2D11 = simplePerlin2D11*0.5 + 0.5;
				float BasicNoise116 = simplePerlin2D11;
				float2 uv_Masks = v.texcoord.xy * _Masks_ST.xy + _Masks_ST.zw;
				float4 tex2DNode45 = tex2Dlod( _Masks, float4( uv_Masks, 0, 0.0) );
				float MaskR15 = tex2DNode45.r;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.tangentOS.xyz);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.normalOS);
				float ase_vertexTangentSign = v.tangentOS.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentTobjectDir4 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( ( appendResult5 * BasicNoise116 ) * MaskR15 ).xyz ), 0 ) ).xyz;
				float2 appendResult171 = (float2(( 0.11 * BasicNoise116 ) , ( BasicNoise116 * 0.04 )));
				float2 texCoord172 = v.texcoord.xy * float2( 1,1 ) + appendResult171;
				float2 SkullWave175 = texCoord172;
				float4 tex2DNode35 = tex2Dlod( _TopSkullVDM, float4( SkullWave175, 0, 0.0) );
				float4 appendResult36 = (float4(tex2DNode35.r , tex2DNode35.b , tex2DNode35.g , 0.0));
				float MaskG63 = tex2DNode45.g;
				float3 tangentTobjectDir38 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( appendResult36 * MaskG63 ).xyz ), 0 ) ).xyz;
				float3 lerpResult72 = lerp( ( tangentTobjectDir4 * _HandIntensity ) , ( tangentTobjectDir38 * _SkullIntensity ) , MaskG63);
				float2 appendResult110 = (float2(( -0.01 * BasicNoise116 ) , ( simplePerlin2D11 * 0.04 )));
				float2 texCoord99 = v.texcoord.xy * float2( 1,1 ) + appendResult110;
				float2 LeftHandWave103 = texCoord99;
				float4 tex2DNode77 = tex2Dlod( _LeftHandVDM, float4( LeftHandWave103, 0, 0.0) );
				float4 appendResult78 = (float4(tex2DNode77.r , tex2DNode77.b , tex2DNode77.g , 0.0));
				float MaskB84 = tex2DNode45.b;
				float3 tangentTobjectDir82 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( ( appendResult78 * BasicNoise116 ) * MaskB84 ).xyz ), 0 ) ).xyz;
				float3 lerpResult85 = lerp( lerpResult72 , ( tangentTobjectDir82 * _SideHandIntensity ) , MaskB84);
				float3 FinalVertexOffset318 = ( lerpResult85 * _DisplacementMultiplier );
				
				o.ase_texcoord8.xy = v.texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord8.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = FinalVertexOffset318;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;
				v.tangentOS = v.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( v.positionOS.xyz );
				VertexNormalInputs normalInput = GetVertexNormalInputs( v.normalOS, v.tangentOS );

				o.tSpace0 = float4( normalInput.normalWS, vertexInput.positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, vertexInput.positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, vertexInput.positionWS.z);

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					o.dynamicLightmapUV.xy = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if !defined(LIGHTMAP_ON)
					OUTPUT_SH(normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz);
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord.xy;
					o.lightmapUVOrVertexSH.xy = v.texcoord.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( vertexInput.positionWS, normalInput.normalWS );

				o.fogFactorAndVertexLight = half4(0, vertexLight);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.positionCS = vertexInput.positionCS;
				o.clipPosV = vertexInput.positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.tangentOS = v.tangentOS;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			FragmentOutput frag ( VertexOutput IN
								#ifdef ASE_DEPTH_WRITE_ON
								,out float outputDepth : ASE_SV_DEPTH
								#endif
								 )
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.positionCS.xyz, unity_LODFade.x );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif

				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				float2 NormalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.positionCS);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#else
					ShadowCoords = float4(0, 0, 0, 0);
				#endif

				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float2 uv_Albedo = IN.ase_texcoord8.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				float SkullIntensity51 = _SkullIntensity;
				float2 temp_cast_0 = (_NoiseTiling).xx;
				float2 texCoord13 = IN.ase_texcoord8.xy * temp_cast_0 + float2( 0,0 );
				float simplePerlin2D11 = snoise( texCoord13*sin( _TimeParameters.x * 0.25 ) );
				simplePerlin2D11 = simplePerlin2D11*0.5 + 0.5;
				float BasicNoise116 = simplePerlin2D11;
				float2 appendResult171 = (float2(( 0.11 * BasicNoise116 ) , ( BasicNoise116 * 0.04 )));
				float2 texCoord172 = IN.ase_texcoord8.xy * float2( 1,1 ) + appendResult171;
				float2 SkullWave175 = texCoord172;
				float4 tex2DNode35 = tex2D( _TopSkullVDM, SkullWave175 );
				float TopSkullColorMask66 = tex2DNode35.g;
				float clampResult59 = clamp( ( ( SkullIntensity51 * 0.5 ) * TopSkullColorMask66 ) , 0.0 , 0.5 );
				float4 lerpResult56 = lerp( tex2D( _Albedo, uv_Albedo ) , _TopSkullTint , clampResult59);
				float SideHandIntensity75 = _SideHandIntensity;
				float2 appendResult110 = (float2(( -0.01 * BasicNoise116 ) , ( simplePerlin2D11 * 0.04 )));
				float2 texCoord99 = IN.ase_texcoord8.xy * float2( 1,1 ) + appendResult110;
				float2 LeftHandWave103 = texCoord99;
				float4 tex2DNode77 = tex2D( _LeftHandVDM, LeftHandWave103 );
				float SideHandColorMask80 = tex2DNode77.g;
				float clampResult93 = clamp( ( ( SideHandIntensity75 * 0.5 ) * SideHandColorMask80 ) , 0.0 , 0.5 );
				float4 lerpResult94 = lerp( lerpResult56 , _SideHandTint , clampResult93);
				float2 texCoord206 = IN.ase_texcoord8.xy * float2( 3,3 ) + float2( 0,0 );
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles205 = 2.0 * 2.0;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset205 = 1.0f / 2.0;
				float fbrowsoffset205 = 1.0f / 2.0;
				// Speed of animation
				float fbspeed205 = _TimeParameters.x * 12.0;
				// UV Tiling (col and row offset)
				float2 fbtiling205 = float2(fbcolsoffset205, fbrowsoffset205);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex205 = round( fmod( fbspeed205 + 0.0, fbtotaltiles205) );
				fbcurrenttileindex205 += ( fbcurrenttileindex205 < 0) ? fbtotaltiles205 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox205 = round ( fmod ( fbcurrenttileindex205, 2.0 ) );
				// Multiply Offset X by coloffset
				float fboffsetx205 = fblinearindextox205 * fbcolsoffset205;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy205 = round( fmod( ( fbcurrenttileindex205 - fblinearindextox205 ) / 2.0, 2.0 ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy205 = (int)(2.0-1) - fblinearindextoy205;
				// Multiply Offset Y by rowoffset
				float fboffsety205 = fblinearindextoy205 * fbrowsoffset205;
				// UV Offset
				float2 fboffset205 = float2(fboffsetx205, fboffsety205);
				// Flipbook UV
				half2 fbuv205 = texCoord206 * fbtiling205 + fboffset205;
				// *** END Flipbook UV Animation vars ***
				float2 uv_Masks = IN.ase_texcoord8.xy * _Masks_ST.xy + _Masks_ST.zw;
				float4 tex2DNode45 = tex2D( _Masks, uv_Masks );
				float MaskR15 = tex2DNode45.r;
				float4 temp_output_209_0 = ( tex2D( _NoiseFlipbook, fbuv205 ) * MaskR15 );
				float2 uv_ScreenHandsVDM = IN.ase_texcoord8.xy * _ScreenHandsVDM_ST.xy + _ScreenHandsVDM_ST.zw;
				float4 tex2DNode6 = tex2D( _ScreenHandsVDM, uv_ScreenHandsVDM );
				float myVarName244 = tex2DNode6.g;
				float HandIntensity29 = _HandIntensity;
				float clampResult259 = clamp( saturate( ( myVarName244 * ( HandIntensity29 * 0.7 ) ) ) , 0.0 , 0.9 );
				float4 lerpResult252 = lerp( temp_output_209_0 , _TVHandsTint , ( clampResult259 * _ScreenColorTintBlend ));
				float ScreenToggle242 = _ScreenToggle;
				float ScreenToggleSlider283 = ( MaskR15 * ScreenToggle242 );
				float4 lerpResult213 = lerp( lerpResult94 , lerpResult252 , ScreenToggleSlider283);
				float4 FinalBaseColor314 = lerpResult213;
				
				float MaskG63 = tex2DNode45.g;
				float MaskB84 = tex2DNode45.b;
				float3 appendResult20 = (float3(MaskR15 , MaskG63 , MaskB84));
				float2 uv_Normal = IN.ase_texcoord8.xy * _Normal_ST.xy + _Normal_ST.zw;
				float2 uv_NormalHands = IN.ase_texcoord8.xy * _NormalHands_ST.xy + _NormalHands_ST.zw;
				float clampResult32 = clamp( HandIntensity29 , 0.0 , 1.0 );
				float3 unpack21 = UnpackNormalScale( tex2D( _NormalHands, uv_NormalHands ), clampResult32 );
				unpack21.z = lerp( 1, unpack21.z, saturate(clampResult32) );
				float clampResult53 = clamp( SkullIntensity51 , 0.0 , 1.0 );
				float3 unpack50 = UnpackNormalScale( tex2D( _NormalTopSkull, SkullWave175 ), clampResult53 );
				unpack50.z = lerp( 1, unpack50.z, saturate(clampResult53) );
				float clampResult98 = clamp( SideHandIntensity75 , 0.0 , 1.0 );
				float3 unpack96 = UnpackNormalScale( tex2D( _NormalsLeftHand, LeftHandWave103 ), clampResult98 );
				unpack96.z = lerp( 1, unpack96.z, saturate(clampResult98) );
				float3 layeredBlendVar18 = appendResult20;
				float3 layeredBlend18 = ( lerp( lerp( lerp( UnpackNormalScale( tex2D( _Normal, uv_Normal ), 1.0f ) , unpack21 , layeredBlendVar18.x ) , unpack50 , layeredBlendVar18.y ) , unpack96 , layeredBlendVar18.z ) );
				float3 normalizeResult19 = normalize( layeredBlend18 );
				float3 FinalNormal315 = normalizeResult19;
				
				float4 TVNoise214 = temp_output_209_0;
				float2 temp_cast_2 = (_TilingGlow).xx;
				float2 texCoord235 = IN.ase_texcoord8.xy * temp_cast_2 + float2( 0,0 );
				float simplePerlin2D237 = snoise( texCoord235*_TimeParameters.y );
				simplePerlin2D237 = simplePerlin2D237*0.5 + 0.5;
				float HandMaskNoiseEmission263 = clampResult259;
				float4 FinalEmission316 = ( ( ( ( TVNoise214 * _NoiseTint * _GlowIntensity ) * simplePerlin2D237 ) * ( 1.0 - HandMaskNoiseEmission263 ) ) * ScreenToggle242 );
				
				float2 uv_TV_MetallicSmoothness = IN.ase_texcoord8.xy * _TV_MetallicSmoothness_ST.xy + _TV_MetallicSmoothness_ST.zw;
				float FinalSmoothness317 = ( tex2D( _TV_MetallicSmoothness, uv_TV_MetallicSmoothness ).a * _BaseSmoothness );
				

				float3 BaseColor = FinalBaseColor314.rgb;
				float3 Normal = FinalNormal315;
				float3 Emission = FinalEmission316.rgb;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = FinalSmoothness317;
				float Occlusion = 1;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = WorldPosition;
				inputData.positionCS = IN.positionCS;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
					#if _NORMAL_DROPOFF_TS
						inputData.normalWS = TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
					#elif _NORMAL_DROPOFF_OS
						inputData.normalWS = TransformObjectToWorldNormal(Normal);
					#elif _NORMAL_DROPOFF_WS
						inputData.normalWS = Normal;
					#endif
				#else
					inputData.normalWS = WorldNormal;
				#endif

				inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				inputData.viewDirectionWS = SafeNormalize( WorldViewDirection );

				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				#ifdef ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#else
					#if defined(DYNAMICLIGHTMAP_ON)
						inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, IN.dynamicLightmapUV.xy, SH, inputData.normalWS);
					#else
						inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );
					#endif
				#endif

				inputData.normalizedScreenSpaceUV = NormalizedScreenSpaceUV;
				inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUVOrVertexSH.xy);

				#if defined(DEBUG_DISPLAY)
					#if defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = IN.dynamicLightmapUV.xy;
						#endif
					#if defined(LIGHTMAP_ON)
						inputData.staticLightmapUV = IN.lightmapUVOrVertexSH.xy;
					#else
						inputData.vertexSH = SH;
					#endif
				#endif

				#ifdef _DBUFFER
					ApplyDecal(IN.positionCS,
						BaseColor,
						Specular,
						inputData.normalWS,
						Metallic,
						Occlusion,
						Smoothness);
				#endif

				BRDFData brdfData;
				InitializeBRDFData
				(BaseColor, Metallic, Specular, Smoothness, Alpha, brdfData);

				Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask);
				half4 color;
				MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, inputData.shadowMask);
				color.rgb = GlobalIllumination(brdfData, inputData.bakedGI, Occlusion, inputData.positionWS, inputData.normalWS, inputData.viewDirectionWS);
				color.a = Alpha;

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return BRDFDataToGbuffer(brdfData, inputData, Smoothness, Emission + color.rgb, Occlusion);
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "SceneSelectionPass"
			Tags { "LightMode"="SceneSelectionPass" }

			Cull Off
			AlphaToMask Off

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120113


			#pragma vertex vert
			#pragma fragment frag

			#define SCENESELECTIONPASS 1

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_NORMAL


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _ScreenHandsVDM_ST;
			float4 _NoiseTint;
			float4 _NormalHands_ST;
			float4 _Normal_ST;
			float4 _TVHandsTint;
			float4 _TV_MetallicSmoothness_ST;
			float4 _TopSkullTint;
			float4 _SideHandTint;
			float4 _Masks_ST;
			float4 _Albedo_ST;
			float _DisplacementMultiplier;
			float _SideHandIntensity;
			float _SkullIntensity;
			float _ScreenColorTintBlend;
			float _ScreenToggle;
			float _HandIntensity;
			float _NoiseTiling;
			float _GlowIntensity;
			float _TilingGlow;
			float _BaseSmoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _ScreenHandsVDM;
			sampler2D _Masks;
			sampler2D _TopSkullVDM;
			sampler2D _LeftHandVDM;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 uv_ScreenHandsVDM = v.ase_texcoord.xy * _ScreenHandsVDM_ST.xy + _ScreenHandsVDM_ST.zw;
				float4 tex2DNode6 = tex2Dlod( _ScreenHandsVDM, float4( uv_ScreenHandsVDM, 0, 0.0) );
				float4 appendResult5 = (float4(tex2DNode6.r , tex2DNode6.b , tex2DNode6.g , 0.0));
				float2 temp_cast_0 = (_NoiseTiling).xx;
				float2 texCoord13 = v.ase_texcoord.xy * temp_cast_0 + float2( 0,0 );
				float simplePerlin2D11 = snoise( texCoord13*sin( _TimeParameters.x * 0.25 ) );
				simplePerlin2D11 = simplePerlin2D11*0.5 + 0.5;
				float BasicNoise116 = simplePerlin2D11;
				float2 uv_Masks = v.ase_texcoord.xy * _Masks_ST.xy + _Masks_ST.zw;
				float4 tex2DNode45 = tex2Dlod( _Masks, float4( uv_Masks, 0, 0.0) );
				float MaskR15 = tex2DNode45.r;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.normalOS);
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentTobjectDir4 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( ( appendResult5 * BasicNoise116 ) * MaskR15 ).xyz ), 0 ) ).xyz;
				float2 appendResult171 = (float2(( 0.11 * BasicNoise116 ) , ( BasicNoise116 * 0.04 )));
				float2 texCoord172 = v.ase_texcoord.xy * float2( 1,1 ) + appendResult171;
				float2 SkullWave175 = texCoord172;
				float4 tex2DNode35 = tex2Dlod( _TopSkullVDM, float4( SkullWave175, 0, 0.0) );
				float4 appendResult36 = (float4(tex2DNode35.r , tex2DNode35.b , tex2DNode35.g , 0.0));
				float MaskG63 = tex2DNode45.g;
				float3 tangentTobjectDir38 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( appendResult36 * MaskG63 ).xyz ), 0 ) ).xyz;
				float3 lerpResult72 = lerp( ( tangentTobjectDir4 * _HandIntensity ) , ( tangentTobjectDir38 * _SkullIntensity ) , MaskG63);
				float2 appendResult110 = (float2(( -0.01 * BasicNoise116 ) , ( simplePerlin2D11 * 0.04 )));
				float2 texCoord99 = v.ase_texcoord.xy * float2( 1,1 ) + appendResult110;
				float2 LeftHandWave103 = texCoord99;
				float4 tex2DNode77 = tex2Dlod( _LeftHandVDM, float4( LeftHandWave103, 0, 0.0) );
				float4 appendResult78 = (float4(tex2DNode77.r , tex2DNode77.b , tex2DNode77.g , 0.0));
				float MaskB84 = tex2DNode45.b;
				float3 tangentTobjectDir82 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( ( appendResult78 * BasicNoise116 ) * MaskB84 ).xyz ), 0 ) ).xyz;
				float3 lerpResult85 = lerp( lerpResult72 , ( tangentTobjectDir82 * _SideHandIntensity ) , MaskB84);
				float3 FinalVertexOffset318 = ( lerpResult85 * _DisplacementMultiplier );
				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = FinalVertexOffset318;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				float3 positionWS = TransformObjectToWorld( v.positionOS.xyz );

				o.positionCS = TransformWorldToHClip(positionWS);

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				

				surfaceDescription.Alpha = 1;
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;

				#ifdef SCENESELECTIONPASS
					outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				#elif defined(SCENEPICKINGPASS)
					outColor = _SelectionID;
				#endif

				return outColor;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ScenePickingPass"
			Tags { "LightMode"="Picking" }

			AlphaToMask Off

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120113


			#pragma vertex vert
			#pragma fragment frag

		    #define SCENEPICKINGPASS 1

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_NORMAL


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _ScreenHandsVDM_ST;
			float4 _NoiseTint;
			float4 _NormalHands_ST;
			float4 _Normal_ST;
			float4 _TVHandsTint;
			float4 _TV_MetallicSmoothness_ST;
			float4 _TopSkullTint;
			float4 _SideHandTint;
			float4 _Masks_ST;
			float4 _Albedo_ST;
			float _DisplacementMultiplier;
			float _SideHandIntensity;
			float _SkullIntensity;
			float _ScreenColorTintBlend;
			float _ScreenToggle;
			float _HandIntensity;
			float _NoiseTiling;
			float _GlowIntensity;
			float _TilingGlow;
			float _BaseSmoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _ScreenHandsVDM;
			sampler2D _Masks;
			sampler2D _TopSkullVDM;
			sampler2D _LeftHandVDM;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 uv_ScreenHandsVDM = v.ase_texcoord.xy * _ScreenHandsVDM_ST.xy + _ScreenHandsVDM_ST.zw;
				float4 tex2DNode6 = tex2Dlod( _ScreenHandsVDM, float4( uv_ScreenHandsVDM, 0, 0.0) );
				float4 appendResult5 = (float4(tex2DNode6.r , tex2DNode6.b , tex2DNode6.g , 0.0));
				float2 temp_cast_0 = (_NoiseTiling).xx;
				float2 texCoord13 = v.ase_texcoord.xy * temp_cast_0 + float2( 0,0 );
				float simplePerlin2D11 = snoise( texCoord13*sin( _TimeParameters.x * 0.25 ) );
				simplePerlin2D11 = simplePerlin2D11*0.5 + 0.5;
				float BasicNoise116 = simplePerlin2D11;
				float2 uv_Masks = v.ase_texcoord.xy * _Masks_ST.xy + _Masks_ST.zw;
				float4 tex2DNode45 = tex2Dlod( _Masks, float4( uv_Masks, 0, 0.0) );
				float MaskR15 = tex2DNode45.r;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.normalOS);
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentTobjectDir4 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( ( appendResult5 * BasicNoise116 ) * MaskR15 ).xyz ), 0 ) ).xyz;
				float2 appendResult171 = (float2(( 0.11 * BasicNoise116 ) , ( BasicNoise116 * 0.04 )));
				float2 texCoord172 = v.ase_texcoord.xy * float2( 1,1 ) + appendResult171;
				float2 SkullWave175 = texCoord172;
				float4 tex2DNode35 = tex2Dlod( _TopSkullVDM, float4( SkullWave175, 0, 0.0) );
				float4 appendResult36 = (float4(tex2DNode35.r , tex2DNode35.b , tex2DNode35.g , 0.0));
				float MaskG63 = tex2DNode45.g;
				float3 tangentTobjectDir38 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( appendResult36 * MaskG63 ).xyz ), 0 ) ).xyz;
				float3 lerpResult72 = lerp( ( tangentTobjectDir4 * _HandIntensity ) , ( tangentTobjectDir38 * _SkullIntensity ) , MaskG63);
				float2 appendResult110 = (float2(( -0.01 * BasicNoise116 ) , ( simplePerlin2D11 * 0.04 )));
				float2 texCoord99 = v.ase_texcoord.xy * float2( 1,1 ) + appendResult110;
				float2 LeftHandWave103 = texCoord99;
				float4 tex2DNode77 = tex2Dlod( _LeftHandVDM, float4( LeftHandWave103, 0, 0.0) );
				float4 appendResult78 = (float4(tex2DNode77.r , tex2DNode77.b , tex2DNode77.g , 0.0));
				float MaskB84 = tex2DNode45.b;
				float3 tangentTobjectDir82 = mul( GetWorldToObjectMatrix(), float4( mul( ase_tangentToWorldFast, ( ( appendResult78 * BasicNoise116 ) * MaskB84 ).xyz ), 0 ) ).xyz;
				float3 lerpResult85 = lerp( lerpResult72 , ( tangentTobjectDir82 * _SideHandIntensity ) , MaskB84);
				float3 FinalVertexOffset318 = ( lerpResult85 * _DisplacementMultiplier );
				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = FinalVertexOffset318;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.positionOS.xyz = vertexValue;
				#else
					v.positionOS.xyz += vertexValue;
				#endif

				v.normalOS = v.normalOS;

				float3 positionWS = TransformObjectToWorld( v.positionOS.xyz );
				o.positionCS = TransformWorldToHClip(positionWS);

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.positionOS;
				o.normalOS = v.normalOS;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.positionOS = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.positionOS.xyz - patch[i].normalOS * (dot(o.positionOS.xyz, patch[i].normalOS) - dot(patch[i].vertex.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				o.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				

				surfaceDescription.Alpha = 1;
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
						clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;

				#ifdef SCENESELECTIONPASS
					outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				#elif defined(SCENEPICKINGPASS)
					outColor = _SelectionID;
				#endif

				return outColor;
			}

			ENDHLSL
		}
		
	}
	
	CustomEditor "UnityEditor.ShaderGraphLitGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19302
Node;AmplifyShaderEditor.CommentaryNode;313;-5389.939,337.5533;Inherit;False;5734.147;1973.72;VDM;8;302;95;71;34;299;300;298;318;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;298;-5339.939,1565.909;Inherit;False;1044.41;393.6719;;5;10;12;13;11;116;Basic noise for fake anim, use whatever you need.;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-5289.939,1728.582;Inherit;False;Property;_NoiseTiling;Noise Tiling;4;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;13;-5131.452,1615.909;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinTimeNode;12;-5098.661,1776.581;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;11;-4894.134,1689.001;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;300;-4526.591,905.1403;Inherit;False;1295.137;427.7112;Setting some limits, avoiding seams - optional;8;174;173;168;169;170;171;172;175;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;299;-4105.746,1637.576;Inherit;False;961.709;427.7114;Setting some limits, avoiding seams - optional;7;108;111;112;107;110;99;103;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;116;-4519.534,1723.197;Inherit;False;BasicNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;168;-4476.591,1052.13;Inherit;False;116;BasicNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;174;-4284.83,1209.893;Inherit;False;Constant;_Float1;Float 1;19;0;Create;True;0;0;0;False;0;False;0.04;0.04;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;173;-4240.395,955.1403;Inherit;False;Constant;_Float3;Float 3;16;0;Create;True;0;0;0;False;0;False;0.11;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;-4082.311,1692.576;Inherit;False;Constant;_Float2;Float 2;14;0;Create;True;0;0;0;False;0;False;-0.01;-0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-4072.746,1942.329;Inherit;False;Constant;_Float0;Float 0;18;0;Create;True;0;0;0;False;0;False;0.04;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;169;-4095.375,1017.851;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;170;-4077.375,1197.851;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;-3841.293,1748.287;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;-3848.293,1930.287;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;288;-2110.347,-2219.174;Inherit;False;1554.723;1078.986;Normal Combine;20;19;15;97;98;114;52;30;53;176;32;96;50;21;2;18;20;84;63;45;311;;0,0.3949246,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;171;-3951.376,1080.851;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;110;-3722.292,1813.287;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;34;-3360.536,387.5533;Inherit;False;1795.94;448.062;Screen Hand;12;182;5;181;7;4;16;48;17;29;8;244;6;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;45;-2078.397,-2129.427;Inherit;True;Property;_Masks;Masks;8;0;Create;True;0;0;0;False;0;False;-1;None;2ce18361c9dd445ab8b2bdef593443ba;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;172;-3796.505,1032.185;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;99;-3590.427,1804.499;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;71;-3080.458,989.5092;Inherit;False;1405.517;500.1821;Top Skull;10;40;39;38;37;36;54;41;35;51;66;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;95;-3040.037,1650.228;Inherit;False;1405.516;500.1832;Side Hand;12;117;83;82;81;79;118;78;80;76;77;75;74;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-1755.198,-2085.02;Inherit;False;MaskG;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-1747.482,-2164.811;Inherit;False;MaskR;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-3333.616,489.7702;Inherit;True;Property;_ScreenHandsVDM;Screen Hands VDM;20;0;Create;True;0;0;0;False;0;False;-1;None;eed7ad983901406c86b628d1d8b8b68c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;175;-3455.455,1052.682;Inherit;False;SkullWave;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;103;-3368.037,1790.359;Inherit;False;LeftHandWave;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;-1752.702,-2012.642;Inherit;False;MaskB;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;35;-3030.458,1039.509;Inherit;True;Property;_TopSkullVDM;Top Skull VDM;21;0;Create;True;0;0;0;False;0;False;-1;None;4cd521ef1b5b4ffabe5a48acfe011ab2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;182;-2781.646,652.9453;Inherit;False;116;BasicNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-2762.515,745.3145;Inherit;False;15;MaskR;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;5;-2765.739,466.4062;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-3010.683,1254.901;Inherit;False;63;MaskG;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;77;-2990.037,1700.228;Inherit;True;Property;_LeftHandVDM;Left Hand VDM;22;0;Create;True;0;0;0;False;0;False;-1;None;07775227b94f4c0193241bd40841f81c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;36;-2636.501,1073.836;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;78;-2636.909,1717.198;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;48;-2554.13,731.0443;Inherit;False;True;False;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;-2972.63,1932.621;Inherit;False;84;MaskB;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;54;-2650.994,1233.869;Inherit;False;False;True;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;-2625.788,1862.848;Inherit;False;116;BasicNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;-2487.146,489.9832;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-2343.516,491.1493;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;-2456.162,1726.009;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-2451.302,1072.643;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;79;-2614.573,1940.589;Inherit;False;False;True;False;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;302;-1464.151,446.1821;Inherit;False;1027.477;547.8003;Blend it all;6;85;86;72;64;306;307;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-2152.438,698.0411;Inherit;False;Property;_HandIntensity;Hand Intensity;1;0;Create;True;0;0;0;False;0;False;0;0.3;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-2265.677,1267.317;Inherit;False;Property;_SkullIntensity;Skull Intensity;2;0;Create;True;0;0;0;False;0;False;0;0.06;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-2319.881,1735.363;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TransformDirectionNode;4;-2138.432,512.2322;Inherit;False;Tangent;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;38;-2230.427,1056.367;Inherit;False;Tangent;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;74;-2280.258,1931.037;Inherit;False;Property;_SideHandIntensity;Side Hand Intensity;3;0;Create;True;0;0;0;False;0;False;0;0.34;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-1414.151,695.7;Inherit;False;63;MaskG;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1836.942,1067.751;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;82;-2129.006,1719.086;Inherit;False;Tangent;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-1852.042,498.9012;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-1796.52,1728.471;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;72;-1164.939,502.288;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;-1093.412,674.1199;Inherit;False;84;MaskB;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;85;-908.4567,496.1821;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;307;-885.2482,627.502;Inherit;False;Property;_DisplacementMultiplier;Displacement Multiplier;24;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;306;-648.181,498.1727;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;285;-2169.221,-3195.721;Inherit;False;1625.504;925.7112;Noise and Screen Toggle;24;305;254;260;246;255;256;259;263;304;241;242;283;227;210;252;253;214;209;203;205;211;212;208;206;;0,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;70;-2509.243,-3879.968;Inherit;False;946.314;679.926;Top Skull Color;7;65;58;67;60;59;57;56;;0,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;87;-1541.847,-3872.958;Inherit;False;983.7319;667.2546;Side Hands Color;7;94;92;88;93;91;89;90;;0,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;239;-2106.817,-1123.468;Inherit;False;1550.857;686.1973;Noise Glow;15;271;270;236;234;237;264;266;265;238;219;218;217;221;235;316;;0,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;287;-2891.964,-3874.719;Inherit;False;374.8137;679.5413;Base Albedo;1;1;;0,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;293;-1392.609,-421.1147;Inherit;False;849.9263;372.43;Base Smoothness;5;261;202;312;262;317;;0,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;303;-540.7618,-3877.957;Inherit;False;503.4564;677.6317;Blend it all;3;213;284;310;;0,0,0,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;318;-491.2319,492.7085;Inherit;False;FinalVertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;235;-1898.331,-737.02;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;221;-1916.393,-818.1255;Inherit;False;Property;_GlowIntensity;Glow Intensity;17;1;[HDR];Create;True;0;0;0;False;0;False;0;0.21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;262;-933.7239,-371.1146;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-2832.336,-3799.447;Inherit;True;Property;_Albedo;Albedo;7;0;Create;True;0;0;0;False;0;False;-1;None;47a4fa154e4d444982cb3993f6da2795;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;57;-1997.173,-3732.559;Inherit;False;Property;_TopSkullTint;Top Skull Tint;10;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;59;-1941.404,-3565.679;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-2100.948,-3564.598;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-2244.448,-3564.829;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-2455.632,-3568.172;Inherit;False;51;SkullIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-2331.371,-3470.72;Inherit;False;66;TopSkullColorMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-1365.18,-3476.945;Inherit;False;80;SideHandColorMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-1273.443,-3566.242;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-1128.742,-3564.807;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;93;-978.8223,-3565.889;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-1513.509,-3570.789;Inherit;False;75;SideHandIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;56;-1764.894,-3794.385;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;92;-1046.851,-3731.496;Inherit;False;Property;_SideHandTint;Side Hand Tint;11;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;94;-806.6676,-3795.893;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;206;-2070.153,-3002.74;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;3,3;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;208;-1992.855,-2887.13;Inherit;False;Constant;_Float4;Float 4;18;0;Create;True;0;0;0;False;0;False;2;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;212;-1997.263,-2815.284;Inherit;False;Constant;_Float5;Float 5;17;0;Create;True;0;0;0;False;0;False;12;12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;211;-2023.863,-2742.183;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;205;-1782.18,-3005.266;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;203;-1521.493,-3032.929;Inherit;True;Property;_NoiseFlipbook;Noise Flipbook;16;0;Create;True;0;0;0;False;0;False;-1;None;417025cc229b4cd38638ba97d15d9fd2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;209;-1098.447,-3029.772;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;214;-925.0044,-3091.714;Inherit;False;TVNoise;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;253;-934.1104,-2957.043;Inherit;False;Property;_TVHandsTint;TV Hands Tint;19;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.9213688,0.9365109,0.9528301,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;210;-1307.437,-2744.196;Inherit;False;15;MaskR;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;227;-1092.685,-2746.9;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;283;-956.5618,-2753.318;Inherit;False;ScreenToggleSlider;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;242;-1327.606,-2661.57;Inherit;False;ScreenToggle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;241;-1607.149,-2662.409;Inherit;False;Property;_ScreenToggle;Screen Toggle;0;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;304;-841.6588,-2523.819;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;263;-973.2727,-2608.728;Inherit;False;HandMaskNoiseEmission;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;259;-1130.181,-2522.133;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.9;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;256;-1279.698,-2511.681;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;255;-1424.677,-2509.806;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;246;-1647.088,-2503.971;Inherit;False;244;myVarName;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;260;-1595.201,-2423.337;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;254;-1840.037,-2428.125;Inherit;False;29;HandIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;305;-1130.763,-2399.191;Inherit;False;Property;_ScreenColorTintBlend;Screen Color Tint Blend;23;0;Create;True;0;0;0;False;0;False;0;0.28;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;284;-500.75,-3831.488;Inherit;False;283;ScreenToggleSlider;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;213;-247.0364,-3800.675;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;252;-707.5391,-3033.529;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;309;-351.3822,-3088.859;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;310;-340.8327,-3660.313;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StickyNoteNode;311;-1701.866,-1874.132;Inherit;False;230;130;;;0,0,0,1;This is optional, increasing it here because we're blending in the effect.;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;217;-1930.395,-1075.468;Inherit;False;214;TVNoise;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;218;-1669.149,-1069.81;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;219;-1963.771,-998.5041;Inherit;False;Property;_NoiseTint;Noise Tint;18;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;77.24828,77.24828,77.24828,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;238;-1439.556,-1063.535;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;265;-1087.849,-1061.434;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;266;-1237.576,-934.0737;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;264;-1494.576,-926.0737;Inherit;False;263;HandMaskNoiseEmission;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;237;-1664.558,-743.785;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;234;-2074.564,-725.499;Inherit;False;Property;_TilingGlow;Tiling Glow;5;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;236;-1826.499,-622.4876;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StickyNoteNode;312;-974.7336,-249.3619;Inherit;False;174;142;;;0,0,0,1;Could be improved, use your own! Get the masks already available.;0;0
Node;AmplifyShaderEditor.SamplerNode;202;-1330.609,-367.3285;Inherit;True;Property;_TV_MetallicSmoothness;TV_MetallicSmoothness;14;0;Create;True;0;0;0;False;0;False;-1;None;0adb73023f2a4566bc08f553cd0b2f2c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;261;-1308.157,-173.7325;Inherit;False;Property;_BaseSmoothness;Base Smoothness;15;0;Create;True;0;0;0;False;0;False;0;0.55;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;270;-893.7255,-1061.997;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;271;-1110.117,-861.2579;Inherit;False;242;ScreenToggle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;20;-1526.577,-2103.772;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LayeredBlendNode;18;-1028.031,-2108.835;Inherit;False;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;2;-1421.655,-1958.893;Inherit;True;Property;_Normal;Normal;12;0;Create;True;0;0;0;False;0;False;-1;None;21786817dce64c4a9f09e9d564a7ef61;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;21;-1421.269,-1771.175;Inherit;True;Property;_NormalHands;Normal Hands;6;0;Create;True;0;0;0;False;0;False;-1;None;7213c3e97f724fa5adb6e613340bafb0;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;50;-1421.191,-1583.395;Inherit;True;Property;_NormalTopSkull;Normal Top Skull;9;0;Create;True;0;0;0;False;0;False;-1;None;25ed1d4b8ff342dba6a9335134a9f686;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;96;-1421.896,-1394.359;Inherit;True;Property;_NormalsLeftHand;Normals Left Hand;13;0;Create;True;0;0;0;False;0;False;-1;None;37097ef2806343569563472cbdc7f6bf;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;32;-1634.008,-1717.716;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;176;-1634.422,-1560.006;Inherit;False;175;SkullWave;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;53;-1606.547,-1489.929;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-1866.279,-1723.235;Inherit;False;29;HandIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-1859.82,-1498.617;Inherit;False;51;SkullIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;-1637.735,-1370.683;Inherit;False;103;LeftHandWave;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;98;-1587.884,-1291.439;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-1882.854,-1298.547;Inherit;False;75;SideHandIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;19;-828.8991,-2108.003;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-1817.021,695.3362;Inherit;False;HandIntensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;244;-2984.242,704.1382;Inherit;False;myVarName;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-1923.806,1347.274;Inherit;False;SkullIntensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;-1883.385,2007.994;Inherit;False;SideHandIntensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;-2656.485,1373.691;Inherit;False;TopSkullColorMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-2616.063,2034.411;Inherit;False;SideHandColorMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;314;-42.97925,-3808.81;Inherit;False;FinalBaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;316;-743.8811,-1069.194;Inherit;False;FinalEmission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;317;-774.1445,-374.4495;Inherit;False;FinalSmoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;319;525.1219,-3813.426;Inherit;False;314;FinalBaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;320;523.1219,-3735.426;Inherit;False;315;FinalNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;321;518.1219,-3663.426;Inherit;False;316;FinalEmission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;322;502.1219,-3586.426;Inherit;False;317;FinalSmoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;315;-674.3245,-2112.37;Inherit;False;FinalNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;323;502.8394,-3510.426;Inherit;False;318;FinalVertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;324;769.9008,-3810.047;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;325;769.9008,-3810.047;Float;False;True;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;AmplifyShaderPack/Vector Displacement;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;21;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;;0;0;Standard;39;Workflow;1;0;Surface;0;0;  Refraction Model;0;0;  Blend;0;0;Two Sided;1;0;Fragment Normal Space,InvertActionOnDeselection;0;0;Forward Only;0;0;Transmission;0;0;  Transmission Shadow;0.5,False,;0;Translucency;0;0;  Translucency Strength;1,False,;0;  Normal Distortion;0.5,False,;0;  Scattering;2,False,;0;  Direct;0.9,False,;0;  Ambient;0.1,False,;0;  Shadow;0.5,False,;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;1;0;_FinalColorxAlpha;0;0;Meta Pass;1;0;Override Baked GI;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Write Depth;0;0;  Early Z;0;0;Vertex Position,InvertActionOnDeselection;1;0;Debug Display;0;0;Clear Coat;0;0;0;10;False;True;True;True;True;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;326;769.9008,-3810.047;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;327;769.9008,-3810.047;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;328;769.9008,-3810.047;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;329;769.9008,-3810.047;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;330;769.9008,-3810.047;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthNormals;0;6;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormals;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;331;769.9008,-3810.047;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;GBuffer;0;7;GBuffer;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalGBuffer;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;332;769.9008,-3730.047;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;SceneSelectionPass;0;8;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;333;769.9008,-3730.047;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ScenePickingPass;0;9;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
WireConnection;13;0;10;0
WireConnection;11;0;13;0
WireConnection;11;1;12;2
WireConnection;116;0;11;0
WireConnection;169;0;173;0
WireConnection;169;1;168;0
WireConnection;170;0;168;0
WireConnection;170;1;174;0
WireConnection;112;0;111;0
WireConnection;112;1;116;0
WireConnection;107;0;11;0
WireConnection;107;1;108;0
WireConnection;171;0;169;0
WireConnection;171;1;170;0
WireConnection;110;0;112;0
WireConnection;110;1;107;0
WireConnection;172;1;171;0
WireConnection;99;1;110;0
WireConnection;63;0;45;2
WireConnection;15;0;45;1
WireConnection;175;0;172;0
WireConnection;103;0;99;0
WireConnection;84;0;45;3
WireConnection;35;1;175;0
WireConnection;5;0;6;1
WireConnection;5;1;6;3
WireConnection;5;2;6;2
WireConnection;77;1;103;0
WireConnection;36;0;35;1
WireConnection;36;1;35;3
WireConnection;36;2;35;2
WireConnection;78;0;77;1
WireConnection;78;1;77;3
WireConnection;78;2;77;2
WireConnection;48;0;17;0
WireConnection;54;0;41;0
WireConnection;181;0;5;0
WireConnection;181;1;182;0
WireConnection;16;0;181;0
WireConnection;16;1;48;0
WireConnection;118;0;78;0
WireConnection;118;1;117;0
WireConnection;37;0;36;0
WireConnection;37;1;54;0
WireConnection;79;0;76;0
WireConnection;81;0;118;0
WireConnection;81;1;79;0
WireConnection;4;0;16;0
WireConnection;38;0;37;0
WireConnection;39;0;38;0
WireConnection;39;1;40;0
WireConnection;82;0;81;0
WireConnection;7;0;4;0
WireConnection;7;1;8;0
WireConnection;83;0;82;0
WireConnection;83;1;74;0
WireConnection;72;0;7;0
WireConnection;72;1;39;0
WireConnection;72;2;64;0
WireConnection;85;0;72;0
WireConnection;85;1;83;0
WireConnection;85;2;86;0
WireConnection;306;0;85;0
WireConnection;306;1;307;0
WireConnection;318;0;306;0
WireConnection;235;0;234;0
WireConnection;262;0;202;4
WireConnection;262;1;261;0
WireConnection;59;0;60;0
WireConnection;60;0;67;0
WireConnection;60;1;65;0
WireConnection;67;0;58;0
WireConnection;89;0;88;0
WireConnection;91;0;89;0
WireConnection;91;1;90;0
WireConnection;93;0;91;0
WireConnection;56;0;1;0
WireConnection;56;1;57;0
WireConnection;56;2;59;0
WireConnection;94;0;56;0
WireConnection;94;1;92;0
WireConnection;94;2;93;0
WireConnection;205;0;206;0
WireConnection;205;1;208;0
WireConnection;205;2;208;0
WireConnection;205;3;212;0
WireConnection;205;5;211;0
WireConnection;203;1;205;0
WireConnection;209;0;203;0
WireConnection;209;1;210;0
WireConnection;214;0;209;0
WireConnection;227;0;210;0
WireConnection;227;1;242;0
WireConnection;283;0;227;0
WireConnection;242;0;241;0
WireConnection;304;0;259;0
WireConnection;304;1;305;0
WireConnection;263;0;259;0
WireConnection;259;0;256;0
WireConnection;256;0;255;0
WireConnection;255;0;246;0
WireConnection;255;1;260;0
WireConnection;260;0;254;0
WireConnection;213;0;94;0
WireConnection;213;1;310;0
WireConnection;213;2;284;0
WireConnection;252;0;209;0
WireConnection;252;1;253;0
WireConnection;252;2;304;0
WireConnection;309;0;252;0
WireConnection;310;0;309;0
WireConnection;218;0;217;0
WireConnection;218;1;219;0
WireConnection;218;2;221;0
WireConnection;238;0;218;0
WireConnection;238;1;237;0
WireConnection;265;0;238;0
WireConnection;265;1;266;0
WireConnection;266;0;264;0
WireConnection;237;0;235;0
WireConnection;237;1;236;4
WireConnection;270;0;265;0
WireConnection;270;1;271;0
WireConnection;20;0;15;0
WireConnection;20;1;63;0
WireConnection;20;2;84;0
WireConnection;18;0;20;0
WireConnection;18;1;2;0
WireConnection;18;2;21;0
WireConnection;18;3;50;0
WireConnection;18;4;96;0
WireConnection;21;5;32;0
WireConnection;50;1;176;0
WireConnection;50;5;53;0
WireConnection;96;1;114;0
WireConnection;96;5;98;0
WireConnection;32;0;30;0
WireConnection;53;0;52;0
WireConnection;98;0;97;0
WireConnection;19;0;18;0
WireConnection;29;0;8;0
WireConnection;244;0;6;2
WireConnection;51;0;40;0
WireConnection;75;0;74;0
WireConnection;66;0;35;2
WireConnection;80;0;77;2
WireConnection;314;0;213;0
WireConnection;316;0;270;0
WireConnection;317;0;262;0
WireConnection;315;0;19;0
WireConnection;325;0;319;0
WireConnection;325;1;320;0
WireConnection;325;2;321;0
WireConnection;325;4;322;0
WireConnection;325;8;323;0
ASEEND*/
//CHKSM=1C5E8B55F814F3941158EBC76AE4B327B41927EB