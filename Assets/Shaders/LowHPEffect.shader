// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LowHPEffect"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		_MainTex("MainTex", 2D) = "white" {}
		_TillingOffset("TillingOffset", Vector) = (1,1,0,0)
		_MaskTillingOffset("MaskTillingOffset", Vector) = (1,1,0,0)
		_Color("Color", Color) = (1,1,1,1)
		_Scale("Scale", Float) = 1
		_Alpha("Alpha", Float) = 1
		_Panner("Panner", Vector) = (1,1,0,0)
		_RGBA_MASK("RGBA_MASK", Vector) = (0,0,0,0)
		_Mask("Mask", 2D) = "white" {}
		_MaskScale("MaskScale", Float) = 1
		[Toggle(_KEYWORD0_ON)] _Keyword0("是否乘主貼圖", Float) = 0
		[Enum(OFF,0,ON,1)]_Int0("主貼圖是否極座標UV", Int) = 0
		_SinTimeScale("SinTimeScale", Float) = 1

		[HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent+1000" }

		Cull Off
		HLSLINCLUDE
		#pragma target 3.0
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"
		ENDHLSL

		
		Pass
		{
			Name "Sprite Unlit"
			Tags { "LightMode"="Universal2D" }

			Blend SrcAlpha OneMinusSrcAlpha
			ZTest LEqual
			ZWrite Off
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM

			#define ASE_SRP_VERSION 120112


			#pragma vertex vert
			#pragma fragment frag

			#define _SURFACE_TYPE_TRANSPARENT 1
			#define SHADERPASS SHADERPASS_SPRITEUNLIT

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/SurfaceData2D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging2D.hlsl"

			#pragma shader_feature_local _KEYWORD0_ON


			sampler2D _MainTex;
			sampler2D _Mask;
			CBUFFER_START( UnityPerMaterial )
			float4 _Panner;
			float4 _TillingOffset;
			float4 _Color;
			float4 _RGBA_MASK;
			float4 _MaskTillingOffset;
			int _Int0;
			float _Scale;
			float _SinTimeScale;
			float _Alpha;
			float _MaskScale;
			CBUFFER_END


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 color : COLOR;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 texCoord0 : TEXCOORD0;
				float4 color : TEXCOORD1;
				float3 positionWS : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			#if ETC1_EXTERNAL_ALPHA
				TEXTURE2D( _AlphaTex ); SAMPLER( sampler_AlphaTex );
				float _EnableAlphaTexture;
			#endif

			float4 _RendererColor;

			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3( 0, 0, 0 );
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.normal = v.normal;
				v.tangent.xyz = v.tangent.xyz;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( v.vertex.xyz );

				o.texCoord0 = v.uv0;
				o.color = v.color;
				o.clipPos = vertexInput.positionCS;
				o.positionWS = vertexInput.positionWS;

				return o;
			}

			half4 frag( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float mulTime31 = _TimeParameters.x * _Panner.z;
				float2 appendResult29 = (float2(_Panner.x , _Panner.y));
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult23 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 appendResult49 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 temp_output_50_0 = (appendResult49*2.0 + -1.0);
				float2 break61 = temp_output_50_0;
				float2 appendResult64 = (float2(length( temp_output_50_0 ) , (0.0 + (atan2( break61.y , break61.x ) - 0.0) * (1.0 - 0.0) / (3.141593 - 0.0))));
				float2 lerpResult67 = lerp( appendResult23 , appendResult64 , (float)_Int0);
				float2 appendResult27 = (float2(_TillingOffset.x , _TillingOffset.y));
				float2 appendResult28 = (float2(_TillingOffset.z , _TillingOffset.w));
				float2 panner24 = ( ( mulTime31 + _Panner.w ) * appendResult29 + (lerpResult67*appendResult27 + appendResult28));
				float mulTime71 = _TimeParameters.x * _SinTimeScale;
				float clampResult74 = clamp( (0.5 + (sin( mulTime71 ) - -1.0) * (1.0 - 0.5) / (1.0 - -1.0)) , 0.0 , 1.0 );
				#ifdef _KEYWORD0_ON
				float staticSwitch66 = ( ( _RGBA_MASK.x * _Color.r ) + ( _RGBA_MASK.y * _Color.g ) + ( _RGBA_MASK.z * _Color.b ) + ( _RGBA_MASK.w * _Color.a ) );
				#else
				float staticSwitch66 = 1.0;
				#endif
				float2 appendResult44 = (float2(_MaskTillingOffset.x , _MaskTillingOffset.y));
				float2 appendResult45 = (float2(_MaskTillingOffset.z , _MaskTillingOffset.w));
				float4 appendResult21 = (float4(( tex2D( _MainTex, panner24 ) * _Color * _Scale * clampResult74 ).rgb , ( staticSwitch66 * _Alpha * ( tex2D( _Mask, (appendResult23*appendResult44 + appendResult45) ) * _MaskScale ) ).r));
				
				float4 Color = appendResult21;

				#if ETC1_EXTERNAL_ALPHA
					float4 alpha = SAMPLE_TEXTURE2D( _AlphaTex, sampler_AlphaTex, IN.texCoord0.xy );
					Color.a = lerp( Color.a, alpha.r, _EnableAlphaTexture );
				#endif

				#if defined(DEBUG_DISPLAY)
				SurfaceData2D surfaceData;
				InitializeSurfaceData(Color.rgb, Color.a, surfaceData);
				InputData2D inputData;
				InitializeInputData(IN.positionWS.xy, half2(IN.texCoord0.xy), inputData);
				half4 debugColor = 0;

				SETUP_DEBUG_DATA_2D(inputData, IN.positionWS);

				if (CanDebugOverrideOutputColor(surfaceData, inputData, debugColor))
				{
					return debugColor;
				}
				#endif

				Color *= IN.color * _RendererColor;
				return Color;
			}

			ENDHLSL
		}
		
		Pass
		{
			
			Name "Sprite Unlit Forward"
            Tags { "LightMode"="UniversalForward" }

			Blend SrcAlpha OneMinusSrcAlpha
			ZTest LEqual
			ZWrite Off
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM

			#define ASE_SRP_VERSION 120112


			#pragma vertex vert
			#pragma fragment frag

			#define _SURFACE_TYPE_TRANSPARENT 1
			#define SHADERPASS SHADERPASS_SPRITEFORWARD

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/SurfaceData2D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging2D.hlsl"

			#pragma shader_feature_local _KEYWORD0_ON


			sampler2D _MainTex;
			sampler2D _Mask;
			CBUFFER_START( UnityPerMaterial )
			float4 _Panner;
			float4 _TillingOffset;
			float4 _Color;
			float4 _RGBA_MASK;
			float4 _MaskTillingOffset;
			int _Int0;
			float _Scale;
			float _SinTimeScale;
			float _Alpha;
			float _MaskScale;
			CBUFFER_END


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 color : COLOR;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 texCoord0 : TEXCOORD0;
				float4 color : TEXCOORD1;
				float3 positionWS : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			#if ETC1_EXTERNAL_ALPHA
				TEXTURE2D( _AlphaTex ); SAMPLER( sampler_AlphaTex );
				float _EnableAlphaTexture;
			#endif

			float4 _RendererColor;

			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3( 0, 0, 0 );
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.normal = v.normal;
				v.tangent.xyz = v.tangent.xyz;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( v.vertex.xyz );

				o.texCoord0 = v.uv0;
				o.color = v.color;
				o.clipPos = vertexInput.positionCS;
				o.positionWS = vertexInput.positionWS;

				return o;
			}

			half4 frag( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float mulTime31 = _TimeParameters.x * _Panner.z;
				float2 appendResult29 = (float2(_Panner.x , _Panner.y));
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult23 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 appendResult49 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 temp_output_50_0 = (appendResult49*2.0 + -1.0);
				float2 break61 = temp_output_50_0;
				float2 appendResult64 = (float2(length( temp_output_50_0 ) , (0.0 + (atan2( break61.y , break61.x ) - 0.0) * (1.0 - 0.0) / (3.141593 - 0.0))));
				float2 lerpResult67 = lerp( appendResult23 , appendResult64 , (float)_Int0);
				float2 appendResult27 = (float2(_TillingOffset.x , _TillingOffset.y));
				float2 appendResult28 = (float2(_TillingOffset.z , _TillingOffset.w));
				float2 panner24 = ( ( mulTime31 + _Panner.w ) * appendResult29 + (lerpResult67*appendResult27 + appendResult28));
				float mulTime71 = _TimeParameters.x * _SinTimeScale;
				float clampResult74 = clamp( (0.5 + (sin( mulTime71 ) - -1.0) * (1.0 - 0.5) / (1.0 - -1.0)) , 0.0 , 1.0 );
				#ifdef _KEYWORD0_ON
				float staticSwitch66 = ( ( _RGBA_MASK.x * _Color.r ) + ( _RGBA_MASK.y * _Color.g ) + ( _RGBA_MASK.z * _Color.b ) + ( _RGBA_MASK.w * _Color.a ) );
				#else
				float staticSwitch66 = 1.0;
				#endif
				float2 appendResult44 = (float2(_MaskTillingOffset.x , _MaskTillingOffset.y));
				float2 appendResult45 = (float2(_MaskTillingOffset.z , _MaskTillingOffset.w));
				float4 appendResult21 = (float4(( tex2D( _MainTex, panner24 ) * _Color * _Scale * clampResult74 ).rgb , ( staticSwitch66 * _Alpha * ( tex2D( _Mask, (appendResult23*appendResult44 + appendResult45) ) * _MaskScale ) ).r));
				
				float4 Color = appendResult21;

				#if ETC1_EXTERNAL_ALPHA
					float4 alpha = SAMPLE_TEXTURE2D( _AlphaTex, sampler_AlphaTex, IN.texCoord0.xy );
					Color.a = lerp( Color.a, alpha.r, _EnableAlphaTexture );
				#endif


				#if defined(DEBUG_DISPLAY)
				SurfaceData2D surfaceData;
				InitializeSurfaceData(Color.rgb, Color.a, surfaceData);
				InputData2D inputData;
				InitializeInputData(IN.positionWS.xy, half2(IN.texCoord0.xy), inputData);
				half4 debugColor = 0;

				SETUP_DEBUG_DATA_2D(inputData, IN.positionWS);

				if (CanDebugOverrideOutputColor(surfaceData, inputData, debugColor))
				{
					return debugColor;
				}
				#endif

				Color *= IN.color * _RendererColor;
				return Color;
			}

			ENDHLSL
		}
		
        Pass
        {
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }

            Cull Off

            HLSLPROGRAM

			#define ASE_SRP_VERSION 120112


			#pragma vertex vert
			#pragma fragment frag

            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX
            #define SHADERPASS SHADERPASS_DEPTHONLY
			#define SCENESELECTIONPASS 1


            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#pragma shader_feature_local _KEYWORD0_ON


			sampler2D _MainTex;
			sampler2D _Mask;
			CBUFFER_START( UnityPerMaterial )
			float4 _Panner;
			float4 _TillingOffset;
			float4 _Color;
			float4 _RGBA_MASK;
			float4 _MaskTillingOffset;
			int _Int0;
			float _Scale;
			float _SinTimeScale;
			float _Alpha;
			float _MaskScale;
			CBUFFER_END


            struct VertexInput
			{
				float3 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};


            int _ObjectId;
            int _PassValue;

			
			VertexOutput vert(VertexInput v )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord = screenPos;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
				float3 positionWS = TransformObjectToWorld(v.vertex);
				o.clipPos = TransformWorldToHClip(positionWS);

				return o;
			}

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				float mulTime31 = _TimeParameters.x * _Panner.z;
				float2 appendResult29 = (float2(_Panner.x , _Panner.y));
				float4 screenPos = IN.ase_texcoord;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult23 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 appendResult49 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 temp_output_50_0 = (appendResult49*2.0 + -1.0);
				float2 break61 = temp_output_50_0;
				float2 appendResult64 = (float2(length( temp_output_50_0 ) , (0.0 + (atan2( break61.y , break61.x ) - 0.0) * (1.0 - 0.0) / (3.141593 - 0.0))));
				float2 lerpResult67 = lerp( appendResult23 , appendResult64 , (float)_Int0);
				float2 appendResult27 = (float2(_TillingOffset.x , _TillingOffset.y));
				float2 appendResult28 = (float2(_TillingOffset.z , _TillingOffset.w));
				float2 panner24 = ( ( mulTime31 + _Panner.w ) * appendResult29 + (lerpResult67*appendResult27 + appendResult28));
				float mulTime71 = _TimeParameters.x * _SinTimeScale;
				float clampResult74 = clamp( (0.5 + (sin( mulTime71 ) - -1.0) * (1.0 - 0.5) / (1.0 - -1.0)) , 0.0 , 1.0 );
				#ifdef _KEYWORD0_ON
				float staticSwitch66 = ( ( _RGBA_MASK.x * _Color.r ) + ( _RGBA_MASK.y * _Color.g ) + ( _RGBA_MASK.z * _Color.b ) + ( _RGBA_MASK.w * _Color.a ) );
				#else
				float staticSwitch66 = 1.0;
				#endif
				float2 appendResult44 = (float2(_MaskTillingOffset.x , _MaskTillingOffset.y));
				float2 appendResult45 = (float2(_MaskTillingOffset.z , _MaskTillingOffset.w));
				float4 appendResult21 = (float4(( tex2D( _MainTex, panner24 ) * _Color * _Scale * clampResult74 ).rgb , ( staticSwitch66 * _Alpha * ( tex2D( _Mask, (appendResult23*appendResult44 + appendResult45) ) * _MaskScale ) ).r));
				
				float4 Color = appendResult21;

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				return outColor;
			}

            ENDHLSL
        }

		
        Pass
        {
			
            Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }

            Cull Off

            HLSLPROGRAM

			#define ASE_SRP_VERSION 120112


			#pragma vertex vert
			#pragma fragment frag

            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX
            #define SHADERPASS SHADERPASS_DEPTHONLY
			#define SCENEPICKINGPASS 1


            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        	#pragma shader_feature_local _KEYWORD0_ON


			sampler2D _MainTex;
			sampler2D _Mask;
			CBUFFER_START( UnityPerMaterial )
			float4 _Panner;
			float4 _TillingOffset;
			float4 _Color;
			float4 _RGBA_MASK;
			float4 _MaskTillingOffset;
			int _Int0;
			float _Scale;
			float _SinTimeScale;
			float _Alpha;
			float _MaskScale;
			CBUFFER_END


            struct VertexInput
			{
				float3 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

            float4 _SelectionID;

			
			VertexOutput vert(VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord = screenPos;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
				float3 positionWS = TransformObjectToWorld(v.vertex);
				o.clipPos = TransformWorldToHClip(positionWS);

				return o;
			}

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				float mulTime31 = _TimeParameters.x * _Panner.z;
				float2 appendResult29 = (float2(_Panner.x , _Panner.y));
				float4 screenPos = IN.ase_texcoord;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult23 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 appendResult49 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 temp_output_50_0 = (appendResult49*2.0 + -1.0);
				float2 break61 = temp_output_50_0;
				float2 appendResult64 = (float2(length( temp_output_50_0 ) , (0.0 + (atan2( break61.y , break61.x ) - 0.0) * (1.0 - 0.0) / (3.141593 - 0.0))));
				float2 lerpResult67 = lerp( appendResult23 , appendResult64 , (float)_Int0);
				float2 appendResult27 = (float2(_TillingOffset.x , _TillingOffset.y));
				float2 appendResult28 = (float2(_TillingOffset.z , _TillingOffset.w));
				float2 panner24 = ( ( mulTime31 + _Panner.w ) * appendResult29 + (lerpResult67*appendResult27 + appendResult28));
				float mulTime71 = _TimeParameters.x * _SinTimeScale;
				float clampResult74 = clamp( (0.5 + (sin( mulTime71 ) - -1.0) * (1.0 - 0.5) / (1.0 - -1.0)) , 0.0 , 1.0 );
				#ifdef _KEYWORD0_ON
				float staticSwitch66 = ( ( _RGBA_MASK.x * _Color.r ) + ( _RGBA_MASK.y * _Color.g ) + ( _RGBA_MASK.z * _Color.b ) + ( _RGBA_MASK.w * _Color.a ) );
				#else
				float staticSwitch66 = 1.0;
				#endif
				float2 appendResult44 = (float2(_MaskTillingOffset.x , _MaskTillingOffset.y));
				float2 appendResult45 = (float2(_MaskTillingOffset.z , _MaskTillingOffset.w));
				float4 appendResult21 = (float4(( tex2D( _MainTex, panner24 ) * _Color * _Scale * clampResult74 ).rgb , ( staticSwitch66 * _Alpha * ( tex2D( _Mask, (appendResult23*appendResult44 + appendResult45) ) * _MaskScale ) ).r));
				
				float4 Color = appendResult21;
				half4 outColor = _SelectionID;
				return outColor;
			}

            ENDHLSL
        }
		
	}
	CustomEditor "ASEMaterialInspector"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;11;0,0;Float;False;False;-1;2;ASEMaterialInspector;0;15;New Amplify Shader;cf964e524c8e69742b1d21fbe2ebcc4a;True;Sprite Unlit Forward;0;1;Sprite Unlit Forward;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;12;all;0;False;True;2;5;False;;10;False;;0;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;12;0,0;Float;False;False;-1;2;ASEMaterialInspector;0;15;New Amplify Shader;cf964e524c8e69742b1d21fbe2ebcc4a;True;SceneSelectionPass;0;2;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;13;0,0;Float;False;False;-1;2;ASEMaterialInspector;0;15;New Amplify Shader;cf964e524c8e69742b1d21fbe2ebcc4a;True;ScenePickingPass;0;3;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-629.8547,377.9609;Inherit;False;Property;_Scale;Scale;4;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;17;-648,152;Inherit;False;Property;_Color;Color;3;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;16;-671,-73;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-278.273,46.85597;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;29;-1082.894,144.8611;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;30;-1336.894,284.8611;Inherit;False;Property;_Panner;Panner;6;0;Create;True;0;0;0;False;0;False;1,1,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;31;-1123.894,287.8611;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;24;-853.8937,15.86111;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-944.8936,298.8611;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;38;-633.2576,456.5057;Inherit;False;Property;_RGBA_MASK;RGBA_MASK;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-316.4665,208.1747;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-317.4491,306.7866;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-318.1149,407.6182;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-318.1782,506.358;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;-138.1893,319.3962;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-145.8433,482.8974;Inherit;False;Property;_Alpha;Alpha;5;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;25;-1090.894,2.861115;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;27;-1277.894,76.86111;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;28;-1271.894,188.8611;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;26;-1471.894,107.8611;Inherit;False;Property;_TillingOffset;TillingOffset;1;0;Create;True;0;0;0;False;0;False;1,1,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;42;-635.4487,650.0643;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;44;-822.4481,724.0643;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;45;-816.4482,836.0643;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;46;-1016.447,755.0643;Inherit;False;Property;_MaskTillingOffset;MaskTillingOffset;2;0;Create;True;0;0;0;False;0;False;1,1,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;41;-419.8687,617.9549;Inherit;True;Property;_Mask;Mask;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;47;-282.6179,816.8558;Inherit;False;Property;_MaskScale;MaskScale;9;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-107.403,632.8984;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;10;590.5639,60.29976;Float;False;True;-1;2;ASEMaterialInspector;0;15;LowHPEffect;cf964e524c8e69742b1d21fbe2ebcc4a;True;Sprite Unlit;0;0;Sprite Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=1000;True;2;True;12;all;0;True;True;2;5;False;;10;False;;0;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;3;Vertex Position;1;0;Debug Display;0;0;External Alpha;0;0;0;4;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.DynamicAppendNode;21;388.7522,61.69194;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;61;-2364.64,243.3156;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ATan2OpNode;62;-2253.64,250.3156;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;22;-2609.972,-21.41732;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;49;-2434.674,98.01704;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;50;-2246.673,122.017;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LengthOpNode;51;-1998.535,122.6092;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;23;-1731.151,9.705462;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;64;-1785.709,113.8334;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;63;-2034.989,193.8158;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;3.141593;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-90.78892,213.6641;Inherit;False;Constant;_Float0;Float 0;10;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;247.3729,352.1859;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;66;69.11111,214.9641;Inherit;False;Property;_Keyword0;是否乘主貼圖;10;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;67;-1418.084,-69.73558;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.IntNode;69;-1793.781,-97.03555;Inherit;False;Property;_Int0;主貼圖是否極座標UV;11;1;[Enum];Create;False;0;2;OFF;0;ON;1;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-1534.315,503.1319;Inherit;False;Property;_SinTimeScale;SinTimeScale;12;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;71;-1356.744,497.9366;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;72;-1175.744,495.9366;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;74;-824.4462,410.1366;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;73;-1035.626,441.69;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0.5;False;4;FLOAT;1;False;1;FLOAT;0
WireConnection;16;1;24;0
WireConnection;20;0;16;0
WireConnection;20;1;17;0
WireConnection;20;2;18;0
WireConnection;20;3;74;0
WireConnection;29;0;30;1
WireConnection;29;1;30;2
WireConnection;31;0;30;3
WireConnection;24;0;25;0
WireConnection;24;2;29;0
WireConnection;24;1;32;0
WireConnection;32;0;31;0
WireConnection;32;1;30;4
WireConnection;34;0;38;1
WireConnection;34;1;17;1
WireConnection;35;0;38;2
WireConnection;35;1;17;2
WireConnection;37;0;38;3
WireConnection;37;1;17;3
WireConnection;36;0;38;4
WireConnection;36;1;17;4
WireConnection;39;0;34;0
WireConnection;39;1;35;0
WireConnection;39;2;37;0
WireConnection;39;3;36;0
WireConnection;25;0;67;0
WireConnection;25;1;27;0
WireConnection;25;2;28;0
WireConnection;27;0;26;1
WireConnection;27;1;26;2
WireConnection;28;0;26;3
WireConnection;28;1;26;4
WireConnection;42;0;23;0
WireConnection;42;1;44;0
WireConnection;42;2;45;0
WireConnection;44;0;46;1
WireConnection;44;1;46;2
WireConnection;45;0;46;3
WireConnection;45;1;46;4
WireConnection;41;1;42;0
WireConnection;48;0;41;0
WireConnection;48;1;47;0
WireConnection;10;1;21;0
WireConnection;21;0;20;0
WireConnection;21;3;40;0
WireConnection;61;0;50;0
WireConnection;62;0;61;1
WireConnection;62;1;61;0
WireConnection;49;0;22;1
WireConnection;49;1;22;2
WireConnection;50;0;49;0
WireConnection;51;0;50;0
WireConnection;23;0;22;1
WireConnection;23;1;22;2
WireConnection;64;0;51;0
WireConnection;64;1;63;0
WireConnection;63;0;62;0
WireConnection;40;0;66;0
WireConnection;40;1;19;0
WireConnection;40;2;48;0
WireConnection;66;1;65;0
WireConnection;66;0;39;0
WireConnection;67;0;23;0
WireConnection;67;1;64;0
WireConnection;67;2;69;0
WireConnection;71;0;70;0
WireConnection;72;0;71;0
WireConnection;74;0;73;0
WireConnection;73;0;72;0
ASEEND*/
//CHKSM=A8299026D80A0D804F44EAE98C1674F317C1EE1D