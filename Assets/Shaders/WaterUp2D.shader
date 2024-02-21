Shader "Unlit/Water2DUp_new"
{
    //2d水上涨效果：
    //1.定义水面高度参数   
    //2.对满足水面高度的点，按照uv.x的值来进行sin函数变换，记录 最终高度值
    //3.对高于该值的赋予无水颜色，低于该值的赋予水颜色。
    //4.加变量，移动
    //5.对纹理取 需要轮廓（圆形，圆心在中心，半径为最短边的一半）
    //6.对轮廓外的部分透明，轮廓内的部分 颜色采样
  
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Clo("Color",Color)=(1,1,1,1)
        _Wave("Wave",float)=0
        _WaterHeight("WaterHeight",float)=0
        _Speed("Speed",float)=1
        _T("T",float)=1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;

            float4 _MainTex_ST;
            float _WaterHeight;
            fixed4 _Clo;
            float _Wave;
            float _Speed;
            float _T;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = fixed4(1,1,1,0);

                //亮度
                fixed4 lightT = 0.7+ i.uv.y * fixed4(1,1,1,1);

                //
                float offsetV = 0.1*_Wave*sin(i.uv.x*_T + _Time.y*2*_Speed);
                if(i.uv.y <= _WaterHeight + offsetV){
                     col = _Clo *lightT;
                     col.a = 1;
                }

                //取圆

                return col;
            }
            ENDCG
        }

        //取圆
        Pass{
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata{
                float4 vertex:POSITION;
                float2 uv:TEXCOORD0;
            };

            struct v2f{
                float4 vertex:SV_POSITION;
                float2 uv:TEXCOORD0;
                float transp:TEXCOORD1;
            };
            
             sampler2D _MainTex;
             float4 _MainTex_TexelSize;
            
            v2f vert(appdata v){
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                
                fixed4 col = tex2D(_MainTex,i.uv);

                 float leng = _MainTex_TexelSize.z > _MainTex_TexelSize.w ? _MainTex_TexelSize.w/2 : _MainTex_TexelSize.z/2;
                float2 uv_temp;
                uv_temp.x = i.uv.x * _MainTex_TexelSize.z;
                uv_temp.y = i.uv.y * _MainTex_TexelSize.w;
                if(uv_temp.x>0.5*_MainTex_TexelSize.z-leng && uv_temp.x<0.5*_MainTex_TexelSize.z+leng 
                    && uv_temp.y>0.5*_MainTex_TexelSize.w-leng && uv_temp.y<0.5*_MainTex_TexelSize.w+leng){
                    i.transp = 1;
                    }else{
                    i.transp = 0;
                    }
                if(i.transp < 0.0000001){
                    col = fixed4(0,0,0,0);
                }

                return col;
            }
            ENDCG
        }
    }
}

