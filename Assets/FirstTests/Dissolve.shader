Shader "Unlit/Dissolve"
{
    Properties
    {
        _MainTex("Noise Texture", 2D) = "white" {}

        _Color("Color", Color) = (1,1,1,1)
        _ShineColor("Shine Color", Color) = (1,1,1,1)
        _ShinePower("Shine Power", Float) = 1

        _FillAmount ("Dissolve Amount", Range(-0.2,1)) = 0.7
        _Smoothing("Smooth", Range(0,0.5)) = 0.05
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

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

            float4 _Color;
            float4 _ShineColor;

            float _ShinePower;
            float _FillAmount;
            float _Smoothing;

            float4x4 cameraToWorld;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float cubicPulse( float c, float w, float x ){
                x = abs(x - c);
                if( x>w ) return 0.0;
                x /= w;
                return 1.0 - x*x*(3.0-2.0*x);
            }

            float4 frag (v2f i) : SV_Target
            {   
                float yPos = smoothstep(i.uv.y - _Smoothing,i.uv.y, _FillAmount);
            
                float4 tex = tex2D(_MainTex, i.uv) * cubicPulse(0.5,_Smoothing, yPos);
                tex *= _ShineColor *_ShinePower;
                float4 finalColor = (_Color + tex) * yPos;

                return finalColor;
            }
            ENDCG
        }
    }
}
