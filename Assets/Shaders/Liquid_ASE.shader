// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Liquid_ASE"
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

        _WaveStrength("WaveStrength", Float) = 100
        _WaveFrequency("WaveFrequency", Float) = 10
        _WaveHeight("WaveHeight", Range( 0 , 1)) = 1

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

            uniform float _WaveFrequency;
            uniform float _WaveStrength;
            uniform float _WaveHeight;

            
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

                float2 texCoord202 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
                float WaveFrequency146 = _WaveFrequency;
                float2 texCoord203 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
                float2 texCoord204 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
                float mulTime133 = _Time.y * 0.6;
                float2 texCoord205 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
                float mulTime144 = _Time.y * 0.3;
                float Wave91 = ( sin( ( ( texCoord202.x * 10.0 ) + ( 10.0 * texCoord202.y ) + ( _Time.y * WaveFrequency146 ) ) ) + ( sin( ( ( ( 1.0 - texCoord203.x ) * 20.0 ) + ( 20.0 * ( 1.0 - texCoord203.y ) ) + ( _Time.y * WaveFrequency146 ) ) ) * 0.5 ) + ( sin( ( ( ( 1.0 - texCoord204.x ) * 15.0 ) + ( 15.0 * ( 1.0 - texCoord204.y ) ) + ( mulTime133 * WaveFrequency146 ) ) ) * 1.3 ) + ( sin( ( ( ( 1.0 - texCoord205.x ) * 2.0 ) + ( 2.0 * ( 1.0 - texCoord205.y ) ) + ( mulTime144 * WaveFrequency146 ) ) ) * 10.0 ) );
                float WaveStrength166 = ( _WaveStrength * 0.001 );
                float2 texCoord45 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
                float WaveHeight222 = _WaveHeight;
                float temp_output_51_0 = pow( ( 1.0 - abs( ( texCoord45.y - WaveHeight222 ) ) ) , 20.0 );
                float temp_output_208_0 = ( ( Wave91 * WaveStrength166 ) * temp_output_51_0 );
                float2 appendResult11_g1 = (float2(1.0 , 1.0));
                float temp_output_17_0_g1 = length( ( (IN.texcoord.xy*2.0 + -1.0) / appendResult11_g1 ) );
                float temp_output_259_0 = saturate( ( ( 1.0 - temp_output_17_0_g1 ) / fwidth( temp_output_17_0_g1 ) ) );
                float2 texCoord335 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
                float4 tex2DNode3 = tex2D( _MainTex, ( ( temp_output_208_0 * temp_output_259_0 ) + ( temp_output_259_0 * texCoord335 ) ) );
                

                half4 color = ( tex2DNode3 * IN.color );

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
Node;AmplifyShaderEditor.CommentaryNode;246;-5074.663,-143.4229;Inherit;False;586;241;WaveLevel;4;245;242;243;244;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;241;-5039.137,-331.2;Inherit;False;551.1152;148.2898;WaveHeight;2;48;222;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;193;-5499.641,-961.1594;Inherit;False;1011.921;387;rcpHeight;7;186;185;190;191;187;192;201;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;172;-5108.504,-554.1721;Inherit;False;626.4028;190.2482;WaveStrength;3;166;163;171;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;162;-5237.462,-1280.67;Inherit;False;753.4023;304;absSignHeight;4;157;158;161;221;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;154;-4226.552,-2049.619;Inherit;False;1865.2;1666.68;getWave;48;98;99;102;104;107;100;106;108;120;122;123;124;125;127;128;129;131;130;134;135;136;137;139;140;141;142;145;101;133;144;84;89;88;85;83;87;121;147;148;149;150;93;91;167;202;203;204;205;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;151;-4917.821,-1449.595;Inherit;False;432.7544;144.3417;WaveFrequency;2;146;86;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;69;-3938.736,-304.2584;Inherit;False;1575.199;359.2585;Comment;10;226;58;56;49;53;51;52;50;47;45;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;45;-3821.036,-254.2583;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;50;-3256.54,-214;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-2792.54,-191;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;51;-3054.539,-214;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-2586.209,-252.3994;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;49;-3367.54,-223;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;56;-3398.97,-77.71844;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;58;-3578.97,-79.71844;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-3749.42,-1628.923;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-3750.555,-1515.466;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;102;-3550.801,-1537.284;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;104;-3335.43,-1536.846;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;107;-3920.696,-1476.599;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-3923.258,-1555.101;Inherit;False;Constant;_Float3;Float 1;2;0;Create;True;0;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;106;-3923.963,-1637.232;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;-3160.091,-1533.484;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;-3747.43,-1402.241;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;-3750.691,-1223.767;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-3751.825,-1110.31;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;124;-3552.072,-1132.128;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;125;-3336.701,-1131.69;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;127;-3921.967,-1071.442;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;129;-3925.234,-1232.076;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;-3748.7,-997.0856;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-3161.361,-1128.328;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;-3752.864,-812.6605;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;-3753.998,-699.2034;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;136;-3554.245,-721.0214;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;137;-3338.874,-720.5834;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;139;-3924.14,-660.3354;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;141;-3927.407,-820.9694;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;-3750.873,-585.9785;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;101;-3955.801,-1396.284;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;133;-3957.072,-991.1285;Inherit;False;1;0;FLOAT;0.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-3713.271,-1999.619;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;89;-3287.16,-1962.949;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;-3487.383,-1964.314;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-3715.405,-1906.624;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-3857.028,-1938.255;Inherit;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;87;-3946.524,-1835.026;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;-3716.86,-1800.535;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;147;-3972.456,-1749.711;Inherit;False;146;WaveFrequency;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;148;-3979.089,-1317.191;Inherit;False;146;WaveFrequency;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;-3981.745,-909.8832;Inherit;False;146;WaveFrequency;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;150;-3985.726,-495.9403;Inherit;False;146;WaveFrequency;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;93;-2838.239,-1429.638;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;161;-4726.06,-1227.647;Inherit;False;absSignHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;146;-4695.067,-1395.253;Inherit;False;WaveFrequency;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-4905.821,-1394.595;Inherit;False;Property;_WaveFrequency;WaveFrequency;1;0;Create;True;0;0;0;False;0;False;10;180;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;-3163.534,-717.2215;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;171;-4872.514,-500.9239;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;158;-4845.462,-1228.67;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;157;-4967.462,-1227.67;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-5207.641,-911.1594;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;185;-5449.641,-888.1594;Inherit;False;161;absSignHeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;190;-5211.641,-797.1594;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;191;-5060.641,-799.1594;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;187;-4928.641,-911.1594;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;192;-4720.021,-910.6694;Inherit;False;rcpHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;-5424.418,-766.7897;Inherit;False;198;Color_A;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;-1793.89,-1114.411;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;221;-5173.094,-1226.197;Inherit;False;222;WaveHeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;47;-3534.54,-234;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;77;-361.8614,-1009.009;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-149.4435,-1073.963;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;26;14.46045,-1073.919;Float;False;True;-1;2;ASEMaterialInspector;0;3;Liquid_ASE;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;3;1;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;True;True;True;True;True;0;True;_ColorMask;False;False;False;False;False;False;False;True;True;0;True;_Stencil;255;True;_StencilReadMask;255;True;_StencilWriteMask;0;True;_StencilComp;0;True;_StencilOp;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;0;True;unity_GUIZTestMode;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;198;-300.3775,-1278.098;Inherit;False;Color_A;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;2;-821.1921,-1280.152;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;226;-3803.898,-109.4883;Inherit;False;222;WaveHeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;208;-2018.791,-1064.222;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;91;-2603.352,-1424.77;Inherit;False;Wave;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;166;-4724.101,-504.1721;Inherit;False;WaveStrength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-4999.137,-278.2;Inherit;False;Property;_WaveHeight;WaveHeight;2;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;222;-4726.021,-277.3471;Inherit;False;WaveHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;245;-4838.663,-93.42294;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;242;-4730.663,-92.42294;Inherit;False;WaveLevel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;243;-5024.663,-91.42294;Inherit;False;222;WaveHeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;244;-5022.663,-15.42294;Inherit;False;91;Wave;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;262;-1540.867,-900.1945;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;265;-1556.134,-1337.589;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;266;-1322.134,-1465.589;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;253;-1325.953,-1734.32;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;247;-1342.953,-1839.32;Inherit;False;242;WaveLevel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;252;-1497.953,-1740.32;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-1519.953,-1814.32;Inherit;False;Property;_WaterAngle;WaterAngle;3;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;250;-1708.953,-1816.32;Inherit;False;242;WaveLevel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;249;-1151.953,-1840.32;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;254;-952.9534,-1840.32;Inherit;False;y;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-631.871,-1283.892;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;251;-1737.953,-1746.32;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;327;-937.785,-1762.027;Inherit;False;Constant;_Color0;Color 0;4;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;326;-685.1541,-1845.581;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;328;-558.5011,-1806.75;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;-2323.651,-1410.102;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;175;-2015.282,-1194.81;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;140;-3926.702,-738.8384;Inherit;False;Constant;_Float7;Float 1;2;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;128;-3924.529,-1149.945;Inherit;False;Constant;_Float5;Float 1;2;0;Create;True;0;0;0;False;0;False;15;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;167;-2607.696,-1340.119;Inherit;False;166;WaveStrength;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;163;-5058.504,-503.812;Inherit;False;Property;_WaveStrength;WaveStrength;0;0;Create;True;0;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;205;-4173.688,-769.0089;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;204;-4181.576,-1176.396;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;144;-3961.245,-581.0215;Inherit;False;1;0;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;207;-1547.835,-1210.754;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;335;-1823.659,-628.8997;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;337;-1489.759,-644.8358;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;339;-1136.437,-814.0317;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;264;-1302.759,-1100.31;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;202;-4163.024,-1994.811;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;203;-4159.351,-1591.881;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;259;-1823.843,-872.8746;Inherit;True;Ellipse;-1;;1;3ba94b7b3cfd5f447befde8107c04d52;0;3;2;FLOAT2;0,0;False;7;FLOAT;1;False;9;FLOAT;1;False;1;FLOAT;0
WireConnection;50;0;49;0
WireConnection;52;0;45;0
WireConnection;52;1;51;0
WireConnection;51;0;50;0
WireConnection;53;0;45;0
WireConnection;53;1;52;0
WireConnection;49;0;47;0
WireConnection;56;0;58;0
WireConnection;98;0;106;0
WireConnection;98;1;100;0
WireConnection;99;0;100;0
WireConnection;99;1;107;0
WireConnection;102;0;98;0
WireConnection;102;1;99;0
WireConnection;102;2;120;0
WireConnection;104;0;102;0
WireConnection;107;0;203;2
WireConnection;106;0;203;1
WireConnection;108;0;104;0
WireConnection;120;0;101;0
WireConnection;120;1;148;0
WireConnection;122;0;129;0
WireConnection;122;1;128;0
WireConnection;123;0;128;0
WireConnection;123;1;127;0
WireConnection;124;0;122;0
WireConnection;124;1;123;0
WireConnection;124;2;131;0
WireConnection;125;0;124;0
WireConnection;127;0;204;2
WireConnection;129;0;204;1
WireConnection;131;0;133;0
WireConnection;131;1;149;0
WireConnection;130;0;125;0
WireConnection;134;0;141;0
WireConnection;134;1;140;0
WireConnection;135;0;140;0
WireConnection;135;1;139;0
WireConnection;136;0;134;0
WireConnection;136;1;135;0
WireConnection;136;2;142;0
WireConnection;137;0;136;0
WireConnection;139;0;205;2
WireConnection;141;0;205;1
WireConnection;142;0;144;0
WireConnection;142;1;150;0
WireConnection;84;0;202;1
WireConnection;84;1;83;0
WireConnection;89;0;88;0
WireConnection;88;0;84;0
WireConnection;88;1;85;0
WireConnection;88;2;121;0
WireConnection;85;0;83;0
WireConnection;85;1;202;2
WireConnection;121;0;87;0
WireConnection;121;1;147;0
WireConnection;93;0;89;0
WireConnection;93;1;108;0
WireConnection;93;2;130;0
WireConnection;93;3;145;0
WireConnection;161;0;158;0
WireConnection;146;0;86;0
WireConnection;145;0;137;0
WireConnection;171;0;163;0
WireConnection;158;0;157;0
WireConnection;157;0;221;0
WireConnection;186;1;185;0
WireConnection;190;0;185;0
WireConnection;191;0;190;0
WireConnection;191;1;201;0
WireConnection;187;0;186;0
WireConnection;187;1;191;0
WireConnection;192;0;187;0
WireConnection;206;0;175;1
WireConnection;206;1;208;0
WireConnection;47;0;45;2
WireConnection;47;1;226;0
WireConnection;78;0;3;0
WireConnection;78;1;77;0
WireConnection;26;0;78;0
WireConnection;198;0;3;4
WireConnection;208;0;168;0
WireConnection;208;1;51;0
WireConnection;91;0;93;0
WireConnection;166;0;171;0
WireConnection;222;0;48;0
WireConnection;245;0;243;0
WireConnection;245;1;244;0
WireConnection;242;0;245;0
WireConnection;262;0;208;0
WireConnection;262;1;259;0
WireConnection;265;1;206;0
WireConnection;266;0;175;0
WireConnection;266;1;265;0
WireConnection;253;0;248;0
WireConnection;253;1;252;0
WireConnection;252;0;250;0
WireConnection;252;1;251;2
WireConnection;249;0;247;0
WireConnection;249;1;253;0
WireConnection;254;0;249;0
WireConnection;3;0;2;0
WireConnection;3;1;339;0
WireConnection;326;0;254;0
WireConnection;328;0;326;0
WireConnection;328;1;327;0
WireConnection;168;0;91;0
WireConnection;168;1;167;0
WireConnection;207;0;175;0
WireConnection;207;1;206;0
WireConnection;337;0;259;0
WireConnection;337;1;335;0
WireConnection;339;0;262;0
WireConnection;339;1;337;0
WireConnection;264;0;207;0
WireConnection;264;1;259;0
ASEEND*/
//CHKSM=CCFF882F0F7F5AD5AC10613A69BB7FF4910F5567