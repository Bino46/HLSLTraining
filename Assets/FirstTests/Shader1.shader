Shader "Unlit/Shader1"
{
    Properties //input data
    {
        //_MainTex ("Texture", 2D) = "white" {}

        //TODO PropertyName ("Name in inspector", type) = initialize (no ;)
        _Value ("Value", Float) = 1.0
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader //render pipeline related
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        //LOD 100 mostly useless

        Pass //graphics related
        {            
            Blend One One //Additive
            //Blend DstColor Zero //Multiply
            ZWrite Off
            //Cull Front
            //ZTest GEqual //Sort of masking, LEqual = normal, Always = always rendering even behind opaques, GEquals = rendering through opaques

            CGPROGRAM //Shader code, != from HLSL ?

            //? defines what is the VERTEX shader function and what is the FRAGMENT shader fonction
            #pragma vertex vert 
            #pragma fragment frag

            #include "UnityCG.cginc" //Unity specific things, always have, can add more if needed
            
            float _Value; //get automatically the value from properties
            float4 _Color;

            struct MeshData //? also named appdata, per vertex mesh data
            {
                //Example types
                float4 vertex : POSITION; //vertex pos
                float2 uv0 : TEXCOORD0; //uv0 channel coodinates, ex : Diffuse/normal
                //float4 color : COLOR;

                //float3 normal : NORMAL; //local normal direction of the vertex, mostly used in shading
                //float4 tangent : TANGENT; //tangent direction, xyz = direction / w = sign 
                //? Channels are used to cumulate different UV on a mesh, can be float2 to float4
                //float4 uv1 : TEXCOORD1; // uv1 channel coodinates, ex : Lightmap
            };
            
            struct v2f //! Data from vertex shader to fragment shader, one-way direction. Looses access to any not transferred vertex data from here
            {          //! Also called Interpolators, fragment shader will interpolate data between connected vertices like normals
                float4 vertex : SV_POSITION; //clip space position, mandatory
                float3 uv : TEXCOORD0; 
            };

            //? Vertex shader
            v2f vert (MeshData v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); //converts local space to clip space, o = output
                return o;
            }

            //bool, can be used sometimes
            //int, will be changed to float anyway
            //float = 32bit float, used for world space, mostly used
            //half = 16bit float, used in general, good for mobile/optimisation
            //fixed (old) = lower precision, useful for -1 to 1 values 

            //TODO use float everytime until optimisation is needed

            //Types ex = float4 -> half4 -> fixed4 (bool4 ?)
            //Matrices = float4x4 -> half4x4 -> fixed4x4

            float4 frag (v2f i) : SV_Target //output to the frame buffer
            {
                return _Color;
            }
            ENDCG
        }
    }
}
