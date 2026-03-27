Shader "Unlit/Shield"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) =(1,1,1,1)
        _Intensity("Intensity", Float) = 1
        _Fresnel("Fresnel", Float) = 1

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha 

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _Color;
            float _Intensity;
            float _Fresnel;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normals : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float4 vertex : SV_POSITION;

                float3 wPos : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.normal = UnityObjectToWorldNormal(v.normals);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 n = normalize(i.normal);

                float3 v = normalize(_WorldSpaceCameraPos - i.wPos);

                float fresnel = step(_Fresnel, dot(v, n));

                return tex2D(_MainTex, i.uv) * _Color * _Intensity;
            }
            ENDCG
        }
    }
}
