Shader "Unlit/LightingTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor("Albedo", Color) = (0,1,0,1)
        _Roughness("Roughness", Range(0, 1)) = 1
        _Fresnel("Fresnel", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry"}

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            
            sampler2D _MainTex;
            float4 _MainColor;
            float _Roughness;
            float _Fresnel;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
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
                o.uv = v.uv;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 n = normalize(i.normal);
                float3 l = _WorldSpaceLightPos0.xyz; //direction when directional light, position when other.

                // float3 ligthDirection;
                // float attenuation = 1;

                // if(_WorldSpaceLightPos0.w == 0.0)
                // {
                //     ligthDirection = normalize(_WorldSpaceLightPos0.xyz);
                // }
                // else
                // {
                //     float3 vertexLightDirection = _WorldSpaceLightPos0.xyz - i.wPos.xyz;
                //     float distance = length(vertexLightDirection);

                //     attenuation = 1/distance;
                //     ligthDirection = normalize(vertexLightDirection);
                // }

                //Diffuse
                float3 lambert = saturate(dot(n,l)); //dot product from light pos and vertex pos around the object (front = shiny, side = dark)
                float3 diffuseLight = _LightColor0.xyz * _MainColor.xyz * max(0.0,dot(lambert, _LightColor0.xyz));  

                //specular 
                float3 v = normalize(_WorldSpaceCameraPos - i.wPos);
                float3 h = normalize(l + v);

                float specularExponent = exp2(_Roughness * 8) + 2;

                float3 specularLight = saturate(dot(h,n)) * (lambert > 0);
                specularLight = pow(specularLight, specularExponent) * _Roughness; //specular exponent
                specularLight *= _LightColor0;

                //Fresnel
                float fresnel = step(_Fresnel, dot(v, n));

                float4 finalColor = float4(diffuseLight + specularLight + (1-fresnel), 1);
                return finalColor;
            }
            ENDCG
        }
    }
}
