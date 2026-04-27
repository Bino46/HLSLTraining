Shader "Unlit/Grass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AlphaClipping("_AlphaClipping", Float) = 0

        _BaseColor("_BaseColor", Color) = (1,1,1,1)
        _LowColor("_LowColor", Color) = (1,1,1,1)
        _TipColor("_TipColor", Color) = (1,1,1,1)

        _HeightPatchSize("_HeightPatchSize", Float) = 1
        _HeightSizeDiff("_HeightSizeDiff", Float) = 1

        [Header(Wind)] _WindStrength("_WindStrength", Float) = 0
        _WindIntensity("_WindIntensity", Float) = 0
        _WindSpeed("_WindSpeed", Float) = 1
        _XWindDirection("_XWindDirection", Range(-10,10)) = 1
        _YWindDirection("_YWindDirection", Range(-10,10)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}
        Cull Off

        Pass
        {
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "GradientNoise.cginc" 
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
                float3 wPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _AlphaClipping;

            float4 _BaseColor;
            float4 _LowColor;
            float4 _TipColor;

            float _HeightPatchSize;
            float _HeightSizeDiff;

            float _WindStrength;
            float _WindIntensity;
            float _WindSpeed;
            float _XWindDirection;
            float _YWindDirection;

            float noiseWave(float2 wPos)
            {
                float2 noiseUv = float2(wPos.x, wPos.y - _Time.y * _WindSpeed);
                float windNoise = 0;

                Unity_GradientNoise_float(noiseUv, _WindIntensity, windNoise);
                windNoise = clamp(windNoise, 0, 1);
                return windNoise;
            }

            v2f vert (appdata v)
            {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                
                float windNoise = noiseWave(o.wPos.xz);
                
                float3 wind = windNoise * _WindStrength;
                
                v.vertex.x += (_XWindDirection * wind * v.uv.y);
                v.vertex.y += (_YWindDirection * wind * v.uv.y);

                float heightRandomness = 0;
                Unity_GradientNoise_float(o.wPos.xz, _HeightPatchSize, heightRandomness);
                heightRandomness *= _HeightSizeDiff;

                v.vertex.z += heightRandomness * v.uv.y;
                v.vertex.z *= 0.5 + (1 -wind) * v.uv.y ;

                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {   
                // sample the texture
                float4 col = tex2D(_MainTex, i.uv);

                clip(1-((_AlphaClipping + 1) - col.a));

                col *= lerp(_LowColor, _BaseColor, i.uv.y);

                float heightRandomness = 0;
                Unity_GradientNoise_float(i.wPos.xz, _HeightPatchSize, heightRandomness);
                heightRandomness = heightRandomness * _HeightSizeDiff - 0.5;

                col = lerp(col, _TipColor, heightRandomness * i.uv.y);

                float4 finalColor = col - (noiseWave(i.wPos.xz) * 0.02);
                return finalColor;
            }
            ENDCG
        } 
    }
}
