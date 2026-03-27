Shader "Unlit/VertexDeform"
{
    Properties
    {   
        _WaveSpeed("Wave Speed", Float) = 1.0
        _WaveAmplitude("Wave Ampliture", Range(0.0,0.2)) = 0

        _TopWaveColor("Top Wave Color", Color) = (1,1,1,1)
        _BottomWaveColor("Bottom Wave Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags {"RenderType"="Transparent" "Queue" = "Transparent"} //Geometry is for opaques

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Back
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.283185307179586

            float _WaveSpeed;
            float _WaveAmplitude;

            float4 _TopWaveColor;
            float4 _BottomWaveColor;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normals : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;

                float4 color : TEXCOORD2; 
            };

            float GetWave(float2 uv)
            {
                float2 uvCentered = uv *2 -1;
                float radialDistance = length(uvCentered);

                float wavePattern = cos((radialDistance + _Time.y * _WaveSpeed) * TAU * 5) *0.5 +0.5;
                wavePattern *= 1-radialDistance;
                return wavePattern;
            }

            v2f vert (MeshData v)
            {
                v2f o;

                v.vertex.z = GetWave(v.uv0) * (_WaveAmplitude * 0.01);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normals);
                o.uv = v.uv0;

                return o;
            }

            float InverseLerp(float a, float b, float t)
            {
                return(t-a)/(b-a);
            }

            float4 frag (v2f i) : SV_Target
            {   
                float t = saturate(InverseLerp(_BottomWaveColor, _TopWaveColor, GetWave(i.uv)));
                float f = saturate(InverseLerp(_TopWaveColor, _BottomWaveColor, GetWave(i.uv)));

                float4 topColor = float4(_TopWaveColor);
                float4 botColor = float4(_BottomWaveColor);
 
                return t * topColor + f * botColor;
            }
            ENDCG
        }
    }
}
