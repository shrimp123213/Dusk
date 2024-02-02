Shader "Hidden/UI/Liquid2D (SoftMaskable)"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Face ("Face Texture", 2D) = "white" {}
        _ReflectionTex ("ReflectionTex", 2D) = "white" {}
        [HDR]
        _FaceColor ("Face Color", Color) = (1, 1, 1, 1)
        _Progress ("Progress", Range(0.0, 1.0)) = 0.5
        _Tangent ("AngleTangent", float) = 0.66
        _NoiseSpeedScale ("NoiseSpeed(XY)Scale(ZW)", Vector) = (-0.02, 0.2, 0.5, 1)
        _Gradient ("Gradient", Vector) = (2, 0.36, 0, 0)
        [HDR]
        _WaterColor ("WaterColor", Color) = (1.0, 1.0, 0.2, 1.0)
        _WaveStrength ("WaveStrength", Float) = 2.0
        _WaveFrequency ("WaveFrequency", Float) = 180.0
        _WaterTransparency ("WaterTransparency", Float) = 1.0
        _WaterAngle ("WaterAngle", Float) = 4.0
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0

        [HideInInspector]
        _StencilComp ("Stencil Comparison", Float) = 8
        [HideInInspector]
		_Stencil ("Stencil ID", Float) = 0
        [HideInInspector]
		_StencilOp ("Stencil Operation", Float) = 0
        [HideInInspector]
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
        [HideInInspector]
		_StencilReadMask ("Stencil Read Mask", Float) = 255
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Pass
        {
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_instancing
            #pragma multi_compile_local _ PIXELSNAP_ON
            #pragma multi_compile _ ETC1_EXTERNAL_ALPHA

            #include "Packages/com.coffee.softmask-for-ugui/Shaders/SoftMask.cginc"	// Add for soft mask
            #pragma shader_feature __ SOFTMASK_EDITOR	// Add for soft mask
            
            sampler2D _Face;
            sampler2D _ReflectionTex;
            float4 _ReflectionTex_ST;
            float4 _FaceColor;
            float _Progress;
            fixed4 _WaterColor;
            float _WaveStrength;
            float _WaveFrequency;
            float _WaterTransparency;
            float _WaterAngle;
            float _Tangent;
            float4 _NoiseSpeedScale;
            float2 _Gradient;

            struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
			};

            v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color;
				#ifdef PIXELSNAP_ON
				//OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif

				return OUT;
			}

            float getWave(float2 uv, float wave_frequency)
            {
                float wave = sin(10.0 * uv.y + 10.0 * uv.x + wave_frequency * _Time);
                wave += sin(20.0 * -uv.y + 20.0 *  uv.x + wave_frequency * 1.0 * _Time) * 0.5;
                wave += sin(15.0 * -uv.y + 15.0 * -uv.x + wave_frequency * 0.6 * _Time) * 1.3;
                wave += sin(3.0  * -uv.y + 3.0  * -uv.x + wave_frequency * 0.3 * _Time) * 10.0;
                return wave;
            }

            fixed4 drawWater(fixed4 water_color, sampler2D colorTex, float transparency, float height, float angle, float wave_strength, float wave_frequency, fixed2 uv)
            {
                float absSignHeight = abs(sign(height));
                float rcpHeight = 1 * absSignHeight / (1 - absSignHeight + height);//避免除以0
                // angle = angle * uv.y * rcpHeight + angle*angle*_Tangent; //3D effect
                // angle *= uv.y/height+angle/1.5; //3D effect
                wave_strength *= 0.001;

                float wave = getWave(uv, wave_frequency) * wave_strength;
                
                float waterLevel = height + wave;//晃动的水面的高度

                float y = waterLevel + angle * (waterLevel - uv.y);
                fixed4 originColor = tex2D(_ReflectionTex, fixed2(uv.x + wave + _ReflectionTex_ST.z * _Time.y, y + wave + _ReflectionTex_ST.w * _Time.y)) * _FaceColor;
                originColor *= step(y, 1) * originColor.a;//避免取到uv.y大于1的颜色

                fixed4 surfaceColor = lerp(originColor, water_color, saturate(_Gradient.y - (_Gradient.x * (1 - uv.y * rcpHeight))));

                //两次噪声采样，做视差流动
                fixed4 bodyColor = (tex2D(colorTex, fixed2(uv.x + wave/4, uv.y - _Time.y * _NoiseSpeedScale.x)) *_NoiseSpeedScale.z 
                + tex2D(colorTex, fixed2(uv.x + wave/4, uv.y - _Time.y * _NoiseSpeedScale.y)) * _NoiseSpeedScale.w)
                * water_color ;

                //混合水表面和水体的颜色
                fixed4 col = lerp(surfaceColor, bodyColor, transparency * (1 - uv.y/(height+wave)));
                
                //只取水面以下的颜色
                return col * step(uv.y, waterLevel);
            }

            fixed4 frag (v2f i) : SV_Target
            {
				i.color.a *= SoftMask(i.vertex, i.worldPosition);	// Add for soft mask

            	return drawWater(_WaterColor, _Face, _WaterTransparency, i.color.a, _WaterAngle, _WaveStrength, _WaveFrequency, i.texcoord);
            }

            
        ENDCG
        }
    }
}