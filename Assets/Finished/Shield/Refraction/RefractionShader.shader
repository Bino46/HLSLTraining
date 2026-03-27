Shader "Unlit/RefractionShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RefractionStrength("_RefractionStrength", Float) = 1.0
        _IOR("_IOR", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                
                float4 screenPos : TEXCOORD1;

                float3 normal : TEXCOORD2;

                float3 wPos : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _RefractionStrength;
            float _IOR;

            sampler2D _CameraOpaqueTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);

                o.normal = UnityObjectToWorldNormal(v.normal);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target{
                
                float3 normalView = normalize(i.normal);
                float3 viewPos = normalize(_WorldSpaceCameraPos - i.wPos);
                
                float fresnel = smoothstep(0,_RefractionStrength, 1-dot(viewPos, normalView));

                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                
                float3 refractedVector = refract(-viewPos, normalView, 1/_IOR);
                
                float2 refract = screenUV + refractedVector * fresnel;

                float3 refractedColor = tex2D(_CameraOpaqueTexture, refract);
                return float4(refractedColor, 1);
            }
            ENDCG
        }
    }
}
 