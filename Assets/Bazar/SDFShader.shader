Shader "Unlit/SDFShader"
{
    Properties
    {

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv *2 - 1;

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float dist = length(i.uv) -0.5;
               // return step(0, dist);

                return float4(dist.xxx, 0); //shows negative distance
            }
            ENDCG
        }
    }
}
