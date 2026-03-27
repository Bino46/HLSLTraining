Shader "Unlit/MultiLightingTest"
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

        //Base Pass
        Pass
        {
            //Tags { "LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "FGLighting.cginc"

            ENDCG
        }

        //Add Pass
        Pass
        {
            Tags { "LightMode" = "ForwardAdd"}
            Blend One One
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "FGLighting.cginc"

            ENDCG
        }
    }
}
