Shader "Custom/ShadowTest"
{
    Properties
    {
        _TestVal("_TestVal", Float) = 1
        _MainTex ("Texture", 2D) = "white" {}
        _AlphaClipping("_AlphaClipping", Float) = 0

        _BaseColor("_BaseColor", Color) = (1,1,1,1)
        _LowColor("_LowColor", Color) = (1,1,1,1)
        _TipColor("_TipColor", Color) = (1,1,1,1)

        [Header(Shadows)]
        _ShadowIntensity("_ShadowIntensity", Range(0,1)) = 1
        _ShadowThreshold("_ShadowThreshold", Float) = 1
        _ShadowPower("_ShadowPower", Float) = 1
        _ShadowSplat("_ShadowSplat", Float) = 1

        [Header(Height)]
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
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        Cull Off

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_instancing
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #include "C:\Users\Maya\Documents\JeuxVideoz\HlslTraining\Assets\Demo Nature Scene\Shader\Grass\HLSLGrass\GradientNoiseHLSL.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS     : NORMAL;
                float4 tangentOS    : TANGENT;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 shadowCoord : TEXCOORD1;
                half3  normalWS : TEXCOORD2;
                float3 wPos : TEXCOORD3;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            CBUFFER_START(UnityPerMaterial)
                sampler2D _MainTex;
                float4 _MainTex_ST;
                float _TestVal;
                float _AlphaClipping;

                float4 _BaseColor;
                float4 _LowColor;
                float4 _TipColor;

                float _ShadowIntensity;
                float _ShadowThreshold;
                float _ShadowPower;
                float _ShadowSplat;

                float _HeightPatchSize;
                float _HeightSizeDiff;

                float _WindStrength;
                float _WindIntensity;
                float _WindSpeed;
                float _XWindDirection;
                float _YWindDirection;
            CBUFFER_END

            float noiseWave(float2 wPos)
            {
                float2 noiseUv = float2(wPos.x, wPos.y - _Time.y * _WindSpeed);
                float windNoise = 0;

                Unity_GradientNoise_float(noiseUv, _WindIntensity, windNoise);
                windNoise = clamp(windNoise, 0, 1);
                return windNoise;
            }

            Varyings vert(Attributes i)
            {
                Varyings o;

                //GPU Instancing
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_TRANSFER_INSTANCE_ID(i, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.wPos = TransformObjectToWorld(i.positionOS.xyz);

                //Wind
                float windNoise = noiseWave(o.wPos.xz);
                float3 wind = windNoise * _WindStrength;
                
                i.positionOS.x += (_XWindDirection * wind * i.uv.y);
                i.positionOS.y += (_YWindDirection * wind * i.uv.y);
                
                //Grass Patches
                float heightRandomness = 0;
                Unity_GradientNoise_float(o.wPos.xz, _HeightPatchSize, heightRandomness);
                heightRandomness *= _HeightSizeDiff;
                
                i.positionOS.z += heightRandomness * i.uv.y;
                i.positionOS.z *= 0.5 + (1 -wind) * i.uv.y;
                
                //Vertex Clip Pos
                VertexPositionInputs vertexInput = GetVertexPositionInputs(i.positionOS.xyz);
                o.positionHCS = vertexInput.positionCS;
                o.shadowCoord = GetShadowCoord(vertexInput);
                
                //Normals
                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(i.normalOS, i.tangentOS);
                o.normalWS = vertexNormalInput.normalWS;

                //Texture
                o.uv = TRANSFORM_TEX(i.uv, _MainTex);

                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                //Texture shape
                float4 col = tex2D(_MainTex, i.uv);
                clip(1-((_AlphaClipping + 1) - col.a));
                
                //Top bottom gradient
                col *= lerp(_LowColor, _BaseColor, i.uv.y);
                
                //Grass patch gradient
                float heightRandomness = 0;
                Unity_GradientNoise_float(i.wPos.xz, _HeightPatchSize, heightRandomness);
                heightRandomness = heightRandomness * _HeightSizeDiff - 0.5;
                col = lerp(col, _TipColor, heightRandomness * i.uv.y);
                
                //Shadows
                Light mainLight = GetMainLight(i.shadowCoord);
                half4 finalColor = (col - (noiseWave(i.wPos.xz) * 0.02)) * float4(mainLight.color,1);
                
                finalColor = lerp(finalColor * (1-_ShadowIntensity), finalColor, mainLight.shadowAttenuation);

                return finalColor;
            }
            ENDHLSL
        }
    }
}
