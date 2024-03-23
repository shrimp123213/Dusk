// Made with Amplify Shader Editor v1.9.3.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AmplifyShaderPack/Baked GI Standard"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Enum(Front,2,Back,1,Both,0)]_Cull("Render Face", Int) = 2
		[Header(SURFACE INPUTS)]_BaseColor("Base Color", Color) = (1,1,1,0)
		_Brightness("Brightness", Range( 0 , 2)) = 1
		[SingleLineTexture]_MainTex("BaseColor Map", 2D) = "white" {}
		_MainUVs("Main UVs", Vector) = (1,1,0,0)
		[Normal][SingleLineTexture]_BumpMap("Normal Map", 2D) = "bump" {}
		_NormalStrength("Normal Strength", Float) = 1
		[SingleLineTexture]_MetallicGlossMap("Metallic Map", 2D) = "white" {}
		_MetallicStrength("Metallic Strength", Range( 0 , 1)) = 0
		[SingleLineTexture]_OcclusionMap("Occlusion Map", 2D) = "white" {}
		_OcclusionStrengthAO("Occlusion Strength", Range( 0 , 1)) = 0
		[SingleLineTexture]_SmoothnessMap("Smoothness Map", 2D) = "white" {}
		_SmoothnessStrength("Smoothness Strength", Range( 0 , 1)) = 0
		[Header(BAKED GI)][ToggleUI]_BakedGIEnable("ENABLE BAKED GI", Float) = 1
		[Header(INDIRECT SPECULAR)][Space(5)]_IndirectSpecularColor("Indirect Specular Color", Color) = (1,0.9568627,0.8392157,0)
		_IndirectSpecular("Indirect Specular ", Range( 0 , 1)) = 0.85
		_IndirectSpecularSmoothness("Indirect Specular Smoothness", Range( 0 , 1)) = 0.25
		_IndirectSpecularOcclusion("Indirect Specular Occlusion", Range( 0 , 1)) = 0.5
		[Header(INDIRECT DIFFUSE)][Space(5)]_IndirectDiffuse("Indirect Diffuse", Range( 0 , 1)) = 0.85
		[Header(SHADOWS)]_ShadowStrength("Shadow Strength", Range( 0 , 1)) = 0.85
		[Enum(Near,0,Exact,1)]_ShadowApproxmation("Shadow Approxmation", Float) = 1
		_ShadowSharpness("Shadow Sharpness", Range( 0.01 , 1)) = 0.7
		_ShadowOffset("Shadow Offset", Range( 0 , 1)) = 0.5
		[ToggleUI]_ShadowColorEnable("Enable Shadow Color", Float) = 0
		[HDR]_ShadowColor("Shadow Color", Color) = (0.3113208,0.3113208,0.3113208,0)


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

		Cull [_Cull]
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 3.5
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
			#define ASE_BAKEDGI 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120113
			#define ASE_USING_SAMPLING_MACROS 1


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

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR


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
				float4 ase_texcoord9 : TEXCOORD9;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainUVs;
			float4 _IndirectSpecularColor;
			float4 _ShadowColor;
			half4 _BaseColor;
			int _Cull;
			half _SmoothnessStrength;
			float _MetallicStrength;
			half _IndirectSpecular;
			half _IndirectSpecularOcclusion;
			half _IndirectSpecularSmoothness;
			half _Brightness;
			float _ShadowColorEnable;
			half _ShadowSharpness;
			half _ShadowOffset;
			half _ShadowApproxmation;
			half _ShadowStrength;
			float _IndirectDiffuse;
			half _NormalStrength;
			half _OcclusionStrengthAO;
			float _BakedGIEnable;
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

			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			TEXTURE2D(_MetallicGlossMap);
			TEXTURE2D(_SmoothnessMap);
			TEXTURE2D(_OcclusionMap);


			half4 CalculateShadowMask1_g33( half2 LightmapUV )
			{
				#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
				return SAMPLE_SHADOWMASK( LightmapUV.xy );
				#elif !defined (LIGHTMAP_ON)
				return unity_ProbesOcclusion;
				#else
				return half4( 1, 1, 1, 1 );
				#endif
			}
			
			float3 AdditionalLightsHalfLambertMask12x( float3 WorldPosition, float3 WorldNormal, float4 ShadowMask )
			{
				float3 Color = 0;
				#ifdef _ADDITIONAL_LIGHTS
					uint lightCount = GetAdditionalLightsCount();
					LIGHT_LOOP_BEGIN( lightCount )
						#if ASE_SRP_VERSION >= 100000
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#else
						Light light = GetAdditionalLight(lightIndex, WorldPosition);
						#endif
						half3 AttLightColor = light.color *(light.distanceAttenuation * light.shadowAttenuation);
						Color +=(dot(light.direction, WorldNormal)*0.5+0.5 )* AttLightColor;
					LIGHT_LOOP_END
				#endif
				return Color;
			}
			
			float3 ASEBakedGI( float3 normalWS, float2 uvStaticLightmap, bool applyScaling )
			{
			#ifdef LIGHTMAP_ON
				if( applyScaling )
					uvStaticLightmap = uvStaticLightmap * unity_LightmapST.xy + unity_LightmapST.zw;
				return SampleLightmap( uvStaticLightmap, normalWS );
			#else
				return SampleSH(normalWS);
			#endif
			}
			
			float3 ASESafeNormalize(float3 inVec)
			{
				float dp3 = max(1.175494351e-38, dot(inVec, inVec));
				return inVec* rsqrt(dp3);
			}
			
			float3 AdditionalLightsSpecular10x12x( float3 WorldPosition, float3 WorldNormal, float3 WorldView, float3 SpecColor, float Smoothness )
			{
				float3 Color = 0;
				#ifdef _ADDITIONAL_LIGHTS
					Smoothness = exp2(10 * Smoothness + 1);
					uint lightCount = GetAdditionalLightsCount();
					LIGHT_LOOP_BEGIN( lightCount )
						Light light = GetAdditionalLight(lightIndex, WorldPosition);
						half3 AttLightColor = light.color *(light.distanceAttenuation * light.shadowAttenuation);
						Color += LightingSpecular(AttLightColor, light.direction, WorldNormal, WorldView, half4(SpecColor, 0), Smoothness);	
					LIGHT_LOOP_END
				#endif
				return Color;
			}
			
			float4 URPDecodeInstruction984_g26(  )
			{
				return float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0, 0);
			}
			
			void SampleLightmapBicubic( float3 normalWS, float3 backNormalWS, float2 staticUV, float2 dynamicUV, out float3 bakeDiffuseLighting, out float3 backBakeDiffuseLighting, float4 decodeInstructions, float4 staticDir, float4 dynamicDir )
			{
				bakeDiffuseLighting = 0;
				backBakeDiffuseLighting = 0;
				#if defined( SHADER_STAGE_FRAGMENT ) || defined( SHADER_STAGE_RAY_TRACING )
				    int width, height;
				    float4 texSize;
				    float3 illuminance;
				    float halfLambert;
				    float backHalfLambert;
				    #if defined( LIGHTMAP_ON )
				        #if defined( UNITY_DOTS_INSTANCING_ENABLED )
				            #define LM_NAME unity_Lightmaps
				            #define LM_SAMPLER samplerunity_Lightmaps
				            #define LM_SLICE unity_LightmapIndex.x
				        #else
				            #define LM_NAME unity_Lightmap
				            #define LM_SAMPLER samplerunity_Lightmap
				            #define LM_SLICE 0
				        #endif
				        #ifdef UNITY_LIGHTMAP_FULL_HDR
				            bool encodedLightmap = false;
				        #else
				            bool encodedLightmap = true;
				        #endif
				        LIGHTMAP_NAME.GetDimensions( width, height );
				        texSize = float4( width, height, 1.0 / float2( width, height ) );
				        float4 encodedIlluminance = SampleTexture2DBicubic( LM_NAME, LM_SAMPLER, staticUV, texSize, float2( 1, 1 ), LM_SLICE ).rgba;
				        illuminance = encodedLightmap ? DecodeLightmap( encodedIlluminance, decodeInstructions ) : encodedIlluminance.rgb;
				        #if defined( DIRLIGHTMAP_COMBINED )
				            halfLambert = dot( normalWS, staticDir.xyz - 0.5 ) + 0.5;
				            bakeDiffuseLighting += illuminance * halfLambert / max( 1e-4, staticDir.w );
				            backHalfLambert = dot( backNormalWS, staticDir.xyz - 0.5 ) + 0.5;
				            backBakeDiffuseLighting += illuminance * backHalfLambert / max( 1e-4, staticDir.w );
				        #else
				            bakeDiffuseLighting += illuminance;
				            backBakeDiffuseLighting += illuminance;
				        #endif
				    #endif
				    #if defined( DYNAMICLIGHTMAP_ON )
				        unity_DynamicLightmap.GetDimensions( width, height );
				        texSize = float4( width, height, 1.0 / float2( width, height ) );
				        illuminance = SampleTexture2DBicubic( unity_DynamicLightmap, samplerunity_DynamicLightmap, dynamicUV, texSize, float2( 1, 1 ), 0 ).rgb;
				        #if defined( DIRLIGHTMAP_COMBINED )
				            halfLambert = dot( normalWS, dynamicDir.xyz - 0.5 ) + 0.5;
				            bakeDiffuseLighting += illuminance * halfLambert / max( 1e-4, dynamicDir.w );
				            backHalfLambert = dot( backNormalWS, dynamicDir.xyz - 0.5 ) + 0.5;
				            backBakeDiffuseLighting += illuminance * backHalfLambert / max( 1e-4, dynamicDir.w );
				        #else
				            bakeDiffuseLighting += illuminance;
				            backBakeDiffuseLighting += illuminance;
				        #endif
				    #endif
				#endif
				return;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord8.xy = v.texcoord.xy;
				o.ase_texcoord8.zw = v.texcoord2.xy;
				o.ase_texcoord9.xy = v.texcoord1.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord9.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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
						, bool ase_vface : SV_IsFrontFace ) : SV_Target
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

				float3 worldPosValue184_g35 = WorldPosition;
				float3 WorldPosition151_g35 = worldPosValue184_g35;
				float2 temp_output_133_0_g7 = ( ( IN.ase_texcoord8.xy * (_MainUVs).xy ) + (_MainUVs).zw );
				float3 unpack98_g7 = UnpackNormalScale( SAMPLE_TEXTURE2D( _BumpMap, sampler_BumpMap, temp_output_133_0_g7 ), _NormalStrength );
				unpack98_g7.z = lerp( 1, unpack98_g7.z, saturate(_NormalStrength) );
				float3 temp_output_33_6 = unpack98_g7;
				float3 temp_output_975_0_g31 = temp_output_33_6;
				float3 Normal1069_g31 = temp_output_975_0_g31;
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal12_g35 = Normal1069_g31;
				float3 worldNormal12_g35 = normalize( float3(dot(tanToWorld0,tanNormal12_g35), dot(tanToWorld1,tanNormal12_g35), dot(tanToWorld2,tanNormal12_g35)) );
				float3 worldNormalValue185_g35 = worldNormal12_g35;
				float3 WorldNormal151_g35 = worldNormalValue185_g35;
				float2 temp_output_1255_0_g31 = (IN.ase_texcoord8.zw*(unity_DynamicLightmapST).xy + (unity_DynamicLightmapST).zw);
				float2 UV2Dynamic1251_g31 = temp_output_1255_0_g31;
				half2 LightmapUV1_g33 = UV2Dynamic1251_g31;
				half4 localCalculateShadowMask1_g33 = CalculateShadowMask1_g33( LightmapUV1_g33 );
				float4 shadowMaskValue182_g35 = localCalculateShadowMask1_g33;
				float4 ShadowMask151_g35 = shadowMaskValue182_g35;
				float3 localAdditionalLightsHalfLambertMask12x151_g35 = AdditionalLightsHalfLambertMask12x( WorldPosition151_g35 , WorldNormal151_g35 , ShadowMask151_g35 );
				float3 SRP_Lambert_Half1362_g31 = localAdditionalLightsHalfLambertMask12x151_g35;
				float3 tanNormal1158_g31 = Normal1069_g31;
				float3 worldNormal1158_g31 = normalize( float3(dot(tanToWorld0,tanNormal1158_g31), dot(tanToWorld1,tanNormal1158_g31), dot(tanToWorld2,tanNormal1158_g31)) );
				float2 temp_output_1219_0_g31 = (IN.ase_texcoord9.xy*(unity_LightmapST).xy + (unity_LightmapST).zw);
				float2 UV1Static1247_g31 = temp_output_1219_0_g31;
				float3 bakedGI1252_g31 = ASEBakedGI( worldNormal1158_g31, UV1Static1247_g31, true);
				float3 lerpResult1169_g31 = lerp( float3( 1,1,1 ) , ( SRP_Lambert_Half1362_g31 + bakedGI1252_g31 ) , _IndirectDiffuse);
				float3 temp_output_1173_0_g31 = ( lerpResult1169_g31 + step( float3( 1,1,1 ) , ( 1.0 - lerpResult1169_g31 ) ) );
				float3 tanNormal1072_g31 = temp_output_975_0_g31;
				float3 worldNormal1072_g31 = normalize( float3(dot(tanToWorld0,tanNormal1072_g31), dot(tanToWorld1,tanNormal1072_g31), dot(tanToWorld2,tanNormal1072_g31)) );
				float3 normalizeResult1044_g31 = ASESafeNormalize( ( WorldViewDirection + SafeNormalize(_MainLightPosition.xyz) ) );
				float dotResult1046_g31 = dot( worldNormal1072_g31 , normalizeResult1044_g31 );
				float Dot_NdotH1098_g31 = dotResult1046_g31;
				float temp_output_1108_0_g31 = ( 1.0 - ( ( 1.0 - Dot_NdotH1098_g31 ) * _MainLightPosition.w ) );
				float ase_lightIntensity = max( max( _MainLightColor.r, _MainLightColor.g ), _MainLightColor.b );
				float4 ase_lightColor = float4( _MainLightColor.rgb / ase_lightIntensity, ase_lightIntensity );
				float LightColorIntensity1349_g31 = max( ase_lightColor.a , 0.0 );
				float3 temp_output_1112_0_g31 = ( temp_output_1173_0_g31 * temp_output_1108_0_g31 * LightColorIntensity1349_g31 );
				float dotResult1055_g31 = dot( worldNormal1072_g31 , SafeNormalize(_MainLightPosition.xyz) );
				float Dot_NdotL1100_g31 = dotResult1055_g31;
				float Shadow_Strength1138_g31 = _ShadowStrength;
				float lerpResult1130_g31 = lerp( ( Shadow_Strength1138_g31 * Shadow_Strength1138_g31 * 0.7978846 ) , ( Shadow_Strength1138_g31 * Shadow_Strength1138_g31 * sqrt( ( 2.0 / ( 2.0 * PI ) ) ) ) , _ShadowApproxmation);
				float temp_output_1312_0_g31 = ( ( max( Dot_NdotL1100_g31 , 0.0 ) * lerpResult1130_g31 ) + ( 1.0 - lerpResult1130_g31 ) );
				float temp_output_1117_0_g31 = saturate( ( ( ( max( Dot_NdotH1098_g31 , 0.0 ) * temp_output_1312_0_g31 * temp_output_1312_0_g31 ) + _ShadowOffset ) / _ShadowSharpness ) );
				float3 temp_cast_1 = (temp_output_1117_0_g31).xxx;
				float3 temp_cast_2 = (temp_output_1117_0_g31).xxx;
				float3 lerpResult1379_g31 = lerp( (_ShadowColor).rgb , temp_cast_2 , temp_output_1117_0_g31);
				float3 lerpResult1377_g31 = lerp( temp_cast_1 , lerpResult1379_g31 , _ShadowColorEnable);
				float3 temp_cast_3 = (temp_output_1108_0_g31).xxx;
				float3 lerpResult1109_g31 = lerp( ( lerpResult1377_g31 * Dot_NdotH1098_g31 ) , temp_cast_3 , _ShadowStrength);
				float4 tex2DNode21_g7 = SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, temp_output_133_0_g7 );
				float3 temp_output_89_0_g7 = ( (_BaseColor).rgb * (tex2DNode21_g7).rgb * _Brightness );
				float3 temp_output_898_0_g31 = temp_output_89_0_g7;
				float3 temp_output_1210_0_g31 = saturate( ( ( temp_output_1112_0_g31 + lerpResult1109_g31 ) * temp_output_898_0_g31 ) );
				float3 worldPosValue184_g32 = WorldPosition;
				float3 WorldPosition157_g32 = worldPosValue184_g32;
				float3 tanNormal1260_g31 = Normal1069_g31;
				float3 worldNormal1260_g31 = normalize( float3(dot(tanToWorld0,tanNormal1260_g31), dot(tanToWorld1,tanNormal1260_g31), dot(tanToWorld2,tanNormal1260_g31)) );
				float3 worldNormalValue185_g32 = worldNormal1260_g31;
				float3 WorldNormal157_g32 = worldNormalValue185_g32;
				float3 temp_output_15_0_g32 = WorldViewDirection;
				float3 WorldView157_g32 = temp_output_15_0_g32;
				float3 temp_output_1196_0_g31 = (_IndirectSpecularColor).rgb;
				float3 temp_output_14_0_g32 = temp_output_1196_0_g31;
				float3 SpecColor157_g32 = temp_output_14_0_g32;
				float temp_output_18_0_g32 = _IndirectSpecularSmoothness;
				float Smoothness157_g32 = temp_output_18_0_g32;
				float3 localAdditionalLightsSpecular10x12x157_g32 = AdditionalLightsSpecular10x12x( WorldPosition157_g32 , WorldNormal157_g32 , WorldView157_g32 , SpecColor157_g32 , Smoothness157_g32 );
				float3 LightColorAtten1105_g31 = ( Dot_NdotH1098_g31 * ase_lightColor.rgb );
				float3 normalizeResult1197_g31 = normalize( ( WorldViewDirection + SafeNormalize(_MainLightPosition.xyz) ) );
				float dotResult1187_g31 = dot( normalizeResult1197_g31 , worldNormal1260_g31 );
				float3 temp_output_1192_0_g31 = ( temp_output_1196_0_g31 * LightColorAtten1105_g31 * pow( max( dotResult1187_g31 , 0.0 ) , exp2( (_IndirectSpecularSmoothness*10.0 + 1.0) ) ) );
				float3 temp_output_1202_0_g31 = ( localAdditionalLightsSpecular10x12x157_g32 + temp_output_1192_0_g31 );
				float3 temp_cast_4 = (1.0).xxx;
				half3 reflectVector1296_g31 = reflect( -WorldViewDirection, worldNormal1260_g31 );
				float3 indirectSpecular1296_g31 = GlossyEnvironmentReflection( reflectVector1296_g31, 1.0 - _IndirectSpecularSmoothness, _IndirectSpecularOcclusion );
				float3 lerpResult1266_g31 = lerp( temp_cast_4 , ( indirectSpecular1296_g31 + step( float3( 1,1,1 ) , ( 1.0 - indirectSpecular1296_g31 ) ) ) , _IndirectSpecular);
				float3 BaseColor1240_g31 = temp_output_898_0_g31;
				float3 switchResult1238_g31 = (((ase_vface>0)?(( temp_output_1202_0_g31 + lerpResult1266_g31 )):(BaseColor1240_g31)));
				float fresnelNdotV1262_g31 = dot( worldNormal1260_g31, WorldViewDirection );
				float fresnelNode1262_g31 = ( 0.04 + _IndirectSpecularSmoothness * pow( 1.0 - fresnelNdotV1262_g31, 5.0 ) );
				float3 lerpResult1236_g31 = lerp( temp_output_1210_0_g31 , switchResult1238_g31 , saturate( fresnelNode1262_g31 ));
				
				float localSampleLightmapBicubic965_g26 = ( 0.0 );
				float3 temp_output_975_0_g26 = temp_output_33_6;
				float3 tanNormal1070_g26 = temp_output_975_0_g26;
				float3 worldNormal1070_g26 = float3(dot(tanToWorld0,tanNormal1070_g26), dot(tanToWorld1,tanNormal1070_g26), dot(tanToWorld2,tanNormal1070_g26));
				float3 NormalWS1073_g26 = worldNormal1070_g26;
				float3 normalWS965_g26 = NormalWS1073_g26;
				float3 temp_output_1063_0_g26 = ( worldNormal1070_g26 * float3( -1,-1,-1 ) );
				float3 BackNormalWS1101_g26 = temp_output_1063_0_g26;
				float3 backNormalWS965_g26 = BackNormalWS1101_g26;
				float2 temp_output_1219_0_g26 = (IN.ase_texcoord9.xy*(unity_LightmapST).xy + (unity_LightmapST).zw);
				float2 UV1Static1247_g26 = temp_output_1219_0_g26;
				float2 staticUV965_g26 = UV1Static1247_g26;
				float2 temp_output_1255_0_g26 = (IN.ase_texcoord8.zw*(unity_DynamicLightmapST).xy + (unity_DynamicLightmapST).zw);
				float2 UV2Dynamic1251_g26 = temp_output_1255_0_g26;
				float2 dynamicUV965_g26 = UV2Dynamic1251_g26;
				float3 bakeDiffuseLighting965_g26 = float3( 0,0,0 );
				float3 backBakeDiffuseLighting965_g26 = float3( 0,0,0 );
				float4 localURPDecodeInstruction984_g26 = URPDecodeInstruction984_g26();
				float4 decodeInstructions965_g26 = localURPDecodeInstruction984_g26;
				float localSampleDirectionBicubic961_g26 = ( 0.0 );
				float2 staticUV961_g26 = UV1Static1247_g26;
				float2 dynamicUV961_g26 = UV2Dynamic1251_g26;
				float4 staticDir961_g26 = float4( 0,0,0,0 );
				float4 dynamicDir961_g26 = float4( 0,0,0,0 );
				{
				#if defined( DIRLIGHTMAP_COMBINED ) && ( defined( SHADER_STAGE_FRAGMENT ) || defined( SHADER_STAGE_RAY_TRACING ) )
				    int width, height;
				    float4 texSize;
				    #if defined( LIGHTMAP_ON )
				        #if defined( UNITY_DOTS_INSTANCING_ENABLED )
				            #define LM_IND_NAME unity_LightmapsInd
				            #define LM_SAMPLER samplerunity_Lightmaps
				            #define LM_SLICE unity_LightmapIndex.x
				        #else
				            #define LM_IND_NAME unity_LightmapInd
				            #define LM_SAMPLER samplerunity_Lightmap
				            #define LM_SLICE 0
				        #endif
				        LM_IND_NAME.GetDimensions( width, height );
				        texSize = float4( width, height, 1.0 / float2( width, height ) );
				        staticDir961_g26 = SampleTexture2DBicubic( LM_IND_NAME, LM_SAMPLER, staticUV961_g26, texSize, float2( 1, 1 ), LM_SLICE );
				    #endif
				    #if defined( DYNAMICLIGHTMAP_ON )
				        unity_DynamicDirectionality.GetDimensions( width, height );
				        texSize = float4( width, height, 1.0 / float2( width, height ) );
				        dynamicDir961_g26 = SampleTexture2DBicubic( unity_DynamicDirectionality, samplerunity_DynamicLightmap, dynamicUV961_g26, texSize, float2( 1, 1 ), 0 );
				    #endif
				#endif
				}
				float4 staticDir965_g26 = staticDir961_g26;
				float4 dynamicDir965_g26 = dynamicDir961_g26;
				SampleLightmapBicubic( normalWS965_g26 , backNormalWS965_g26 , staticUV965_g26 , dynamicUV965_g26 , bakeDiffuseLighting965_g26 , backBakeDiffuseLighting965_g26 , decodeInstructions965_g26 , staticDir965_g26 , dynamicDir965_g26 );
				float3 lerpResult941_g26 = lerp( float3( 0,0,0 ) , bakeDiffuseLighting965_g26 , _BakedGIEnable);
				

				float3 BaseColor = lerpResult1236_g31;
				float3 Normal = temp_output_33_6;
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = ( _MetallicStrength * (SAMPLE_TEXTURE2D( _MetallicGlossMap, sampler_MainTex, temp_output_133_0_g7 )).rgb ).x;
				float Smoothness = ( _SmoothnessStrength * (SAMPLE_TEXTURE2D( _SmoothnessMap, sampler_MainTex, temp_output_133_0_g7 )).rgb ).x;
				float Occlusion = saturate( ( ( 1.0 - _OcclusionStrengthAO ) * (SAMPLE_TEXTURE2D( _OcclusionMap, sampler_MainTex, temp_output_133_0_g7 )).rgb ) ).x;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = lerpResult941_g26;
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
			#define ASE_BAKEDGI 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120113
			#define ASE_USING_SAMPLING_MACROS 1


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
			float4 _MainUVs;
			float4 _IndirectSpecularColor;
			float4 _ShadowColor;
			half4 _BaseColor;
			int _Cull;
			half _SmoothnessStrength;
			float _MetallicStrength;
			half _IndirectSpecular;
			half _IndirectSpecularOcclusion;
			half _IndirectSpecularSmoothness;
			half _Brightness;
			float _ShadowColorEnable;
			half _ShadowSharpness;
			half _ShadowOffset;
			half _ShadowApproxmation;
			half _ShadowStrength;
			float _IndirectDiffuse;
			half _NormalStrength;
			half _OcclusionStrengthAO;
			float _BakedGIEnable;
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

			

			
			float3 _LightDirection;
			float3 _LightPosition;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;
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
            #define ASE_BAKEDGI 1
            #define _NORMALMAP 1
            #define ASE_SRP_VERSION 120113
            #define ASE_USING_SAMPLING_MACROS 1


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
			float4 _MainUVs;
			float4 _IndirectSpecularColor;
			float4 _ShadowColor;
			half4 _BaseColor;
			int _Cull;
			half _SmoothnessStrength;
			float _MetallicStrength;
			half _IndirectSpecular;
			half _IndirectSpecularOcclusion;
			half _IndirectSpecularSmoothness;
			half _Brightness;
			float _ShadowColorEnable;
			half _ShadowSharpness;
			half _ShadowOffset;
			half _ShadowApproxmation;
			half _ShadowStrength;
			float _IndirectDiffuse;
			half _NormalStrength;
			half _OcclusionStrengthAO;
			float _BakedGIEnable;
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

			

			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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
			#define ASE_BAKEDGI 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120113
			#define ASE_USING_SAMPLING_MACROS 1


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

			#define ASE_NEEDS_FRAG_WORLD_POSITION
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
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainUVs;
			float4 _IndirectSpecularColor;
			float4 _ShadowColor;
			half4 _BaseColor;
			int _Cull;
			half _SmoothnessStrength;
			float _MetallicStrength;
			half _IndirectSpecular;
			half _IndirectSpecularOcclusion;
			half _IndirectSpecularSmoothness;
			half _Brightness;
			float _ShadowColorEnable;
			half _ShadowSharpness;
			half _ShadowOffset;
			half _ShadowApproxmation;
			half _ShadowStrength;
			float _IndirectDiffuse;
			half _NormalStrength;
			half _OcclusionStrengthAO;
			float _BakedGIEnable;
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

			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);


			half4 CalculateShadowMask1_g33( half2 LightmapUV )
			{
				#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
				return SAMPLE_SHADOWMASK( LightmapUV.xy );
				#elif !defined (LIGHTMAP_ON)
				return unity_ProbesOcclusion;
				#else
				return half4( 1, 1, 1, 1 );
				#endif
			}
			
			float3 AdditionalLightsHalfLambertMask12x( float3 WorldPosition, float3 WorldNormal, float4 ShadowMask )
			{
				float3 Color = 0;
				#ifdef _ADDITIONAL_LIGHTS
					uint lightCount = GetAdditionalLightsCount();
					LIGHT_LOOP_BEGIN( lightCount )
						#if ASE_SRP_VERSION >= 100000
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#else
						Light light = GetAdditionalLight(lightIndex, WorldPosition);
						#endif
						half3 AttLightColor = light.color *(light.distanceAttenuation * light.shadowAttenuation);
						Color +=(dot(light.direction, WorldNormal)*0.5+0.5 )* AttLightColor;
					LIGHT_LOOP_END
				#endif
				return Color;
			}
			
			float3 ASEBakedGI( float3 normalWS, float2 uvStaticLightmap, bool applyScaling )
			{
			#ifdef LIGHTMAP_ON
				if( applyScaling )
					uvStaticLightmap = uvStaticLightmap * unity_LightmapST.xy + unity_LightmapST.zw;
				return SampleLightmap( uvStaticLightmap, normalWS );
			#else
				return SampleSH(normalWS);
			#endif
			}
			
			float3 ASESafeNormalize(float3 inVec)
			{
				float dp3 = max(1.175494351e-38, dot(inVec, inVec));
				return inVec* rsqrt(dp3);
			}
			
			float3 AdditionalLightsSpecular10x12x( float3 WorldPosition, float3 WorldNormal, float3 WorldView, float3 SpecColor, float Smoothness )
			{
				float3 Color = 0;
				#ifdef _ADDITIONAL_LIGHTS
					Smoothness = exp2(10 * Smoothness + 1);
					uint lightCount = GetAdditionalLightsCount();
					LIGHT_LOOP_BEGIN( lightCount )
						Light light = GetAdditionalLight(lightIndex, WorldPosition);
						half3 AttLightColor = light.color *(light.distanceAttenuation * light.shadowAttenuation);
						Color += LightingSpecular(AttLightColor, light.direction, WorldNormal, WorldView, half4(SpecColor, 0), Smoothness);	
					LIGHT_LOOP_END
				#endif
				return Color;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord5.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.normalOS);
				o.ase_texcoord6.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord7.xyz = ase_worldBitangent;
				
				o.ase_texcoord4.xy = v.texcoord0.xy;
				o.ase_texcoord4.zw = v.texcoord2.xy;
				o.ase_texcoord8.xy = v.texcoord1.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;
				o.ase_texcoord7.w = 0;
				o.ase_texcoord8.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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

			half4 frag(VertexOutput IN , bool ase_vface : SV_IsFrontFace ) : SV_TARGET
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

				float3 worldPosValue184_g35 = WorldPosition;
				float3 WorldPosition151_g35 = worldPosValue184_g35;
				float2 temp_output_133_0_g7 = ( ( IN.ase_texcoord4.xy * (_MainUVs).xy ) + (_MainUVs).zw );
				float3 unpack98_g7 = UnpackNormalScale( SAMPLE_TEXTURE2D( _BumpMap, sampler_BumpMap, temp_output_133_0_g7 ), _NormalStrength );
				unpack98_g7.z = lerp( 1, unpack98_g7.z, saturate(_NormalStrength) );
				float3 temp_output_33_6 = unpack98_g7;
				float3 temp_output_975_0_g31 = temp_output_33_6;
				float3 Normal1069_g31 = temp_output_975_0_g31;
				float3 ase_worldTangent = IN.ase_texcoord5.xyz;
				float3 ase_worldNormal = IN.ase_texcoord6.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord7.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal12_g35 = Normal1069_g31;
				float3 worldNormal12_g35 = normalize( float3(dot(tanToWorld0,tanNormal12_g35), dot(tanToWorld1,tanNormal12_g35), dot(tanToWorld2,tanNormal12_g35)) );
				float3 worldNormalValue185_g35 = worldNormal12_g35;
				float3 WorldNormal151_g35 = worldNormalValue185_g35;
				float2 temp_output_1255_0_g31 = (IN.ase_texcoord4.zw*(unity_DynamicLightmapST).xy + (unity_DynamicLightmapST).zw);
				float2 UV2Dynamic1251_g31 = temp_output_1255_0_g31;
				half2 LightmapUV1_g33 = UV2Dynamic1251_g31;
				half4 localCalculateShadowMask1_g33 = CalculateShadowMask1_g33( LightmapUV1_g33 );
				float4 shadowMaskValue182_g35 = localCalculateShadowMask1_g33;
				float4 ShadowMask151_g35 = shadowMaskValue182_g35;
				float3 localAdditionalLightsHalfLambertMask12x151_g35 = AdditionalLightsHalfLambertMask12x( WorldPosition151_g35 , WorldNormal151_g35 , ShadowMask151_g35 );
				float3 SRP_Lambert_Half1362_g31 = localAdditionalLightsHalfLambertMask12x151_g35;
				float3 tanNormal1158_g31 = Normal1069_g31;
				float3 worldNormal1158_g31 = normalize( float3(dot(tanToWorld0,tanNormal1158_g31), dot(tanToWorld1,tanNormal1158_g31), dot(tanToWorld2,tanNormal1158_g31)) );
				float2 temp_output_1219_0_g31 = (IN.ase_texcoord8.xy*(unity_LightmapST).xy + (unity_LightmapST).zw);
				float2 UV1Static1247_g31 = temp_output_1219_0_g31;
				float3 bakedGI1252_g31 = ASEBakedGI( worldNormal1158_g31, UV1Static1247_g31, true);
				float3 lerpResult1169_g31 = lerp( float3( 1,1,1 ) , ( SRP_Lambert_Half1362_g31 + bakedGI1252_g31 ) , _IndirectDiffuse);
				float3 temp_output_1173_0_g31 = ( lerpResult1169_g31 + step( float3( 1,1,1 ) , ( 1.0 - lerpResult1169_g31 ) ) );
				float3 tanNormal1072_g31 = temp_output_975_0_g31;
				float3 worldNormal1072_g31 = normalize( float3(dot(tanToWorld0,tanNormal1072_g31), dot(tanToWorld1,tanNormal1072_g31), dot(tanToWorld2,tanNormal1072_g31)) );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float3 normalizeResult1044_g31 = ASESafeNormalize( ( ase_worldViewDir + SafeNormalize(_MainLightPosition.xyz) ) );
				float dotResult1046_g31 = dot( worldNormal1072_g31 , normalizeResult1044_g31 );
				float Dot_NdotH1098_g31 = dotResult1046_g31;
				float temp_output_1108_0_g31 = ( 1.0 - ( ( 1.0 - Dot_NdotH1098_g31 ) * _MainLightPosition.w ) );
				float ase_lightIntensity = max( max( _MainLightColor.r, _MainLightColor.g ), _MainLightColor.b );
				float4 ase_lightColor = float4( _MainLightColor.rgb / ase_lightIntensity, ase_lightIntensity );
				float LightColorIntensity1349_g31 = max( ase_lightColor.a , 0.0 );
				float3 temp_output_1112_0_g31 = ( temp_output_1173_0_g31 * temp_output_1108_0_g31 * LightColorIntensity1349_g31 );
				float dotResult1055_g31 = dot( worldNormal1072_g31 , SafeNormalize(_MainLightPosition.xyz) );
				float Dot_NdotL1100_g31 = dotResult1055_g31;
				float Shadow_Strength1138_g31 = _ShadowStrength;
				float lerpResult1130_g31 = lerp( ( Shadow_Strength1138_g31 * Shadow_Strength1138_g31 * 0.7978846 ) , ( Shadow_Strength1138_g31 * Shadow_Strength1138_g31 * sqrt( ( 2.0 / ( 2.0 * PI ) ) ) ) , _ShadowApproxmation);
				float temp_output_1312_0_g31 = ( ( max( Dot_NdotL1100_g31 , 0.0 ) * lerpResult1130_g31 ) + ( 1.0 - lerpResult1130_g31 ) );
				float temp_output_1117_0_g31 = saturate( ( ( ( max( Dot_NdotH1098_g31 , 0.0 ) * temp_output_1312_0_g31 * temp_output_1312_0_g31 ) + _ShadowOffset ) / _ShadowSharpness ) );
				float3 temp_cast_1 = (temp_output_1117_0_g31).xxx;
				float3 temp_cast_2 = (temp_output_1117_0_g31).xxx;
				float3 lerpResult1379_g31 = lerp( (_ShadowColor).rgb , temp_cast_2 , temp_output_1117_0_g31);
				float3 lerpResult1377_g31 = lerp( temp_cast_1 , lerpResult1379_g31 , _ShadowColorEnable);
				float3 temp_cast_3 = (temp_output_1108_0_g31).xxx;
				float3 lerpResult1109_g31 = lerp( ( lerpResult1377_g31 * Dot_NdotH1098_g31 ) , temp_cast_3 , _ShadowStrength);
				float4 tex2DNode21_g7 = SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, temp_output_133_0_g7 );
				float3 temp_output_89_0_g7 = ( (_BaseColor).rgb * (tex2DNode21_g7).rgb * _Brightness );
				float3 temp_output_898_0_g31 = temp_output_89_0_g7;
				float3 temp_output_1210_0_g31 = saturate( ( ( temp_output_1112_0_g31 + lerpResult1109_g31 ) * temp_output_898_0_g31 ) );
				float3 worldPosValue184_g32 = WorldPosition;
				float3 WorldPosition157_g32 = worldPosValue184_g32;
				float3 tanNormal1260_g31 = Normal1069_g31;
				float3 worldNormal1260_g31 = normalize( float3(dot(tanToWorld0,tanNormal1260_g31), dot(tanToWorld1,tanNormal1260_g31), dot(tanToWorld2,tanNormal1260_g31)) );
				float3 worldNormalValue185_g32 = worldNormal1260_g31;
				float3 WorldNormal157_g32 = worldNormalValue185_g32;
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 temp_output_15_0_g32 = ase_worldViewDir;
				float3 WorldView157_g32 = temp_output_15_0_g32;
				float3 temp_output_1196_0_g31 = (_IndirectSpecularColor).rgb;
				float3 temp_output_14_0_g32 = temp_output_1196_0_g31;
				float3 SpecColor157_g32 = temp_output_14_0_g32;
				float temp_output_18_0_g32 = _IndirectSpecularSmoothness;
				float Smoothness157_g32 = temp_output_18_0_g32;
				float3 localAdditionalLightsSpecular10x12x157_g32 = AdditionalLightsSpecular10x12x( WorldPosition157_g32 , WorldNormal157_g32 , WorldView157_g32 , SpecColor157_g32 , Smoothness157_g32 );
				float3 LightColorAtten1105_g31 = ( Dot_NdotH1098_g31 * ase_lightColor.rgb );
				float3 normalizeResult1197_g31 = normalize( ( ase_worldViewDir + SafeNormalize(_MainLightPosition.xyz) ) );
				float dotResult1187_g31 = dot( normalizeResult1197_g31 , worldNormal1260_g31 );
				float3 temp_output_1192_0_g31 = ( temp_output_1196_0_g31 * LightColorAtten1105_g31 * pow( max( dotResult1187_g31 , 0.0 ) , exp2( (_IndirectSpecularSmoothness*10.0 + 1.0) ) ) );
				float3 temp_output_1202_0_g31 = ( localAdditionalLightsSpecular10x12x157_g32 + temp_output_1192_0_g31 );
				float3 temp_cast_4 = (1.0).xxx;
				half3 reflectVector1296_g31 = reflect( -ase_worldViewDir, worldNormal1260_g31 );
				float3 indirectSpecular1296_g31 = GlossyEnvironmentReflection( reflectVector1296_g31, 1.0 - _IndirectSpecularSmoothness, _IndirectSpecularOcclusion );
				float3 lerpResult1266_g31 = lerp( temp_cast_4 , ( indirectSpecular1296_g31 + step( float3( 1,1,1 ) , ( 1.0 - indirectSpecular1296_g31 ) ) ) , _IndirectSpecular);
				float3 BaseColor1240_g31 = temp_output_898_0_g31;
				float3 switchResult1238_g31 = (((ase_vface>0)?(( temp_output_1202_0_g31 + lerpResult1266_g31 )):(BaseColor1240_g31)));
				float fresnelNdotV1262_g31 = dot( worldNormal1260_g31, ase_worldViewDir );
				float fresnelNode1262_g31 = ( 0.04 + _IndirectSpecularSmoothness * pow( 1.0 - fresnelNdotV1262_g31, 5.0 ) );
				float3 lerpResult1236_g31 = lerp( temp_output_1210_0_g31 , switchResult1238_g31 , saturate( fresnelNode1262_g31 ));
				

				float3 BaseColor = lerpResult1236_g31;
				float3 Emission = 0;
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
			#define ASE_BAKEDGI 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120113
			#define ASE_USING_SAMPLING_MACROS 1


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

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL


			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
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
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainUVs;
			float4 _IndirectSpecularColor;
			float4 _ShadowColor;
			half4 _BaseColor;
			int _Cull;
			half _SmoothnessStrength;
			float _MetallicStrength;
			half _IndirectSpecular;
			half _IndirectSpecularOcclusion;
			half _IndirectSpecularSmoothness;
			half _Brightness;
			float _ShadowColorEnable;
			half _ShadowSharpness;
			half _ShadowOffset;
			half _ShadowApproxmation;
			half _ShadowStrength;
			float _IndirectDiffuse;
			half _NormalStrength;
			half _OcclusionStrengthAO;
			float _BakedGIEnable;
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

			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);


			half4 CalculateShadowMask1_g33( half2 LightmapUV )
			{
				#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
				return SAMPLE_SHADOWMASK( LightmapUV.xy );
				#elif !defined (LIGHTMAP_ON)
				return unity_ProbesOcclusion;
				#else
				return half4( 1, 1, 1, 1 );
				#endif
			}
			
			float3 AdditionalLightsHalfLambertMask12x( float3 WorldPosition, float3 WorldNormal, float4 ShadowMask )
			{
				float3 Color = 0;
				#ifdef _ADDITIONAL_LIGHTS
					uint lightCount = GetAdditionalLightsCount();
					LIGHT_LOOP_BEGIN( lightCount )
						#if ASE_SRP_VERSION >= 100000
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#else
						Light light = GetAdditionalLight(lightIndex, WorldPosition);
						#endif
						half3 AttLightColor = light.color *(light.distanceAttenuation * light.shadowAttenuation);
						Color +=(dot(light.direction, WorldNormal)*0.5+0.5 )* AttLightColor;
					LIGHT_LOOP_END
				#endif
				return Color;
			}
			
			float3 ASEBakedGI( float3 normalWS, float2 uvStaticLightmap, bool applyScaling )
			{
			#ifdef LIGHTMAP_ON
				if( applyScaling )
					uvStaticLightmap = uvStaticLightmap * unity_LightmapST.xy + unity_LightmapST.zw;
				return SampleLightmap( uvStaticLightmap, normalWS );
			#else
				return SampleSH(normalWS);
			#endif
			}
			
			float3 ASESafeNormalize(float3 inVec)
			{
				float dp3 = max(1.175494351e-38, dot(inVec, inVec));
				return inVec* rsqrt(dp3);
			}
			
			float3 AdditionalLightsSpecular10x12x( float3 WorldPosition, float3 WorldNormal, float3 WorldView, float3 SpecColor, float Smoothness )
			{
				float3 Color = 0;
				#ifdef _ADDITIONAL_LIGHTS
					Smoothness = exp2(10 * Smoothness + 1);
					uint lightCount = GetAdditionalLightsCount();
					LIGHT_LOOP_BEGIN( lightCount )
						Light light = GetAdditionalLight(lightIndex, WorldPosition);
						half3 AttLightColor = light.color *(light.distanceAttenuation * light.shadowAttenuation);
						Color += LightingSpecular(AttLightColor, light.direction, WorldNormal, WorldView, half4(SpecColor, 0), Smoothness);	
					LIGHT_LOOP_END
				#endif
				return Color;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.normalOS);
				o.ase_texcoord4.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord5.xyz = ase_worldBitangent;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord2.zw = v.ase_texcoord2.xy;
				o.ase_texcoord6.xy = v.ase_texcoord1.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;

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
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord1 = v.ase_texcoord1;
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
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
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

			half4 frag(VertexOutput IN , bool ase_vface : SV_IsFrontFace ) : SV_TARGET
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

				float3 worldPosValue184_g35 = WorldPosition;
				float3 WorldPosition151_g35 = worldPosValue184_g35;
				float2 temp_output_133_0_g7 = ( ( IN.ase_texcoord2.xy * (_MainUVs).xy ) + (_MainUVs).zw );
				float3 unpack98_g7 = UnpackNormalScale( SAMPLE_TEXTURE2D( _BumpMap, sampler_BumpMap, temp_output_133_0_g7 ), _NormalStrength );
				unpack98_g7.z = lerp( 1, unpack98_g7.z, saturate(_NormalStrength) );
				float3 temp_output_33_6 = unpack98_g7;
				float3 temp_output_975_0_g31 = temp_output_33_6;
				float3 Normal1069_g31 = temp_output_975_0_g31;
				float3 ase_worldTangent = IN.ase_texcoord3.xyz;
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal12_g35 = Normal1069_g31;
				float3 worldNormal12_g35 = normalize( float3(dot(tanToWorld0,tanNormal12_g35), dot(tanToWorld1,tanNormal12_g35), dot(tanToWorld2,tanNormal12_g35)) );
				float3 worldNormalValue185_g35 = worldNormal12_g35;
				float3 WorldNormal151_g35 = worldNormalValue185_g35;
				float2 temp_output_1255_0_g31 = (IN.ase_texcoord2.zw*(unity_DynamicLightmapST).xy + (unity_DynamicLightmapST).zw);
				float2 UV2Dynamic1251_g31 = temp_output_1255_0_g31;
				half2 LightmapUV1_g33 = UV2Dynamic1251_g31;
				half4 localCalculateShadowMask1_g33 = CalculateShadowMask1_g33( LightmapUV1_g33 );
				float4 shadowMaskValue182_g35 = localCalculateShadowMask1_g33;
				float4 ShadowMask151_g35 = shadowMaskValue182_g35;
				float3 localAdditionalLightsHalfLambertMask12x151_g35 = AdditionalLightsHalfLambertMask12x( WorldPosition151_g35 , WorldNormal151_g35 , ShadowMask151_g35 );
				float3 SRP_Lambert_Half1362_g31 = localAdditionalLightsHalfLambertMask12x151_g35;
				float3 tanNormal1158_g31 = Normal1069_g31;
				float3 worldNormal1158_g31 = normalize( float3(dot(tanToWorld0,tanNormal1158_g31), dot(tanToWorld1,tanNormal1158_g31), dot(tanToWorld2,tanNormal1158_g31)) );
				float2 temp_output_1219_0_g31 = (IN.ase_texcoord6.xy*(unity_LightmapST).xy + (unity_LightmapST).zw);
				float2 UV1Static1247_g31 = temp_output_1219_0_g31;
				float3 bakedGI1252_g31 = ASEBakedGI( worldNormal1158_g31, UV1Static1247_g31, true);
				float3 lerpResult1169_g31 = lerp( float3( 1,1,1 ) , ( SRP_Lambert_Half1362_g31 + bakedGI1252_g31 ) , _IndirectDiffuse);
				float3 temp_output_1173_0_g31 = ( lerpResult1169_g31 + step( float3( 1,1,1 ) , ( 1.0 - lerpResult1169_g31 ) ) );
				float3 tanNormal1072_g31 = temp_output_975_0_g31;
				float3 worldNormal1072_g31 = normalize( float3(dot(tanToWorld0,tanNormal1072_g31), dot(tanToWorld1,tanNormal1072_g31), dot(tanToWorld2,tanNormal1072_g31)) );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float3 normalizeResult1044_g31 = ASESafeNormalize( ( ase_worldViewDir + SafeNormalize(_MainLightPosition.xyz) ) );
				float dotResult1046_g31 = dot( worldNormal1072_g31 , normalizeResult1044_g31 );
				float Dot_NdotH1098_g31 = dotResult1046_g31;
				float temp_output_1108_0_g31 = ( 1.0 - ( ( 1.0 - Dot_NdotH1098_g31 ) * _MainLightPosition.w ) );
				float ase_lightIntensity = max( max( _MainLightColor.r, _MainLightColor.g ), _MainLightColor.b );
				float4 ase_lightColor = float4( _MainLightColor.rgb / ase_lightIntensity, ase_lightIntensity );
				float LightColorIntensity1349_g31 = max( ase_lightColor.a , 0.0 );
				float3 temp_output_1112_0_g31 = ( temp_output_1173_0_g31 * temp_output_1108_0_g31 * LightColorIntensity1349_g31 );
				float dotResult1055_g31 = dot( worldNormal1072_g31 , SafeNormalize(_MainLightPosition.xyz) );
				float Dot_NdotL1100_g31 = dotResult1055_g31;
				float Shadow_Strength1138_g31 = _ShadowStrength;
				float lerpResult1130_g31 = lerp( ( Shadow_Strength1138_g31 * Shadow_Strength1138_g31 * 0.7978846 ) , ( Shadow_Strength1138_g31 * Shadow_Strength1138_g31 * sqrt( ( 2.0 / ( 2.0 * PI ) ) ) ) , _ShadowApproxmation);
				float temp_output_1312_0_g31 = ( ( max( Dot_NdotL1100_g31 , 0.0 ) * lerpResult1130_g31 ) + ( 1.0 - lerpResult1130_g31 ) );
				float temp_output_1117_0_g31 = saturate( ( ( ( max( Dot_NdotH1098_g31 , 0.0 ) * temp_output_1312_0_g31 * temp_output_1312_0_g31 ) + _ShadowOffset ) / _ShadowSharpness ) );
				float3 temp_cast_1 = (temp_output_1117_0_g31).xxx;
				float3 temp_cast_2 = (temp_output_1117_0_g31).xxx;
				float3 lerpResult1379_g31 = lerp( (_ShadowColor).rgb , temp_cast_2 , temp_output_1117_0_g31);
				float3 lerpResult1377_g31 = lerp( temp_cast_1 , lerpResult1379_g31 , _ShadowColorEnable);
				float3 temp_cast_3 = (temp_output_1108_0_g31).xxx;
				float3 lerpResult1109_g31 = lerp( ( lerpResult1377_g31 * Dot_NdotH1098_g31 ) , temp_cast_3 , _ShadowStrength);
				float4 tex2DNode21_g7 = SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, temp_output_133_0_g7 );
				float3 temp_output_89_0_g7 = ( (_BaseColor).rgb * (tex2DNode21_g7).rgb * _Brightness );
				float3 temp_output_898_0_g31 = temp_output_89_0_g7;
				float3 temp_output_1210_0_g31 = saturate( ( ( temp_output_1112_0_g31 + lerpResult1109_g31 ) * temp_output_898_0_g31 ) );
				float3 worldPosValue184_g32 = WorldPosition;
				float3 WorldPosition157_g32 = worldPosValue184_g32;
				float3 tanNormal1260_g31 = Normal1069_g31;
				float3 worldNormal1260_g31 = normalize( float3(dot(tanToWorld0,tanNormal1260_g31), dot(tanToWorld1,tanNormal1260_g31), dot(tanToWorld2,tanNormal1260_g31)) );
				float3 worldNormalValue185_g32 = worldNormal1260_g31;
				float3 WorldNormal157_g32 = worldNormalValue185_g32;
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 temp_output_15_0_g32 = ase_worldViewDir;
				float3 WorldView157_g32 = temp_output_15_0_g32;
				float3 temp_output_1196_0_g31 = (_IndirectSpecularColor).rgb;
				float3 temp_output_14_0_g32 = temp_output_1196_0_g31;
				float3 SpecColor157_g32 = temp_output_14_0_g32;
				float temp_output_18_0_g32 = _IndirectSpecularSmoothness;
				float Smoothness157_g32 = temp_output_18_0_g32;
				float3 localAdditionalLightsSpecular10x12x157_g32 = AdditionalLightsSpecular10x12x( WorldPosition157_g32 , WorldNormal157_g32 , WorldView157_g32 , SpecColor157_g32 , Smoothness157_g32 );
				float3 LightColorAtten1105_g31 = ( Dot_NdotH1098_g31 * ase_lightColor.rgb );
				float3 normalizeResult1197_g31 = normalize( ( ase_worldViewDir + SafeNormalize(_MainLightPosition.xyz) ) );
				float dotResult1187_g31 = dot( normalizeResult1197_g31 , worldNormal1260_g31 );
				float3 temp_output_1192_0_g31 = ( temp_output_1196_0_g31 * LightColorAtten1105_g31 * pow( max( dotResult1187_g31 , 0.0 ) , exp2( (_IndirectSpecularSmoothness*10.0 + 1.0) ) ) );
				float3 temp_output_1202_0_g31 = ( localAdditionalLightsSpecular10x12x157_g32 + temp_output_1192_0_g31 );
				float3 temp_cast_4 = (1.0).xxx;
				half3 reflectVector1296_g31 = reflect( -ase_worldViewDir, worldNormal1260_g31 );
				float3 indirectSpecular1296_g31 = GlossyEnvironmentReflection( reflectVector1296_g31, 1.0 - _IndirectSpecularSmoothness, _IndirectSpecularOcclusion );
				float3 lerpResult1266_g31 = lerp( temp_cast_4 , ( indirectSpecular1296_g31 + step( float3( 1,1,1 ) , ( 1.0 - indirectSpecular1296_g31 ) ) ) , _IndirectSpecular);
				float3 BaseColor1240_g31 = temp_output_898_0_g31;
				float3 switchResult1238_g31 = (((ase_vface>0)?(( temp_output_1202_0_g31 + lerpResult1266_g31 )):(BaseColor1240_g31)));
				float fresnelNdotV1262_g31 = dot( worldNormal1260_g31, ase_worldViewDir );
				float fresnelNode1262_g31 = ( 0.04 + _IndirectSpecularSmoothness * pow( 1.0 - fresnelNdotV1262_g31, 5.0 ) );
				float3 lerpResult1236_g31 = lerp( temp_output_1210_0_g31 , switchResult1238_g31 , saturate( fresnelNode1262_g31 ));
				

				float3 BaseColor = lerpResult1236_g31;
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
			#define ASE_BAKEDGI 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120113
			#define ASE_USING_SAMPLING_MACROS 1


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
			float4 _MainUVs;
			float4 _IndirectSpecularColor;
			float4 _ShadowColor;
			half4 _BaseColor;
			int _Cull;
			half _SmoothnessStrength;
			float _MetallicStrength;
			half _IndirectSpecular;
			half _IndirectSpecularOcclusion;
			half _IndirectSpecularSmoothness;
			half _Brightness;
			float _ShadowColorEnable;
			half _ShadowSharpness;
			half _ShadowOffset;
			half _ShadowApproxmation;
			half _ShadowStrength;
			float _IndirectDiffuse;
			half _NormalStrength;
			half _OcclusionStrengthAO;
			float _BakedGIEnable;
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

			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord5.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord5.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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

				float2 temp_output_133_0_g7 = ( ( IN.ase_texcoord5.xy * (_MainUVs).xy ) + (_MainUVs).zw );
				float3 unpack98_g7 = UnpackNormalScale( SAMPLE_TEXTURE2D( _BumpMap, sampler_BumpMap, temp_output_133_0_g7 ), _NormalStrength );
				unpack98_g7.z = lerp( 1, unpack98_g7.z, saturate(_NormalStrength) );
				float3 temp_output_33_6 = unpack98_g7;
				

				float3 Normal = temp_output_33_6;
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
			#define ASE_BAKEDGI 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120113
			#define ASE_USING_SAMPLING_MACROS 1


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

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR


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
				float4 ase_texcoord9 : TEXCOORD9;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainUVs;
			float4 _IndirectSpecularColor;
			float4 _ShadowColor;
			half4 _BaseColor;
			int _Cull;
			half _SmoothnessStrength;
			float _MetallicStrength;
			half _IndirectSpecular;
			half _IndirectSpecularOcclusion;
			half _IndirectSpecularSmoothness;
			half _Brightness;
			float _ShadowColorEnable;
			half _ShadowSharpness;
			half _ShadowOffset;
			half _ShadowApproxmation;
			half _ShadowStrength;
			float _IndirectDiffuse;
			half _NormalStrength;
			half _OcclusionStrengthAO;
			float _BakedGIEnable;
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

			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			TEXTURE2D(_MetallicGlossMap);
			TEXTURE2D(_SmoothnessMap);
			TEXTURE2D(_OcclusionMap);


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"

			half4 CalculateShadowMask1_g33( half2 LightmapUV )
			{
				#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
				return SAMPLE_SHADOWMASK( LightmapUV.xy );
				#elif !defined (LIGHTMAP_ON)
				return unity_ProbesOcclusion;
				#else
				return half4( 1, 1, 1, 1 );
				#endif
			}
			
			float3 AdditionalLightsHalfLambertMask12x( float3 WorldPosition, float3 WorldNormal, float4 ShadowMask )
			{
				float3 Color = 0;
				#ifdef _ADDITIONAL_LIGHTS
					uint lightCount = GetAdditionalLightsCount();
					LIGHT_LOOP_BEGIN( lightCount )
						#if ASE_SRP_VERSION >= 100000
						Light light = GetAdditionalLight(lightIndex, WorldPosition, ShadowMask);
						#else
						Light light = GetAdditionalLight(lightIndex, WorldPosition);
						#endif
						half3 AttLightColor = light.color *(light.distanceAttenuation * light.shadowAttenuation);
						Color +=(dot(light.direction, WorldNormal)*0.5+0.5 )* AttLightColor;
					LIGHT_LOOP_END
				#endif
				return Color;
			}
			
			float3 ASEBakedGI( float3 normalWS, float2 uvStaticLightmap, bool applyScaling )
			{
			#ifdef LIGHTMAP_ON
				if( applyScaling )
					uvStaticLightmap = uvStaticLightmap * unity_LightmapST.xy + unity_LightmapST.zw;
				return SampleLightmap( uvStaticLightmap, normalWS );
			#else
				return SampleSH(normalWS);
			#endif
			}
			
			float3 ASESafeNormalize(float3 inVec)
			{
				float dp3 = max(1.175494351e-38, dot(inVec, inVec));
				return inVec* rsqrt(dp3);
			}
			
			float3 AdditionalLightsSpecular10x12x( float3 WorldPosition, float3 WorldNormal, float3 WorldView, float3 SpecColor, float Smoothness )
			{
				float3 Color = 0;
				#ifdef _ADDITIONAL_LIGHTS
					Smoothness = exp2(10 * Smoothness + 1);
					uint lightCount = GetAdditionalLightsCount();
					LIGHT_LOOP_BEGIN( lightCount )
						Light light = GetAdditionalLight(lightIndex, WorldPosition);
						half3 AttLightColor = light.color *(light.distanceAttenuation * light.shadowAttenuation);
						Color += LightingSpecular(AttLightColor, light.direction, WorldNormal, WorldView, half4(SpecColor, 0), Smoothness);	
					LIGHT_LOOP_END
				#endif
				return Color;
			}
			
			float4 URPDecodeInstruction984_g26(  )
			{
				return float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0, 0);
			}
			
			void SampleLightmapBicubic( float3 normalWS, float3 backNormalWS, float2 staticUV, float2 dynamicUV, out float3 bakeDiffuseLighting, out float3 backBakeDiffuseLighting, float4 decodeInstructions, float4 staticDir, float4 dynamicDir )
			{
				bakeDiffuseLighting = 0;
				backBakeDiffuseLighting = 0;
				#if defined( SHADER_STAGE_FRAGMENT ) || defined( SHADER_STAGE_RAY_TRACING )
				    int width, height;
				    float4 texSize;
				    float3 illuminance;
				    float halfLambert;
				    float backHalfLambert;
				    #if defined( LIGHTMAP_ON )
				        #if defined( UNITY_DOTS_INSTANCING_ENABLED )
				            #define LM_NAME unity_Lightmaps
				            #define LM_SAMPLER samplerunity_Lightmaps
				            #define LM_SLICE unity_LightmapIndex.x
				        #else
				            #define LM_NAME unity_Lightmap
				            #define LM_SAMPLER samplerunity_Lightmap
				            #define LM_SLICE 0
				        #endif
				        #ifdef UNITY_LIGHTMAP_FULL_HDR
				            bool encodedLightmap = false;
				        #else
				            bool encodedLightmap = true;
				        #endif
				        LIGHTMAP_NAME.GetDimensions( width, height );
				        texSize = float4( width, height, 1.0 / float2( width, height ) );
				        float4 encodedIlluminance = SampleTexture2DBicubic( LM_NAME, LM_SAMPLER, staticUV, texSize, float2( 1, 1 ), LM_SLICE ).rgba;
				        illuminance = encodedLightmap ? DecodeLightmap( encodedIlluminance, decodeInstructions ) : encodedIlluminance.rgb;
				        #if defined( DIRLIGHTMAP_COMBINED )
				            halfLambert = dot( normalWS, staticDir.xyz - 0.5 ) + 0.5;
				            bakeDiffuseLighting += illuminance * halfLambert / max( 1e-4, staticDir.w );
				            backHalfLambert = dot( backNormalWS, staticDir.xyz - 0.5 ) + 0.5;
				            backBakeDiffuseLighting += illuminance * backHalfLambert / max( 1e-4, staticDir.w );
				        #else
				            bakeDiffuseLighting += illuminance;
				            backBakeDiffuseLighting += illuminance;
				        #endif
				    #endif
				    #if defined( DYNAMICLIGHTMAP_ON )
				        unity_DynamicLightmap.GetDimensions( width, height );
				        texSize = float4( width, height, 1.0 / float2( width, height ) );
				        illuminance = SampleTexture2DBicubic( unity_DynamicLightmap, samplerunity_DynamicLightmap, dynamicUV, texSize, float2( 1, 1 ), 0 ).rgb;
				        #if defined( DIRLIGHTMAP_COMBINED )
				            halfLambert = dot( normalWS, dynamicDir.xyz - 0.5 ) + 0.5;
				            bakeDiffuseLighting += illuminance * halfLambert / max( 1e-4, dynamicDir.w );
				            backHalfLambert = dot( backNormalWS, dynamicDir.xyz - 0.5 ) + 0.5;
				            backBakeDiffuseLighting += illuminance * backHalfLambert / max( 1e-4, dynamicDir.w );
				        #else
				            bakeDiffuseLighting += illuminance;
				            backBakeDiffuseLighting += illuminance;
				        #endif
				    #endif
				#endif
				return;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord8.xy = v.texcoord.xy;
				o.ase_texcoord8.zw = v.texcoord2.xy;
				o.ase_texcoord9.xy = v.texcoord1.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord9.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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
								, bool ase_vface : SV_IsFrontFace )
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

				float3 worldPosValue184_g35 = WorldPosition;
				float3 WorldPosition151_g35 = worldPosValue184_g35;
				float2 temp_output_133_0_g7 = ( ( IN.ase_texcoord8.xy * (_MainUVs).xy ) + (_MainUVs).zw );
				float3 unpack98_g7 = UnpackNormalScale( SAMPLE_TEXTURE2D( _BumpMap, sampler_BumpMap, temp_output_133_0_g7 ), _NormalStrength );
				unpack98_g7.z = lerp( 1, unpack98_g7.z, saturate(_NormalStrength) );
				float3 temp_output_33_6 = unpack98_g7;
				float3 temp_output_975_0_g31 = temp_output_33_6;
				float3 Normal1069_g31 = temp_output_975_0_g31;
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal12_g35 = Normal1069_g31;
				float3 worldNormal12_g35 = normalize( float3(dot(tanToWorld0,tanNormal12_g35), dot(tanToWorld1,tanNormal12_g35), dot(tanToWorld2,tanNormal12_g35)) );
				float3 worldNormalValue185_g35 = worldNormal12_g35;
				float3 WorldNormal151_g35 = worldNormalValue185_g35;
				float2 temp_output_1255_0_g31 = (IN.ase_texcoord8.zw*(unity_DynamicLightmapST).xy + (unity_DynamicLightmapST).zw);
				float2 UV2Dynamic1251_g31 = temp_output_1255_0_g31;
				half2 LightmapUV1_g33 = UV2Dynamic1251_g31;
				half4 localCalculateShadowMask1_g33 = CalculateShadowMask1_g33( LightmapUV1_g33 );
				float4 shadowMaskValue182_g35 = localCalculateShadowMask1_g33;
				float4 ShadowMask151_g35 = shadowMaskValue182_g35;
				float3 localAdditionalLightsHalfLambertMask12x151_g35 = AdditionalLightsHalfLambertMask12x( WorldPosition151_g35 , WorldNormal151_g35 , ShadowMask151_g35 );
				float3 SRP_Lambert_Half1362_g31 = localAdditionalLightsHalfLambertMask12x151_g35;
				float3 tanNormal1158_g31 = Normal1069_g31;
				float3 worldNormal1158_g31 = normalize( float3(dot(tanToWorld0,tanNormal1158_g31), dot(tanToWorld1,tanNormal1158_g31), dot(tanToWorld2,tanNormal1158_g31)) );
				float2 temp_output_1219_0_g31 = (IN.ase_texcoord9.xy*(unity_LightmapST).xy + (unity_LightmapST).zw);
				float2 UV1Static1247_g31 = temp_output_1219_0_g31;
				float3 bakedGI1252_g31 = ASEBakedGI( worldNormal1158_g31, UV1Static1247_g31, true);
				float3 lerpResult1169_g31 = lerp( float3( 1,1,1 ) , ( SRP_Lambert_Half1362_g31 + bakedGI1252_g31 ) , _IndirectDiffuse);
				float3 temp_output_1173_0_g31 = ( lerpResult1169_g31 + step( float3( 1,1,1 ) , ( 1.0 - lerpResult1169_g31 ) ) );
				float3 tanNormal1072_g31 = temp_output_975_0_g31;
				float3 worldNormal1072_g31 = normalize( float3(dot(tanToWorld0,tanNormal1072_g31), dot(tanToWorld1,tanNormal1072_g31), dot(tanToWorld2,tanNormal1072_g31)) );
				float3 normalizeResult1044_g31 = ASESafeNormalize( ( WorldViewDirection + SafeNormalize(_MainLightPosition.xyz) ) );
				float dotResult1046_g31 = dot( worldNormal1072_g31 , normalizeResult1044_g31 );
				float Dot_NdotH1098_g31 = dotResult1046_g31;
				float temp_output_1108_0_g31 = ( 1.0 - ( ( 1.0 - Dot_NdotH1098_g31 ) * _MainLightPosition.w ) );
				float ase_lightIntensity = max( max( _MainLightColor.r, _MainLightColor.g ), _MainLightColor.b );
				float4 ase_lightColor = float4( _MainLightColor.rgb / ase_lightIntensity, ase_lightIntensity );
				float LightColorIntensity1349_g31 = max( ase_lightColor.a , 0.0 );
				float3 temp_output_1112_0_g31 = ( temp_output_1173_0_g31 * temp_output_1108_0_g31 * LightColorIntensity1349_g31 );
				float dotResult1055_g31 = dot( worldNormal1072_g31 , SafeNormalize(_MainLightPosition.xyz) );
				float Dot_NdotL1100_g31 = dotResult1055_g31;
				float Shadow_Strength1138_g31 = _ShadowStrength;
				float lerpResult1130_g31 = lerp( ( Shadow_Strength1138_g31 * Shadow_Strength1138_g31 * 0.7978846 ) , ( Shadow_Strength1138_g31 * Shadow_Strength1138_g31 * sqrt( ( 2.0 / ( 2.0 * PI ) ) ) ) , _ShadowApproxmation);
				float temp_output_1312_0_g31 = ( ( max( Dot_NdotL1100_g31 , 0.0 ) * lerpResult1130_g31 ) + ( 1.0 - lerpResult1130_g31 ) );
				float temp_output_1117_0_g31 = saturate( ( ( ( max( Dot_NdotH1098_g31 , 0.0 ) * temp_output_1312_0_g31 * temp_output_1312_0_g31 ) + _ShadowOffset ) / _ShadowSharpness ) );
				float3 temp_cast_1 = (temp_output_1117_0_g31).xxx;
				float3 temp_cast_2 = (temp_output_1117_0_g31).xxx;
				float3 lerpResult1379_g31 = lerp( (_ShadowColor).rgb , temp_cast_2 , temp_output_1117_0_g31);
				float3 lerpResult1377_g31 = lerp( temp_cast_1 , lerpResult1379_g31 , _ShadowColorEnable);
				float3 temp_cast_3 = (temp_output_1108_0_g31).xxx;
				float3 lerpResult1109_g31 = lerp( ( lerpResult1377_g31 * Dot_NdotH1098_g31 ) , temp_cast_3 , _ShadowStrength);
				float4 tex2DNode21_g7 = SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, temp_output_133_0_g7 );
				float3 temp_output_89_0_g7 = ( (_BaseColor).rgb * (tex2DNode21_g7).rgb * _Brightness );
				float3 temp_output_898_0_g31 = temp_output_89_0_g7;
				float3 temp_output_1210_0_g31 = saturate( ( ( temp_output_1112_0_g31 + lerpResult1109_g31 ) * temp_output_898_0_g31 ) );
				float3 worldPosValue184_g32 = WorldPosition;
				float3 WorldPosition157_g32 = worldPosValue184_g32;
				float3 tanNormal1260_g31 = Normal1069_g31;
				float3 worldNormal1260_g31 = normalize( float3(dot(tanToWorld0,tanNormal1260_g31), dot(tanToWorld1,tanNormal1260_g31), dot(tanToWorld2,tanNormal1260_g31)) );
				float3 worldNormalValue185_g32 = worldNormal1260_g31;
				float3 WorldNormal157_g32 = worldNormalValue185_g32;
				float3 temp_output_15_0_g32 = WorldViewDirection;
				float3 WorldView157_g32 = temp_output_15_0_g32;
				float3 temp_output_1196_0_g31 = (_IndirectSpecularColor).rgb;
				float3 temp_output_14_0_g32 = temp_output_1196_0_g31;
				float3 SpecColor157_g32 = temp_output_14_0_g32;
				float temp_output_18_0_g32 = _IndirectSpecularSmoothness;
				float Smoothness157_g32 = temp_output_18_0_g32;
				float3 localAdditionalLightsSpecular10x12x157_g32 = AdditionalLightsSpecular10x12x( WorldPosition157_g32 , WorldNormal157_g32 , WorldView157_g32 , SpecColor157_g32 , Smoothness157_g32 );
				float3 LightColorAtten1105_g31 = ( Dot_NdotH1098_g31 * ase_lightColor.rgb );
				float3 normalizeResult1197_g31 = normalize( ( WorldViewDirection + SafeNormalize(_MainLightPosition.xyz) ) );
				float dotResult1187_g31 = dot( normalizeResult1197_g31 , worldNormal1260_g31 );
				float3 temp_output_1192_0_g31 = ( temp_output_1196_0_g31 * LightColorAtten1105_g31 * pow( max( dotResult1187_g31 , 0.0 ) , exp2( (_IndirectSpecularSmoothness*10.0 + 1.0) ) ) );
				float3 temp_output_1202_0_g31 = ( localAdditionalLightsSpecular10x12x157_g32 + temp_output_1192_0_g31 );
				float3 temp_cast_4 = (1.0).xxx;
				half3 reflectVector1296_g31 = reflect( -WorldViewDirection, worldNormal1260_g31 );
				float3 indirectSpecular1296_g31 = GlossyEnvironmentReflection( reflectVector1296_g31, 1.0 - _IndirectSpecularSmoothness, _IndirectSpecularOcclusion );
				float3 lerpResult1266_g31 = lerp( temp_cast_4 , ( indirectSpecular1296_g31 + step( float3( 1,1,1 ) , ( 1.0 - indirectSpecular1296_g31 ) ) ) , _IndirectSpecular);
				float3 BaseColor1240_g31 = temp_output_898_0_g31;
				float3 switchResult1238_g31 = (((ase_vface>0)?(( temp_output_1202_0_g31 + lerpResult1266_g31 )):(BaseColor1240_g31)));
				float fresnelNdotV1262_g31 = dot( worldNormal1260_g31, WorldViewDirection );
				float fresnelNode1262_g31 = ( 0.04 + _IndirectSpecularSmoothness * pow( 1.0 - fresnelNdotV1262_g31, 5.0 ) );
				float3 lerpResult1236_g31 = lerp( temp_output_1210_0_g31 , switchResult1238_g31 , saturate( fresnelNode1262_g31 ));
				
				float localSampleLightmapBicubic965_g26 = ( 0.0 );
				float3 temp_output_975_0_g26 = temp_output_33_6;
				float3 tanNormal1070_g26 = temp_output_975_0_g26;
				float3 worldNormal1070_g26 = float3(dot(tanToWorld0,tanNormal1070_g26), dot(tanToWorld1,tanNormal1070_g26), dot(tanToWorld2,tanNormal1070_g26));
				float3 NormalWS1073_g26 = worldNormal1070_g26;
				float3 normalWS965_g26 = NormalWS1073_g26;
				float3 temp_output_1063_0_g26 = ( worldNormal1070_g26 * float3( -1,-1,-1 ) );
				float3 BackNormalWS1101_g26 = temp_output_1063_0_g26;
				float3 backNormalWS965_g26 = BackNormalWS1101_g26;
				float2 temp_output_1219_0_g26 = (IN.ase_texcoord9.xy*(unity_LightmapST).xy + (unity_LightmapST).zw);
				float2 UV1Static1247_g26 = temp_output_1219_0_g26;
				float2 staticUV965_g26 = UV1Static1247_g26;
				float2 temp_output_1255_0_g26 = (IN.ase_texcoord8.zw*(unity_DynamicLightmapST).xy + (unity_DynamicLightmapST).zw);
				float2 UV2Dynamic1251_g26 = temp_output_1255_0_g26;
				float2 dynamicUV965_g26 = UV2Dynamic1251_g26;
				float3 bakeDiffuseLighting965_g26 = float3( 0,0,0 );
				float3 backBakeDiffuseLighting965_g26 = float3( 0,0,0 );
				float4 localURPDecodeInstruction984_g26 = URPDecodeInstruction984_g26();
				float4 decodeInstructions965_g26 = localURPDecodeInstruction984_g26;
				float localSampleDirectionBicubic961_g26 = ( 0.0 );
				float2 staticUV961_g26 = UV1Static1247_g26;
				float2 dynamicUV961_g26 = UV2Dynamic1251_g26;
				float4 staticDir961_g26 = float4( 0,0,0,0 );
				float4 dynamicDir961_g26 = float4( 0,0,0,0 );
				{
				#if defined( DIRLIGHTMAP_COMBINED ) && ( defined( SHADER_STAGE_FRAGMENT ) || defined( SHADER_STAGE_RAY_TRACING ) )
				    int width, height;
				    float4 texSize;
				    #if defined( LIGHTMAP_ON )
				        #if defined( UNITY_DOTS_INSTANCING_ENABLED )
				            #define LM_IND_NAME unity_LightmapsInd
				            #define LM_SAMPLER samplerunity_Lightmaps
				            #define LM_SLICE unity_LightmapIndex.x
				        #else
				            #define LM_IND_NAME unity_LightmapInd
				            #define LM_SAMPLER samplerunity_Lightmap
				            #define LM_SLICE 0
				        #endif
				        LM_IND_NAME.GetDimensions( width, height );
				        texSize = float4( width, height, 1.0 / float2( width, height ) );
				        staticDir961_g26 = SampleTexture2DBicubic( LM_IND_NAME, LM_SAMPLER, staticUV961_g26, texSize, float2( 1, 1 ), LM_SLICE );
				    #endif
				    #if defined( DYNAMICLIGHTMAP_ON )
				        unity_DynamicDirectionality.GetDimensions( width, height );
				        texSize = float4( width, height, 1.0 / float2( width, height ) );
				        dynamicDir961_g26 = SampleTexture2DBicubic( unity_DynamicDirectionality, samplerunity_DynamicLightmap, dynamicUV961_g26, texSize, float2( 1, 1 ), 0 );
				    #endif
				#endif
				}
				float4 staticDir965_g26 = staticDir961_g26;
				float4 dynamicDir965_g26 = dynamicDir961_g26;
				SampleLightmapBicubic( normalWS965_g26 , backNormalWS965_g26 , staticUV965_g26 , dynamicUV965_g26 , bakeDiffuseLighting965_g26 , backBakeDiffuseLighting965_g26 , decodeInstructions965_g26 , staticDir965_g26 , dynamicDir965_g26 );
				float3 lerpResult941_g26 = lerp( float3( 0,0,0 ) , bakeDiffuseLighting965_g26 , _BakedGIEnable);
				

				float3 BaseColor = lerpResult1236_g31;
				float3 Normal = temp_output_33_6;
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = ( _MetallicStrength * (SAMPLE_TEXTURE2D( _MetallicGlossMap, sampler_MainTex, temp_output_133_0_g7 )).rgb ).x;
				float Smoothness = ( _SmoothnessStrength * (SAMPLE_TEXTURE2D( _SmoothnessMap, sampler_MainTex, temp_output_133_0_g7 )).rgb ).x;
				float Occlusion = saturate( ( ( 1.0 - _OcclusionStrengthAO ) * (SAMPLE_TEXTURE2D( _OcclusionMap, sampler_MainTex, temp_output_133_0_g7 )).rgb ) ).x;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = lerpResult941_g26;
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
			#define ASE_BAKEDGI 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120113
			#define ASE_USING_SAMPLING_MACROS 1


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

			

			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainUVs;
			float4 _IndirectSpecularColor;
			float4 _ShadowColor;
			half4 _BaseColor;
			int _Cull;
			half _SmoothnessStrength;
			float _MetallicStrength;
			half _IndirectSpecular;
			half _IndirectSpecularOcclusion;
			half _IndirectSpecularSmoothness;
			half _Brightness;
			float _ShadowColorEnable;
			half _ShadowSharpness;
			half _ShadowOffset;
			half _ShadowApproxmation;
			half _ShadowStrength;
			float _IndirectDiffuse;
			half _NormalStrength;
			half _OcclusionStrengthAO;
			float _BakedGIEnable;
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

				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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
			#define ASE_BAKEDGI 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 120113
			#define ASE_USING_SAMPLING_MACROS 1


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

			

			struct VertexInput
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainUVs;
			float4 _IndirectSpecularColor;
			float4 _ShadowColor;
			half4 _BaseColor;
			int _Cull;
			half _SmoothnessStrength;
			float _MetallicStrength;
			half _IndirectSpecular;
			half _IndirectSpecularOcclusion;
			half _IndirectSpecularSmoothness;
			half _Brightness;
			float _ShadowColorEnable;
			half _ShadowSharpness;
			half _ShadowOffset;
			half _ShadowApproxmation;
			half _ShadowStrength;
			float _IndirectDiffuse;
			half _NormalStrength;
			half _OcclusionStrengthAO;
			float _BakedGIEnable;
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

				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

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
Node;AmplifyShaderEditor.FunctionNode;33;-192,0;Inherit;False;Material Sample;1;;7;09f1910db887ebd4cb569d6c76c63be3;4,251,0,216,0,263,0,346,1;0;12;FLOAT3;1;FLOAT3;6;FLOAT3;372;FLOAT3;328;FLOAT3;3;FLOAT3;5;FLOAT3;2;FLOAT3;4;FLOAT;8;FLOAT;71;FLOAT;72;FLOAT3;378
Node;AmplifyShaderEditor.IntNode;41;512,-80;Inherit;False;Property;_Cull;Render Face;0;1;[Enum];Create;False;1;;0;1;Front,2,Back,1,Both,0;True;0;False;2;2;False;0;1;INT;0
Node;AmplifyShaderEditor.FunctionNode;52;128,208;Inherit;False;Material Baked GI;35;;26;4963945102cd7c746bbe83f48754e7cb;8,910,1,827,1,826,1,838,1,831,1,839,1,1322,0,1323,0;4;975;FLOAT3;0,0,1;False;765;FLOAT3;0,0,1;False;1246;FLOAT2;0,0;False;1250;FLOAT2;0,0;False;2;FLOAT3;948;FLOAT3;949
Node;AmplifyShaderEditor.FunctionNode;34;128,-80;Inherit;False;Material Lighting;40;;31;b5db59747a6f5584db32cde93c4695e4;9,1290,0,1289,0,1288,0,1074,0,1322,0,1323,0,1280,1,1128,1,1378,1;8;898;FLOAT3;0,0,0;False;975;FLOAT3;0,0,1;False;1081;FLOAT;0;False;1079;FLOAT;0;False;1077;FLOAT;0;False;1075;FLOAT;0;False;1246;FLOAT2;0,0;False;1250;FLOAT2;0,0;False;1;FLOAT3;894
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;42;506.9998,0;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;44;506.9998,-25;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;45;506.9998,-25;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;46;506.9998,-25;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;47;506.9998,-25;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;48;506.9998,-25;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthNormals;0;6;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormals;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;49;506.9998,-25;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;GBuffer;0;7;GBuffer;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalGBuffer;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;50;506.9998,55;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;SceneSelectionPass;0;8;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;51;506.9998,55;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ScenePickingPass;0;9;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;43;512,0;Float;False;True;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;AmplifyShaderPack/Baked GI Standard;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;21;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;True;_Cull;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;3;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;;0;0;Standard;39;Workflow;1;0;Surface;0;0;  Refraction Model;0;0;  Blend;0;0;Two Sided;1;0;Fragment Normal Space,InvertActionOnDeselection;0;0;Forward Only;0;0;Transmission;0;0;  Transmission Shadow;0.5,False,;0;Translucency;0;0;  Translucency Strength;1,False,;0;  Normal Distortion;0.5,False,;0;  Scattering;2,False,;0;  Direct;0.9,False,;0;  Ambient;0.1,False,;0;  Shadow;0.5,False,;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;1;0;_FinalColorxAlpha;0;0;Meta Pass;1;0;Override Baked GI;1;638163211719799797;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Write Depth;0;0;  Early Z;0;0;Vertex Position,InvertActionOnDeselection;1;0;Debug Display;0;0;Clear Coat;0;0;0;10;False;True;True;True;True;True;True;True;True;True;False;;True;0
WireConnection;52;975;33;6
WireConnection;52;765;33;6
WireConnection;34;898;33;1
WireConnection;34;975;33;6
WireConnection;43;0;34;894
WireConnection;43;1;33;6
WireConnection;43;3;33;3
WireConnection;43;4;33;2
WireConnection;43;5;33;4
WireConnection;43;11;52;948
ASEEND*/
//CHKSM=70016D639E0B7DC76DCD297DD1C3B9173F51313A