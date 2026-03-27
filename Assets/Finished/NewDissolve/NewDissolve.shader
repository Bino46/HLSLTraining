Shader "Unlit/NewDissolve"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1,1,1,1)

        _DissolveAmount("Dissolve Amount", Range(0, 1)) = 0.0
        
        _DissolveColor("Dissolve Color", Color) = (1,1,1,1)
        _DissolveColorIntensity("Dissolve Color Intensity", Float) = 1.0
        _DissolveColorThickness("Dissolve Color Thickness", Range(0.01, 0.3)) = 0.1

        _NoiseThickness("Noise Complexity", Float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

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

            float4 _BaseColor;

            float4 _DissolveColor;
            float _DissolveColorIntensity;
            float _DissolveColorThickness;

            float _DissolveAmount;
            float _NoiseThickness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 scrollingUV = float2(i.uv.x, i.uv.y + _Time.y * 0.2);
                float4 noiseTex = tex2D(_MainTex, scrollingUV);

                float dissolveAmountNormalized = lerp(0, _NoiseThickness, _DissolveAmount);
                
                float dissolveLine = 1 - step(i.uv.y - _DissolveAmount, _NoiseThickness * noiseTex.x);
                float shineDissolve = 1 - step(i.uv.y - _DissolveAmount + _DissolveColorThickness, _NoiseThickness * noiseTex.x);
                if(shineDissolve <= 0) discard;

                float4 dissolveColor = shineDissolve * _DissolveColor * _DissolveColorIntensity;

                float4 baseColor = (_BaseColor - _DissolveColor * _DissolveColorIntensity) * dissolveLine;
                
                float4 finalColor = baseColor + dissolveColor;
                return finalColor;
            }
            ENDCG
        }
    }
}
