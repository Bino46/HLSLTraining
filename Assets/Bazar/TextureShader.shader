Shader "Unlit/TextureShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RockTex ("Rock", 2D) = "white" {}
        _Pattern("Pattern", 2D) = "white" {}
        _MoveSpeed("Move Speed", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST; //optionnal -> tiling and offset
            
            sampler2D _RockTex;
            sampler2D _Pattern;

            float _MoveSpeed;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPosition : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;

                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv; //take offset and scale and apply to uv coordinates
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {   
                //return float4(i.worldPosition.xyz, 1);

                float4 moss = tex2D(_MainTex, i.worldPosition.xz);
                float4 rock = tex2D(_RockTex, i.worldPosition.xz);
                float pattern = tex2D(_Pattern, i.uv);

                float4 finalColor = lerp(rock, moss, pattern);
                return finalColor;
            }
            ENDCG
        }
    }
}
