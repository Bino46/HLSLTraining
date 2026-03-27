Shader "Unlit/Exemple"
{
 Properties
    { 
    }
    
    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque"
        }
        
        Cull Off
        ZWrite On
        Pass
        {
            // The LightMode tag matches the ShaderPassName set in UniversalRenderPipeline.cs.
            // The SRPDefaultUnlit pass and passes without the LightMode tag are also rendered by URP
            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            
            HLSLPROGRAM
                        
            #pragma vertex vert
            #pragma fragment frag

            // This multi_compile declaration is required for the Forward rendering path
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            
            // This multi_compile declaration is required for the Forward+ rendering path
            #pragma multi_compile _ _CLUSTER_LIGHT_LOOP
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
            
            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
            };
            
            struct Varyings
            {
                float4 positionCS  : SV_POSITION;
                float3 positionWS  : TEXCOORD1;
                float3 normalWS    : TEXCOORD2;
            };
            
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionCS = TransformWorldToHClip(OUT.positionWS);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                
                return OUT;
            }
            
            float3 MyLightingFunction(float3 normalWS, Light light)
            {
                float NdotL = dot(normalWS, normalize(light.direction));
                NdotL = (NdotL + 1) * 0.5;
                return saturate(NdotL) * light.color * light.distanceAttenuation * light.shadowAttenuation;
            }
            
            // This function loops through the lights in the scene
            float3 MyLightLoop(float3 color, InputData inputData)
            {
                float3 lighting = 0;
                
                // Get the main light
                Light mainLight = GetMainLight();
                lighting += MyLightingFunction(inputData.normalWS, mainLight);
                
                // Get additional lights
                #if defined(_ADDITIONAL_LIGHTS)

                // Additional light loop for non-main directional lights. This block is specific to Forward+.
                #if USE_CLUSTER_LIGHT_LOOP
                UNITY_LOOP for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
                {
                    Light additionalLight = GetAdditionalLight(lightIndex, inputData.positionWS, half4(1,1,1,1));
                    lighting += MyLightingFunction(inputData.normalWS, additionalLight);
                }
                #endif
                
                // Additional light loop.
                uint pixelLightCount = GetAdditionalLightsCount();
                LIGHT_LOOP_BEGIN(pixelLightCount)
                    Light additionalLight = GetAdditionalLight(lightIndex, inputData.positionWS, half4(1,1,1,1));
                    lighting += MyLightingFunction(inputData.normalWS, additionalLight);
                LIGHT_LOOP_END
                
                #endif
                
                return color * lighting;
            }
            
            half4 frag(Varyings input) : SV_Target0
            {
                // The Forward+ light loop (LIGHT_LOOP_BEGIN) requires the InputData struct to be in its scope.
                InputData inputData = (InputData)0;
                inputData.positionWS = input.positionWS;
                inputData.normalWS = input.normalWS;
                inputData.viewDirectionWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
                
                float3 surfaceColor = float3(1, 1, 1);
                float3 lighting = MyLightLoop(surfaceColor, inputData);
                
                half4 finalColor = half4(lighting, 1);
                
                return finalColor;
            }
            
            ENDHLSL
        }
    }
}
