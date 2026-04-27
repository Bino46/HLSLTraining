Shader "Unlit/ToonTest"
{
    Properties
    {
        _MainColor("Albedo", Color) = (0,1,0,1)

        _ColorSlices("Color Slices", Float) = 1
        _Offset("Offset", Float) = 1

        _FresnelIntensity("Fresnel Intensity", Range(0,1.1)) = 1
        _FresnelColor("Fresnel Color", Color) = (1,1,1,1)

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
            #include "Lighting.cginc"
        
            float4 _MainColor;

            float _ColorSlices;
            float _Offset;

            float _FresnelIntensity;
            float4 _FresnelColor;

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

            float4 remap(float4 In, float2 InMinMax, float2 OutMinMax)
            {
                float4 Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                return Out;
            }


            float4 frag (v2f i) : SV_Target
            {
                float3 n = normalize(i.normal);
                float3 l = _WorldSpaceLightPos0.xyz;
                
                float3 v = normalize(_WorldSpaceCameraPos - i.wPos);
                float3 h = normalize(l + v);

                //Diffuse
                float4 lambert = dot(n,l);
                lambert = remap(lambert, float2(1,-1),float2(1,0));

                float divider = 1/floor(_ColorSlices);
                float cut = lambert / divider + _Offset;
                cut = floor(cut) + 1;

                float4 cutLambert = float4(1 - 1/cut, 1 - 1/cut, 1 - 1/cut, 1);
                cutLambert = clamp(cutLambert, 0.1, 1);

                float fresnel = step(_FresnelIntensity, 1-dot(v,n));
                float4 fresnelColor = _FresnelColor * fresnel;
                
                float3 diffuseLight = cutLambert * _LightColor0.xyz;   

                float4 finalColor = float4(diffuseLight * _MainColor + fresnelColor, 1);
                return finalColor;
            }
            ENDCG
        }
    }
}

//specular 
// float3 v = normalize(_WorldSpaceCameraPos - i.wPos);
// float3 h = normalize(l + v);

// float specularExponent = exp2(_Roughness * 8) + 2;

// float3 specularLight = saturate(dot(h,n)) * (lambert > 0);
// specularLight = pow(specularLight, specularExponent) * _Roughness; //specular exponent
// specularLight *= _LightColor0;