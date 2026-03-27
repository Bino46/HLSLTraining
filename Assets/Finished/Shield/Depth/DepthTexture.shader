Shader "Unlit/DepthTexture"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        
        _DepthPow("_DepthPow", Float) = 1.0
        _DepthFactor("_DepthFactor", Float) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        //ZWrite Off
        //ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };

            float4 _Color;

            float _DepthPow;
            float _DepthFactor;

            UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.screenPos = ComputeScreenPos(o.vertex);
                COMPUTE_EYEDEPTH(o.screenPos.z);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 color = _Color;

                float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));
                float depth = sceneZ - i.screenPos.z;

                fixed depthFading = saturate((abs(pow(depth, _DepthPow))) / _DepthFactor);
                color *= depthFading;

                return color;
            } 

            ENDCG
        }
    }
}


