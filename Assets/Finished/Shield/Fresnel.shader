Shader "Unlit/Fresnel"
{
    Properties
    {
        _MainTex("Shield Texture", 2D) = "white" {}

        [Header(Base Color)] _BaseColor("_BaseColor", Color) = (1,1,1,1)
        _BaseColorIntensity("_BaseColorIntensity", Range(0, 0.3)) = 0.0
        _TextureColor("_TextureColor", Color) = (1,1,1,1)
        
        [Header(Color Fresnel)] _FresnelThickness("Fresnel Thickness", Float) = 0.0
        _FresnelIntensity("Fresnel Intensity", Float) = 1.0
        _FresnelPulseIntensity("_FresnelPulseIntensity", Float) = 1.0

        [Header(Depth)] _LineDepthPow("_LineDepthPow", Float) = 1.0
        _LineDepthSize("_LineDepthSize", Float) = 1.0
        _LineDepthColor("_LineDepthColor", Color) = (1,1,1,1)

        [Header(Impact Pulse)] _PulseColor("_PulseColor", Color) = (1,1,1,1)
        _PulseIntensity("_PulseIntensity", Float) = 1.0
        _ImpactRipple("_ImpactRipple", Float) = 1.0
        
        [Header(Refraction)]_RefractionStrength("_RefractionStrength", Float) = 1.0
        _RefractionFresnel("_RefractionFresnel", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        //Cull Off 
        //Tags{"RenderType"="Opaque"}
        
        Pass
        {
            CGPROGRAM
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "GradientNoise.cginc" 

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 wPos : TEXCOORD1;

                float3 normals : TEXCOORD2;

                float4 screenPos : TEXCOORD4; 

                float3 wViewDir : TEXCOORD5;
            };

            float4 _MainTex_ST;
            sampler2D _MainTex;

            float4 _BaseColor;
            float _BaseColorIntensity;
            
            float _FresnelThickness;
            float4 _TextureColor;
            float _FresnelIntensity;
            float _FresnelPulseIntensity;

            float _CutAmount;
            float _CutIntensity;

            float _LineDepthPow;
            float _LineDepthSize;
            float4 _LineDepthColor;

            float3 _hitPos; 
            float _impactSize;
            float _impactTime;

            float4 _PulseColor;
            float _PulseIntensity;
            float _ImpactRipple;

            sampler2D _CameraOpaqueTexture;
            float _RefractionStrength;
            float _RefractionFresnel;

            UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

            v2f vert (appdata v) {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex.xyz);
                o.screenPos = ComputeScreenPos(o.vertex);

                COMPUTE_EYEDEPTH(o.screenPos.z);

                o.wViewDir = WorldSpaceViewDir(v.vertex);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.normals = UnityObjectToWorldNormal(v.normal);

                o.wPos = mul(unity_ObjectToWorld, v.vertex);

                //impact ripple
                float dist = distance(o.wPos, _hitPos);
                if(dist < _impactTime && dist > _impactTime - _impactSize) o.vertex.xyz += v.normal * _ImpactRipple;

                return o;
            }

            float4 shieldTexture(float2 uvs){

                float2 slowUv = float2(uvs.x, uvs.y +_Time.y * 0.05);

                float4 shieldTex = tex2D(_MainTex, slowUv);

                return shieldTex;
            }

            float addNoise(float2 uv)
            {
                float2 glintUv = float2(uv.x, uv.y - _Time.y * 0.1);

                float noise = 0;
                Unity_GradientNoise_float(glintUv, 12, noise);

                noise = step(0.8, noise);

                return noise;
            }

            float fresnelEffect(float3 normals, float3 wPos){

                float3 normalView = normalize(normals);
                float3 viewPos = normalize(_WorldSpaceCameraPos - wPos);
                
                float fresnel = smoothstep(0,_FresnelThickness, 1-dot(viewPos, normalView));

                float fresnelEffect = fresnel * _FresnelIntensity * _FresnelPulseIntensity;

                return fresnelEffect;
            }

            float4 refraction(v2f i)
            {
                float3 normalView = normalize(i.normals);
                float3 viewPos = normalize(_WorldSpaceCameraPos - i.wPos);
                
                float fresnel = smoothstep(0,_RefractionFresnel, 1-dot(viewPos, normalView));

                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                
                float3 refractedVector = refract(-viewPos, normalView, 1/(_RefractionStrength * _FresnelPulseIntensity));
                
                float2 refract = screenUV + refractedVector * fresnel;

                float3 refractedColor = tex2D(_CameraOpaqueTexture, refract);
                return float4(refractedColor, 1);
            }

            float4 finalFresnel(v2f i) {
                
                float4 glintingShieldTexture = shieldTexture(i.uv) + step(0.4,shieldTexture(i.uv) * addNoise(i.uv)) * 20;
                
                float4 fresnelColor = _TextureColor * glintingShieldTexture;
                
                fresnelColor *= fresnelEffect(i.normals, i.wPos);

                if(fresnelColor.w <= 0.4) return 0;
                
                return fresnelColor;
            }

            float depthShine(float4 screenPos){

                float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(screenPos)));
                float depth = sceneZ - screenPos.z;

                float depthLine = saturate((abs(pow(depth, _LineDepthPow))) * _LineDepthSize);
                return depthLine;
            }

            float4 frag (v2f i) : SV_Target {

                //Impact
                float dist = distance(i.wPos, _hitPos);
                if(dist < _impactTime && dist > _impactTime - _impactSize) return _PulseColor * _PulseIntensity;

                //Cross line when overlap
                float lineDepth = depthShine(i.screenPos);

                float4 shieldColor = finalFresnel(i) * lineDepth + _LineDepthColor * (1-lineDepth) + _BaseColor * fresnelEffect(i.normals, i.wPos) * _BaseColorIntensity;
                shieldColor += refraction(i);


                return shieldColor;
            }
            ENDCG
        }
    }
}

