Shader "Unlit/Shader2"
{
    Properties
    {   
        _Offset ("UV Offset", Float) = 0.0
        _newColor ("Primary Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _newColor2 ("Secondary Color", Color) = (1.0, 1.0, 1.0, 1.0)

        _ColorStart ("Color Start", Range(0.0, 1.0)) = 0
        _ColorEnd ("Color End", Range(0.0, 1.0)) = 0
        
        _WaveSpeed("Wave Speed", Float) = 1.0
        _WaveColor ("Wave Color", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags {"RenderType"="Transparent" "Queue" = "Transparent"}

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.283185307179586

            float _Offset;

            float4 _newColor;
            float4 _newColor2;

            float _ColorStart;
            float _ColorEnd;

            float _WaveSpeed;
            float4 _WaveColor;

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

            v2f vert (MeshData v)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normals);
                o.uv = v.uv0 + _Offset;
                return o;
            }

            float InverseLerp(float a, float b, float t)
            {
                return(t-a)/(b-a);
            }

            float4 frag (v2f i) : SV_Target
            {
                float xOffset = cos(i.uv.x * TAU * 8) * 0.01;

                float WavePattern = cos((i.uv.y + xOffset + _Time.y * _WaveSpeed) * TAU * 5) * 0.5 + 0.5;

                float t = saturate(InverseLerp(_ColorStart, _ColorEnd, WavePattern)) * (1-i.uv.y);
                float f = saturate(InverseLerp(_ColorEnd, _ColorStart , WavePattern)) * (1-i.uv.y);

                t *= (abs(i.normal.y) < 0.999);
                f *= (abs(i.normal.y) < 0.999);
                
                float4 waterColor = lerp(_newColor, _newColor2, t);
                float4 waveColor = float4(_WaveColor);
                
                return t * waterColor + f * waveColor;
            }
            ENDCG
        }
    }
}
