Shader "Unlit/LeafShader"
{
    Properties
    {
        [Header(Base Color)] _MainTex ("Texture", 2D) = "white" {}
        _BaseColor("_BaseColor", Color) = (1,1,1,1)
        _ColorVarianceStrength("_ColorVarianceStrength", Float) = 0
        _ColorVarianceIntensity("_ColorVarianceIntensity", Float) = 0
        _AlphaClipping("_AlphaClipping", Range(0,1)) = 0
        
        [Header(Shadow)] _ShadowColor("_ShadowColor", Color) = (1,1,1,1)
        _ShadowOffset("_ShadowOffset", Float) = 1
        _InteriorDrawSize("_InteriorDrawSize", Float) = 0
        _InteriorDrawThreshold("_InteriorDrawThreshold", Float) = 0
        _InteriorOffset("_InteriorOffset", Vector) = (1,1,1)

        [Header(Wind)] _WindStrength("_WindStrength", Float) = 0
        _WindIntensity("_WindIntensity", Float) = 0
        _WindSpeed("_WindSpeed", Float) = 1
    }
    SubShader
    {
        Tags {"RenderType"="Opaque" "Queue"="Geometry"}
        //Blend SrcAlpha OneMinusSrcAlpha
        //ZWrite Off
        //ZTest Always
        Cull Off

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "GradientNoise.cginc"

            #define PI 3.14159

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;

                float3 wPos : TEXCOORD2;
                float3 viewDirection : TEXCOORD3;
            };

            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            float4 _BaseColor;
            float4 _ShadowColor;
            float _ColorVarianceStrength;
            float _ColorVarianceIntensity;
            
            float _AlphaClipping;
            
            float _ShadowOffset;
            float _InteriorDrawSize;
            float _InteriorDrawThreshold;
            float4 _InteriorOffset;

            float _WindStrength;
            float _WindIntensity;
            float _WindSpeed;

            v2f vert (appdata v){

                v2f o;

                o.wPos = mul(unity_ObjectToWorld, v.vertex);

                float2 noiseUv = float2(o.wPos.x, o.wPos.y - _Time.y * _WindSpeed);
                float windNoise = 0;
                Unity_GradientNoise_float(noiseUv, _WindIntensity, windNoise);
                
                float3 wind = (sin(windNoise * PI) + sin(2 * windNoise)) * _WindStrength * windNoise;
                
                v.vertex.xyz += wind;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.viewDirection = WorldSpaceViewDir(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 InteriorLeafColor(float2 uv){
                
                float2 newUv = (uv + 0.5) * _InteriorDrawSize - _InteriorDrawSize;
                float4 interiorCol = tex2D(_MainTex, newUv + _InteriorOffset.xy);

                return interiorCol;
            }

            float4 LeafColor(float viewDir, float2 uv, float3 wPos){
                
                //float lightThreshold = 
                float4 diffuseColor = lerp(_ShadowColor, _BaseColor, viewDir);

                float noiseColor = 0;
                Unity_GradientNoise_float(wPos, _ColorVarianceIntensity, noiseColor);
                noiseColor -= 0.75;
                
                float4 col = tex2D(_MainTex, uv);
                float4 returnColor = col * (diffuseColor + noiseColor * _ColorVarianceStrength);
                
                float4 smoothInteriorColor = InteriorLeafColor(uv) * 0.2 * (1 - viewDir);
                if(viewDir < _InteriorDrawThreshold) returnColor = (col - smoothInteriorColor) * (diffuseColor + noiseColor * _ColorVarianceStrength);

                clip(1-((_AlphaClipping + 1) - col.a));
                
                return returnColor;
            }

            float4 frag (v2f i) : SV_Target{

                float3 normalDir = normalize(i.normal);
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.wPos));
                float3 viewDir = normalize(i.viewDirection);

                float lightDot = saturate(dot(normalDir, lightDir) + _ShadowOffset);

                //InputData lighting = (InputData) 0;

                float4 finalColor = LeafColor(lightDot, i.uv, i.wPos);
                
                return finalColor;
            }
            ENDCG
        }

        Pass
        {
            Tags {"RenderType"="Opaque" "Queue"="Geometry" "LightMode"="ShadowCaster" "RenderType"="AlphaTest"}
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "GradientNoise.cginc"

            #define PI 3.14159

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;

                float3 wPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _AlphaClipping;

            float _WindStrength;
            float _WindIntensity;
            float _WindSpeed;

            v2f vert (appdata v){

                v2f o;

                o.wPos = mul(unity_ObjectToWorld, v.vertex);

                float2 noiseUv = float2(o.wPos.x, o.wPos.y - _Time.y * _WindSpeed);
                float windNoise = 0;
                Unity_GradientNoise_float(noiseUv, _WindIntensity, windNoise);
                
                float3 wind = (sin(windNoise * PI) + sin(2 * windNoise)) * _WindStrength * windNoise;
                
                v.vertex.xyz += wind;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target{

                float4 col = tex2D(_MainTex, i.uv);
                clip(1-((_AlphaClipping + 1) - col.a));
                
                return col;
            }
            ENDCG
        }

    }
}
