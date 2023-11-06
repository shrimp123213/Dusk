Shader "Unlit/ripple_shader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _amount ("_amount", Range(0.01, 1.0)) = 0.5
        _spread ("_spread", Range(0.01, 1.0)) = 0.5
        _width ("_width", Range(0.01, 1.0)) = 0.5
        _alpha ("_alpha", Range(0.01, 1.0)) = 0.5
    }
    SubShader
    {		
        Tags{ 
		"RenderType"="Transparent" 
		"Queue"="Transparent"
		"RenderPipeline" = "UniversalPipeline"
	}
        Blend SrcAlpha OneMinusSrcAlpha       
        
	ZWrite off
	Cull off
      
        LOD 100 
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert alpha
            #pragma fragment frag alpha

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct Interpolation
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
		float4 screenPos : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

	    sampler2D _CameraSortingLayerTexture;

            float _amount;
            float _spread;
            float _width;
            float _alpha;

            Interpolation vert (appdata v)
            {
                Interpolation o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);                
		o.screenPos = ComputeScreenPos(o.vertex);

                return o;
            }

            fixed4 frag(Interpolation i) : SV_Target
            {
                float2 center = float2(0.5, 0.5);
                float spread = 0.5f * _spread;

                // Outer edge (Large in center, small outside bounds)
                float outer_map = 1.0 - smoothstep(spread - _width, spread, length(i.uv - center));

                // Inner hole (small values in center, large outside bounds)
                float inner_map = smoothstep(spread - _width * 2.0, spread - _width, length(i.uv - center));

                // Donut shape multiplier
                float map = outer_map * inner_map;

                float2 displacment = normalize(i.uv - center) * _amount * map;
                float4 color = tex2D(_CameraSortingLayerTexture, i.screenPos - float4(displacment.xy, 0, 0) );
                return float4(color.xyz, _alpha);
            }
            ENDCG
        }
    }
}