Shader "Unlit/HealthBar"
{
    Properties
    {
        _MainTex("HP Bar", 2D) = "white" {}

        _StartColor("Start Color", Color) = (1.0, 0.0, 0.0, 1.0)
        _EndColor("End Color", Color) = (0.0, 1.0, 0.0, 1.0)
        _CurrentLife("Current HP", Range(0.0, 1.0)) = 1.0

        _PulsationSpeed("Pulse Speed", Float ) = 1.0

        _BorderSize("Border Size", Range(0, 0.6)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}

        Pass
        {
            // ZWrite Off
            // Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;

            float4 _StartColor;
            float4 _EndColor;
            float _CurrentLife;

            float _PulsationSpeed;

            float _BorderSize;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            float InverseLerp(float a, float b, float t)
            {
                return (t-a)/(b-a);
            }   

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float EdgeAndBorder(v2f i)
            {
                float2 coords = i.uv;
                coords.x *= 8;

                float2 pointOnLine = float2(clamp(coords.x, 0.5, 7.5), 0.5);
                float sdf = distance(coords, pointOnLine) * 2 - 1;
                
                clip(-sdf);

                float3 borderSDF = sdf + _BorderSize;

                float PartialDerivative = fwidth(borderSDF);

                float borderMask = 1 - saturate(borderSDF / PartialDerivative);
                return borderMask;
            }

            
            float4 frag (v2f i) : SV_Target
            {
                float uvPos = _CurrentLife > i.uv.x;

                float2 centeredUV = i.uv * 2 - 1;
                float radialDistance = length(centeredUV);

                float2 coord = float2(_CurrentLife, i.uv.y);
                float3 color = tex2D(_MainTex, coord);

                if(_CurrentLife < 0.2)
                {
                    float pulsation = cos(_Time.y * _PulsationSpeed) * 0.4 + 1;
                    color *= pulsation;
                }

                float4 finalColor = float4(color * uvPos * EdgeAndBorder(i), 1);
                return finalColor;
            }

            ENDCG
        }
    }
}

            //? Part one
            // float4 frag (v2f i) : SV_Target
            // {
            //     float uvPos = saturate(((1 - i.uv.x) - (1 - _CurrentLife)) * 100);

            //     float2 thresholds = float2(0.2, 0.8);
            //     float cutLerpValue = InverseLerp(thresholds.x, thresholds.y, _CurrentLife);
                
            //     float4 finalColor = lerp(_StartColor,  _EndColor, cutLerpValue);

            //     return finalColor * uvPos;
            // }
