// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "UI_HDR"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0

        _AddTexture("AddTexture", 2D) = "white" {}
        _AddSpeed("AddSpeed", Vector) = (0,0,0,0)
        _NoiseIntersity("NoiseIntersity", Float) = 0.3
        _NoiseTexture("NoiseTexture", 2D) = "white" {}
        _NoiseSpeed("NoiseSpeed", Vector) = (0,0,0,0)
        [HDR]_AddColor("AddColor", Color) = (1,1,1,1)
        [HideInInspector] _texcoord( "", 2D ) = "white" {}

    }

    SubShader
    {
		LOD 0

        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }

        Stencil
        {
        	Ref [_Stencil]
        	ReadMask [_StencilReadMask]
        	WriteMask [_StencilWriteMask]
        	Comp [_StencilComp]
        	Pass [_StencilOp]
        }


        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend One OneMinusSrcAlpha
        ColorMask [_ColorMask]

        
        Pass
        {
            Name "Default"
        CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            #include "UnityShaderVariables.cginc"
            #define ASE_NEEDS_FRAG_COLOR


            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                float4  mask : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
                
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            float _UIMaskSoftnessX;
            float _UIMaskSoftnessY;

            uniform sampler2D _AddTexture;
            uniform float2 _AddSpeed;
            uniform float4 _AddTexture_ST;
            uniform sampler2D _NoiseTexture;
            uniform float2 _NoiseSpeed;
            uniform float4 _NoiseTexture_ST;
            uniform float _NoiseIntersity;
            uniform float4 _AddColor;

            
            v2f vert(appdata_t v )
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                

                v.vertex.xyz +=  float3( 0, 0, 0 ) ;

                float4 vPosition = UnityObjectToClipPos(v.vertex);
                OUT.worldPosition = v.vertex;
                OUT.vertex = vPosition;

                float2 pixelSize = vPosition.w;
                pixelSize /= float2(1, 1) * abs(mul((float2x2)UNITY_MATRIX_P, _ScreenParams.xy));

                float4 clampedRect = clamp(_ClipRect, -2e10, 2e10);
                float2 maskUV = (v.vertex.xy - clampedRect.xy) / (clampedRect.zw - clampedRect.xy);
                OUT.texcoord = v.texcoord;
                OUT.mask = float4(v.vertex.xy * 2 - clampedRect.xy - clampedRect.zw, 0.25 / (0.25 * half2(_UIMaskSoftnessX, _UIMaskSoftnessY) + abs(pixelSize.xy)));

                OUT.color = v.color * _Color;
                return OUT;
            }

            fixed4 frag(v2f IN ) : SV_Target
            {
                //Round up the alpha color coming from the interpolator (to 1.0/256.0 steps)
                //The incoming alpha could have numerical instability, which makes it very sensible to
                //HDR color transparency blend, when it blends with the world's texture.
                const half alphaPrecision = half(0xff);
                const half invAlphaPrecision = half(1.0/alphaPrecision);
                IN.color.a = round(IN.color.a * alphaPrecision)*invAlphaPrecision;

                float2 uv_MainTex = IN.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                float4 tex2DNode10 = tex2D( _MainTex, uv_MainTex );
                float2 uv2_AddTexture = IN.worldPosition.xyzw.xy * _AddTexture_ST.xy + _AddTexture_ST.zw;
                float2 panner15 = ( 1.0 * _Time.y * _AddSpeed + uv2_AddTexture);
                float2 uv_NoiseTexture = IN.texcoord.xy * _NoiseTexture_ST.xy + _NoiseTexture_ST.zw;
                float2 panner21 = ( 1.0 * _Time.y * _NoiseSpeed + uv_NoiseTexture);
                float4 tex2DNode19 = tex2D( _NoiseTexture, panner21 );
                float4 lerpResult17 = lerp( float4( panner15, 0.0 , 0.0 ) , tex2DNode19 , _NoiseIntersity);
                

                half4 color = ( ( tex2DNode10 + ( tex2DNode10.a * tex2D( _AddTexture, lerpResult17.rg ) * _AddColor ) ) * IN.color );

                #ifdef UNITY_UI_CLIP_RECT
                half2 m = saturate((_ClipRect.zw - _ClipRect.xy - abs(IN.mask.xy)) * IN.mask.zw);
                color.a *= m.x * m.y;
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                color.rgb *= color.a;

                return color;
            }
        ENDCG
        }
    }
    CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.CommentaryNode;120;-3954.226,1944.321;Inherit;False;2427.56;1088.688;Comment;28;104;103;102;101;100;99;98;97;96;95;94;93;119;118;117;116;115;114;113;112;111;110;109;108;107;106;105;129;球化;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;36;-3405.066,-1346.884;Inherit;False;2848.921;1762.922;Comment;28;174;173;172;171;22;9;10;14;24;26;11;23;12;25;18;17;19;15;20;21;16;175;177;179;180;181;182;184;流光;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-139.8467,892.6107;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;89;-1211.864,497.4386;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;90;-1004.765,496.3526;Inherit;True;Property;_TextureSample1;Texture Sample 1;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;91;-583.152,644.6762;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-1180.653,726.1718;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;72;-1504.004,586.4166;Inherit;False;Property;_Color0;Color 0;14;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;69;-1947.938,797.4904;Inherit;True;Property;_Texture1;Texture1;12;0;Create;True;0;0;0;False;0;False;-1;ef8db69d40e76ee4fa2e2fd0cbfb0406;ef8db69d40e76ee4fa2e2fd0cbfb0406;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;56;-3459.451,1454.755;Inherit;False;Constant;_Float1;Float 0;7;0;Create;True;0;0;0;False;0;False;1.15;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-2950.248,1385.609;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;59;-3177.248,1460.608;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;64;-2235.146,1229.792;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;61;-2514.393,1229.272;Inherit;True;Radial Shear;-1;;6;c6dc9fc7fa9b08c4d95138f2ae88b526;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-3456.589,1355.977;Inherit;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;0;False;0;False;0.62;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;65;-1978.278,1206.734;Inherit;True;Property;_Texture2;Texture2;10;0;Create;True;0;0;0;False;0;False;-1;ef8db69d40e76ee4fa2e2fd0cbfb0406;ef8db69d40e76ee4fa2e2fd0cbfb0406;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;58;-3185.71,1351.31;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;63;-2760.304,1259.521;Inherit;False;Constant;_Vector4;Vector 4;7;0;Create;True;0;0;0;False;0;False;3,3;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;52;-3484.432,1143.369;Inherit;False;2;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;54;-3253.677,1140.57;Inherit;True;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;3;FLOAT2;-1,-1;False;4;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;53;-2980.921,1165.067;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;66;-1616.388,1038.33;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;70;-1382.543,1040.151;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;74;-1143.358,965.1183;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-408.6558,970.6327;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;87;-717.0068,908.1027;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-720.0353,1096.708;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-991.712,1107.072;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;77;-986.8574,1330.944;Inherit;False;Ellipse;-1;;7;3ba94b7b3cfd5f447befde8107c04d52;0;3;2;FLOAT2;0,0;False;7;FLOAT;1;False;9;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;105;-3463.272,2332.492;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;106;-3606.589,2004.897;Inherit;True;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;3;FLOAT2;-1,-1;False;4;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;107;-3868.998,2004.311;Inherit;False;2;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;108;-2329.709,2207.533;Inherit;True;Property;_Texture4;Texture1;13;0;Create;True;0;0;0;False;0;False;-1;ef8db69d40e76ee4fa2e2fd0cbfb0406;ef8db69d40e76ee4fa2e2fd0cbfb0406;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;109;-3231.091,2228.717;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;110;-3716.464,2267.489;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleTimeNode;111;-3481.783,2438.44;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;112;-3926.071,2266.284;Inherit;False;Property;_SpeedTilling1;SpeedTilling;9;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;113;-3311.97,2005.345;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;114;-2857.927,2199.322;Inherit;True;Radial Shear;-1;;9;c6dc9fc7fa9b08c4d95138f2ae88b526;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;115;-2570.937,2193.986;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;-3260.083,2328.941;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;117;-3063.81,2390.453;Inherit;False;Constant;_Vector6;Vector 3;7;0;Create;True;0;0;0;False;0;False;3,3;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;118;-1938.83,2530.53;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;119;-1704.985,2532.351;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-3828.475,2869.951;Inherit;False;Constant;_Float2;Float 0;7;0;Create;True;0;0;0;False;0;False;1.15;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-3319.272,2800.804;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;95;-3546.272,2875.803;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;96;-2604.171,2644.987;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;97;-2883.418,2644.467;Inherit;True;Radial Shear;-1;;10;c6dc9fc7fa9b08c4d95138f2ae88b526;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-3825.615,2771.172;Inherit;False;Constant;_Float3;Float 0;7;0;Create;True;0;0;0;False;0;False;0.62;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;99;-2347.305,2621.929;Inherit;True;Property;_Texture3;Texture2;11;0;Create;True;0;0;0;False;0;False;-1;ef8db69d40e76ee4fa2e2fd0cbfb0406;ef8db69d40e76ee4fa2e2fd0cbfb0406;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;100;-3554.734,2766.505;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;101;-3129.328,2674.717;Inherit;False;Constant;_Vector5;Vector 4;7;0;Create;True;0;0;0;False;0;False;3,3;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;102;-3853.457,2558.564;Inherit;False;2;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;103;-3622.701,2555.765;Inherit;True;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;3;FLOAT2;-1,-1;False;4;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;104;-3349.945,2580.262;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;-180.7858,2246.417;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;122;-1187.733,2397.242;Inherit;True;Property;_AddTexture1;AddTexture;1;0;Create;True;0;0;0;False;0;False;-1;36be8d528a4fa024faa4680d7658642c;36be8d528a4fa024faa4680d7658642c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;125;-421.0157,2372.145;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;126;-1120.38,2643.808;Inherit;False;Property;_AddColor1;AddColor;7;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;127;-1186.026,2141.174;Inherit;True;Property;_TextureSample2;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;128;-1374.6,2140.673;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;130;-1506.827,2526.986;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0.3,0.3;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;129;-1758.834,2355.459;Inherit;False;3;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-691.4254,2415.636;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;124;-455.3008,2145.442;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;132;-3706.702,3775.643;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;131;-3732.476,3886.983;Inherit;True;Property;_FaceTexture;FaceTexture;15;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;133;-3426.677,3885.918;Inherit;True;Property;_ReflectionTex;ReflectionTex;16;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;134;-3700.043,4115.035;Inherit;False;Property;_FaceColor;FaceColor;17;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;137;-3397.139,4159.233;Inherit;False;Property;_Progress;Progress;18;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;138;-3095.538,4161.835;Inherit;False;Property;_AngleTangent;AngleTangent;19;0;Create;True;0;0;0;False;0;False;0.66;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;139;-3398.438,4312.635;Inherit;False;Property;_NoiseSpeedScale;NoiseSpeed(XY)Scale(ZW);20;0;Create;False;0;0;0;False;0;False;-0.02,0.2,0.5,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;141;-3061.74,4308.734;Inherit;False;Property;_Gradient;Gradient;21;0;Create;True;0;0;0;False;0;False;2,0.36,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;142;-3688.339,4532.339;Inherit;False;Property;_WaterColor;WaterColor;22;1;[HDR];Create;True;0;0;0;False;0;False;1,1,0.1764706,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;145;-3182.635,4676.64;Inherit;False;Property;_WaveTransparency;WaveTransparency;25;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-3372.436,4589.54;Inherit;False;Property;_WaveStrength;WaveStrength;23;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;146;-3371.136,4672.74;Inherit;False;Property;_WaveAngle;WaveAngle;26;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-2931.736,4657.14;Inherit;False;Property;_PixelSnap;PixelSnap;27;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;149;-3008.436,4788.442;Inherit;False;Constant;_StencilID;Stencil ID;28;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-3242.435,4874.24;Inherit;False;Constant;_StencilOperation;Stencil Operation;28;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;148;-3254.138,4791.039;Inherit;False;Constant;_StencilComparison;Stencil Comparison;28;0;Create;True;0;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;151;-3005.836,4875.54;Inherit;False;Constant;_MaskStencilWrite;Mask Stencil Write;28;0;Create;True;0;0;0;False;0;False;255;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;155;-2977.733,3766.615;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;162;-2878.295,3919.675;Inherit;False;Constant;_Float4;Float 4;28;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;164;-2626.08,3783.501;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;163;-2626.081,3893.623;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;152;-2816.472,4336.532;Inherit;False;Constant;_MaskStencilRead;Mask Stencil Read;28;0;Create;True;0;0;0;False;0;False;255;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-2860.174,3656.306;Inherit;False;Property;_WaveFrequency;WaveFrequency;24;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;166;-2836.955,3577.675;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;167;-2629.796,3627.799;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;168;-2382.395,3758.445;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;161;-2174.438,3763.156;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;16;-2926.178,-191.4039;Inherit;False;Property;_AddSpeed;AddSpeed;2;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;15;-2668.616,-287.8801;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;19;-2661.397,-64.6992;Inherit;True;Property;_NoiseTexture;NoiseTexture;4;0;Create;True;0;0;0;False;0;False;-1;ef8db69d40e76ee4fa2e2fd0cbfb0406;ef8db69d40e76ee4fa2e2fd0cbfb0406;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;18;-2342.059,15.79363;Inherit;False;Property;_NoiseIntersity;NoiseIntersity;3;0;Create;True;0;0;0;False;0;False;0.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-760.8679,-299.029;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;12;-1767.814,-148.2038;Inherit;True;Property;_AddTexture;AddTexture;0;0;Create;True;0;0;0;False;0;False;-1;36be8d528a4fa024faa4680d7658642c;36be8d528a4fa024faa4680d7658642c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1241.607,-123.3093;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;26;-1001.098,-173.3008;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;24;-1700.461,98.36189;Inherit;False;Property;_AddColor;AddColor;6;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;22;-3294.475,216.5306;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;5;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.AbsOpNode;173;-2496.241,-384.2333;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;174;-2388.908,-382.8218;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;177;-3085.9,-512.6714;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;171;-2769.241,-404.2342;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-336.4783,-312.1289;Float;False;True;-1;2;ASEMaterialInspector;0;3;UI_HDR;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;3;1;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;True;True;True;True;True;0;True;_ColorMask;False;False;False;False;False;False;False;True;True;0;True;_Stencil;255;True;_StencilReadMask;255;True;_StencilWriteMask;0;True;_StencilComp;0;True;_StencilOp;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;0;True;unity_GUIZTestMode;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.FresnelNode;180;-1774.866,-823.0666;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;-1452.388,-694.0753;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-1000.283,-301.2027;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;179;-2005.974,-797.5367;Inherit;False;Property;_Fresnel;Fresnel;28;0;Create;True;0;0;0;False;0;False;0,1,5;0,1,5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;181;-1786.959,-616.1436;Inherit;False;Property;_FresnelColor;FresnelColor;29;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;17;-2117.698,-88.82666;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;21;-3012.016,107.141;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;49;-3081.503,922.4493;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;38;-3224.819,594.856;Inherit;True;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;3;FLOAT2;-1,-1;False;4;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;37;-3487.228,594.2697;Inherit;False;2;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;50;-2849.321,818.6752;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;43;-3334.694,857.446;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleTimeNode;46;-3100.014,1028.397;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;42;-3544.301,856.2413;Inherit;False;Property;_SpeedTilling;SpeedTilling;8;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;39;-2930.201,595.3038;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;41;-2476.158,789.2794;Inherit;True;Radial Shear;-1;;5;c6dc9fc7fa9b08c4d95138f2ae88b526;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;48;-2189.167,783.9438;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-2878.314,918.8984;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;51;-2682.041,980.4102;Inherit;False;Constant;_Vector3;Vector 3;7;0;Create;True;0;0;0;False;0;False;3,3;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;184;-2340.201,184.7896;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;172;-2633.241,-402.2341;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.9;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;175;-2245.418,-380.5211;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;10;-1767.984,-404.2722;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;14;-2989.697,-330.9148;Inherit;False;1;12;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;20;-3329.677,-14.10136;Inherit;False;0;19;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;9;-1975.681,-410.4682;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;92;0;91;0
WireConnection;92;1;88;0
WireConnection;90;0;89;0
WireConnection;91;0;90;0
WireConnection;91;1;73;0
WireConnection;73;0;72;0
WireConnection;73;1;69;0
WireConnection;69;1;48;0
WireConnection;60;0;58;0
WireConnection;60;1;59;0
WireConnection;64;0;61;0
WireConnection;61;1;53;0
WireConnection;61;3;63;0
WireConnection;61;4;60;0
WireConnection;65;1;64;0
WireConnection;58;0;55;0
WireConnection;58;1;56;0
WireConnection;54;0;52;0
WireConnection;53;0;54;0
WireConnection;66;0;69;1
WireConnection;66;1;65;1
WireConnection;70;0;66;0
WireConnection;74;0;72;0
WireConnection;88;0;87;0
WireConnection;88;1;76;0
WireConnection;76;0;75;0
WireConnection;76;1;77;0
WireConnection;75;0;74;3
WireConnection;75;1;70;0
WireConnection;105;0;110;0
WireConnection;105;1;110;1
WireConnection;106;0;107;0
WireConnection;108;1;115;0
WireConnection;109;0;110;2
WireConnection;109;1;110;3
WireConnection;110;0;112;0
WireConnection;113;0;106;0
WireConnection;114;1;113;0
WireConnection;114;3;117;0
WireConnection;114;4;116;0
WireConnection;115;0;114;0
WireConnection;115;1;109;0
WireConnection;116;0;105;0
WireConnection;116;1;111;0
WireConnection;118;0;108;1
WireConnection;118;1;99;1
WireConnection;119;0;118;0
WireConnection;94;0;100;0
WireConnection;94;1;95;0
WireConnection;96;0;97;0
WireConnection;97;1;104;0
WireConnection;97;3;101;0
WireConnection;97;4;94;0
WireConnection;99;1;96;0
WireConnection;100;0;98;0
WireConnection;100;1;93;0
WireConnection;103;0;102;0
WireConnection;104;0;103;0
WireConnection;121;0;124;0
WireConnection;121;1;125;0
WireConnection;127;0;128;0
WireConnection;130;0;129;0
WireConnection;130;1;119;0
WireConnection;123;0;127;4
WireConnection;123;1;130;0
WireConnection;123;2;126;0
WireConnection;124;0;127;0
WireConnection;124;1;123;0
WireConnection;155;2;132;0
WireConnection;164;0;155;1
WireConnection;164;1;162;0
WireConnection;163;0;155;2
WireConnection;163;1;162;0
WireConnection;167;0;166;0
WireConnection;167;1;144;0
WireConnection;168;0;167;0
WireConnection;168;1;164;0
WireConnection;168;2;163;0
WireConnection;161;0;168;0
WireConnection;15;0;14;0
WireConnection;15;2;16;0
WireConnection;19;1;21;0
WireConnection;25;0;11;0
WireConnection;25;1;26;0
WireConnection;12;1;17;0
WireConnection;23;0;10;4
WireConnection;23;1;12;0
WireConnection;23;2;24;0
WireConnection;173;0;172;0
WireConnection;174;0;173;0
WireConnection;171;0;177;0
WireConnection;0;0;25;0
WireConnection;180;1;179;1
WireConnection;180;2;179;2
WireConnection;180;3;179;3
WireConnection;182;0;180;0
WireConnection;182;1;181;0
WireConnection;11;0;10;0
WireConnection;11;1;23;0
WireConnection;17;0;15;0
WireConnection;17;1;19;0
WireConnection;17;2;18;0
WireConnection;21;0;20;0
WireConnection;21;2;22;0
WireConnection;49;0;43;0
WireConnection;49;1;43;1
WireConnection;38;0;37;0
WireConnection;50;0;43;2
WireConnection;50;1;43;3
WireConnection;43;0;42;0
WireConnection;39;0;38;0
WireConnection;41;1;39;0
WireConnection;41;3;51;0
WireConnection;41;4;47;0
WireConnection;48;0;41;0
WireConnection;48;1;50;0
WireConnection;47;0;49;0
WireConnection;47;1;46;0
WireConnection;184;0;175;0
WireConnection;184;1;19;0
WireConnection;172;0;171;1
WireConnection;175;0;174;0
WireConnection;10;0;9;0
ASEEND*/
//CHKSM=178F64A085B1C6BC1F2C6D6A6B09ED4D2669ED6A