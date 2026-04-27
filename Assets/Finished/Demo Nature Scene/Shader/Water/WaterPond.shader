Shader "Unlit/WaterPond"
{
    Properties
    {
        [Header(Colors)]
        _DeepColor("_DeepColor", Color) = (1,1,1,1)
        _BorderColor("_BorderColor", Color) = (1,1,1,1)
        
        [Header(Depth)]
        _DepthPow("_DepthPow", Float) = 1.0
        _DepthFactor("_DepthFactor", Float) = 1.0

        [Header(Waves)]
        _WaveIntensity("_WaveIntensity", Float) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        //ZWrite Off
        //ZTest Always
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #define PI 3.14159265 

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            float4 _DeepColor;
            float4 _BorderColor;

            float _DepthPow;
            float _DepthFactor;

            float _WaveIntensity;

            UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

            float WaterWave(float2 uv)
            {
                float waveModifier = (sin(PI*uv.x) + 2 * sin(uv-0.5.x) - sin(2 * PI * uv.x)) * 0.3;
                float test = frac(length(uv * waveModifier) - _Time.y);
                return test;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.screenPos = ComputeScreenPos(o.vertex);
                COMPUTE_EYEDEPTH(o.screenPos.z);
                o.uv = v.uv;
                return o;
            }

            float GetSceneDepth(float4 screenPos)
            {
                float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(screenPos)));
                float depth = sceneZ - screenPos.z;
    
                return saturate((abs(pow(depth, _DepthPow))) / _DepthFactor);
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 color = lerp(_BorderColor, _DeepColor, GetSceneDepth(i.screenPos));
                float test = WaterWave(i.uv);

                return color;
            } 

            ENDCG
        }
    }
}


