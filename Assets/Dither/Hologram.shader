// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Hologram"
{
    Properties
    {
        _MainColor("_MainColor", Color) = (1,1,1,1)

        _DitherAmount("_DitherAmount", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
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
                float2 screenPos : TEXCOORD1;
            };

            float4 _MainColor;
            float _DitherAmount;

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos (v.vertex);	   
                o.screenPos = ComputeScreenPos(o.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 scaledUv = i.screenPos * _ScreenParams.xy;

                float2 fracUv = frac(scaledUv * _DitherAmount) * 2 - 1;
                float dot = length(fracUv);

                float4 finalColor = _MainColor * (1-dot);

                if(finalColor.x < 0) discard;

                return finalColor;
            }
            ENDCG
        }
    }
}
