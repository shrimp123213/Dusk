// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DimensionCut"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_Pos("Pos", Vector) = (0,0,0,0)
		_Angle("Angle", Float) = 45
		_Offset("Offset", Range( -0.5 , 0.5)) = 0.2
		_LightScale("LightScale", Float) = 0
		_LightExp("LightExp", Float) = 0

	}

	SubShader
	{
		LOD 0

		
		
		ZTest Always
		Cull Off
		ZWrite Off

		
		Pass
		{ 
			CGPROGRAM 

			

			#pragma vertex vert_img_custom 
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			

			struct appdata_img_custom
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				
			};

			struct v2f_img_custom
			{
				float4 pos : SV_POSITION;
				half2 uv   : TEXCOORD0;
				half2 stereoUV : TEXCOORD2;
		#if UNITY_UV_STARTS_AT_TOP
				half4 uv2 : TEXCOORD1;
				half4 stereoUV2 : TEXCOORD3;
		#endif
				
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform float2 _Pos;
			uniform float _Angle;
			float4 _MainTex_TexelSize;
			uniform float _Offset;
			uniform float _LightScale;
			uniform float _LightExp;


			v2f_img_custom vert_img_custom ( appdata_img_custom v  )
			{
				v2f_img_custom o;
				
				o.pos = UnityObjectToClipPos( v.vertex );
				o.uv = float4( v.texcoord.xy, 1, 1 );

				#if UNITY_UV_STARTS_AT_TOP
					o.uv2 = float4( v.texcoord.xy, 1, 1 );
					o.stereoUV2 = UnityStereoScreenSpaceUVAdjust ( o.uv2, _MainTex_ST );

					if ( _MainTex_TexelSize.y < 0.0 )
						o.uv.y = 1.0 - o.uv.y;
				#endif
				o.stereoUV = UnityStereoScreenSpaceUVAdjust ( o.uv, _MainTex_ST );
				return o;
			}

			half4 frag ( v2f_img_custom i ) : SV_Target
			{
				#ifdef UNITY_UV_STARTS_AT_TOP
					half2 uv = i.uv2;
					half2 stereoUV = i.stereoUV2;
				#else
					half2 uv = i.uv;
					half2 stereoUV = i.stereoUV;
				#endif	
				
				half4 finalColor;

				// ase common template code
				float2 uv_MainTex = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 break20 = ( uv_MainTex - _Pos );
				float temp_output_7_0 = radians( _Angle );
				float temp_output_12_0 = sin( temp_output_7_0 );
				float temp_output_38_0 = ( _MainTex_TexelSize.x * _MainTex_TexelSize.w * cos( temp_output_7_0 ) );
				float temp_output_23_0 = ( ( break20.x * temp_output_12_0 ) - ( break20.y * temp_output_38_0 ) );
				float2 appendResult27 = (float2(( temp_output_12_0 * -1.0 ) , temp_output_38_0));
				float2 normalizeResult30 = normalize( ( temp_output_23_0 * appendResult27 ) );
				

				finalColor = ( tex2D( _MainTex, frac( ( uv_MainTex + ( normalizeResult30 * _Offset ) ) ) ) + ( _LightScale * _Offset * pow( ( 1.0 / abs( temp_output_23_0 ) ) , _LightExp ) ) );

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.RangedFloatNode;5;-36.09998,599.8999;Inherit;False;Property;_Angle;Angle;1;0;Create;True;0;0;0;False;0;False;45;90;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;32.36969,76.66614;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RadiansOpNode;7;116.9,604.8999;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;39;-475.6984,337.0167;Inherit;False;544.6;248;自动生成的代码会报重定义错误, 请手动删除一个_MainTex_TexelSize的定义;1;10;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CosOpNode;11;272.1707,566.2547;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;15;263.8544,341.197;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;20;408.8544,341.197;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;400.2803,476.0363;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;12;416.9628,604.8624;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;578.8544,404.197;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;578.8544,298.197;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;579.8544,604.197;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;27;723.8544,455.197;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;23;715.6761,338.233;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;964.6002,142.3755;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;31;990.7261,249.0683;Inherit;False;Property;_Offset;Offset;2;0;Create;True;0;0;0;False;0;False;0.2;0;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;30;1113.601,141.3755;Inherit;False;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;1288.863,141.3067;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;44;1433.758,341.2718;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;46;1569.331,317.9003;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;1545.838,421.7236;Inherit;False;Property;_LightExp;LightExp;4;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;1452.042,76.93767;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;42;1714.705,228.3281;Inherit;False;Property;_LightScale;LightScale;3;0;Create;True;0;0;0;False;0;False;0;-0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;40;1576.727,76.39027;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;47;1714.103,356.046;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;1870.961,233.9412;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;2031.102,92.30777;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;2;-399.5302,5.985605;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;50;2168.258,91.71365;Float;False;True;-1;2;ASEMaterialInspector;0;9;DimensionCut;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;True;7;False;;False;True;0;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SamplerNode;1;1711.6,-4.411712;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexelSizeNode;10;-282.6984,399.0167;Inherit;False;-1;1;0;SAMPLER2D;;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;4;98.89999,361.8999;Inherit;False;Property;_Pos;Pos;0;0;Create;True;0;0;0;False;0;False;0,0;0.5506014,0.6262203;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
WireConnection;3;2;2;0
WireConnection;7;0;5;0
WireConnection;11;0;7;0
WireConnection;15;0;3;0
WireConnection;15;1;4;0
WireConnection;20;0;15;0
WireConnection;38;0;10;1
WireConnection;38;1;10;4
WireConnection;38;2;11;0
WireConnection;12;0;7;0
WireConnection;21;0;20;1
WireConnection;21;1;38;0
WireConnection;22;0;20;0
WireConnection;22;1;12;0
WireConnection;26;0;12;0
WireConnection;27;0;26;0
WireConnection;27;1;38;0
WireConnection;23;0;22;0
WireConnection;23;1;21;0
WireConnection;29;0;23;0
WireConnection;29;1;27;0
WireConnection;30;0;29;0
WireConnection;36;0;30;0
WireConnection;36;1;31;0
WireConnection;44;0;23;0
WireConnection;46;1;44;0
WireConnection;37;0;3;0
WireConnection;37;1;36;0
WireConnection;40;0;37;0
WireConnection;47;0;46;0
WireConnection;47;1;48;0
WireConnection;43;0;42;0
WireConnection;43;1;31;0
WireConnection;43;2;47;0
WireConnection;41;0;1;0
WireConnection;41;1;43;0
WireConnection;50;0;41;0
WireConnection;1;0;2;0
WireConnection;1;1;40;0
WireConnection;10;0;2;0
ASEEND*/
//CHKSM=CFF86E5B9A0B51420192F067BD6E5964D7A41DF8