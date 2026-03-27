Shader "Unlit/SeaWaves"
{
    Properties
    {   
        _BaseColor("_BaseColor", Color) = (1,1,1,1)
        _TopColor("_TopColor", Color) = (1,1,1,1)

        [Header(Wave1)]
        _Wave1Intensity("_Wave1Intensity", Float) = 1
        _Wave1Speed("_Wave1Speed", Float) = 1
        _Wave1Strength("_Wave1Strength", Float) = 1

        [Header(Wave2)]
        _Wave2Intensity("_Wave2Intensity", Float) = 1
        _Wave2Speed("_Wave2Speed", Float) = 1
        _Wave2Strength("_Wave2Strength", Float) = 1

        [Header(Noise)]
        _NoiseIntensity("_NoiseIntensity", Float) = 1
        _NoiseSpeed("_NoiseSpeed", Float) = 1
        _NoiseStrength("_NoiseStrength", Float) = 1
         
        _ElapsedTime("_ElapsedTime", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        //Blend SrcAlpha OneMinusSrcAlpha
        Cull Back

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "GradientNoise.cginc"
            #define PI 3.14159

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 wPos : TEXCOORD1;
            };

            float4 _BaseColor;
            float4 _TopColor;

            float _Wave1Intensity;
            float _Wave1Speed;
            float _Wave1Strength;

            float _Wave2Intensity;
            float _Wave2Speed;
            float _Wave2Strength;

            float _NoiseIntensity;
            float _NoiseSpeed;
            float _NoiseStrength;

            float _ElapsedTime;

            float NoisyWave(float x, float z)
            {
                float wave1 = sin(x) + 0.5 * sin(PI * x) - 0.2 * sin(4 * PI * x + PI/2);
                float wave2 = sin(z);
                return wave1 * _Wave1Strength + wave2 * _Wave2Strength;
            }

            v2f vert (appdata v)
            {
                v2f o;

                o.wPos = mul(unity_ObjectToWorld, v.vertex);

                float noise = 0;
                float2 wPosScroll = float2(o.wPos.xz + _ElapsedTime * _NoiseSpeed);
                Unity_GradientNoise_float(wPosScroll, _NoiseIntensity, noise);
                
                float x = o.wPos.x * _Wave1Intensity + _ElapsedTime * _Wave1Speed;
                float z = o.wPos.x * _Wave2Intensity + _ElapsedTime * _Wave2Speed;
                v.vertex.z += NoisyWave(x, z);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 col = _BaseColor; 
                
                float x = i.wPos.x * _Wave2Intensity + _ElapsedTime * _Wave2Speed;
                float wave = sin(x);

                float noise = 0;
                Unity_GradientNoise_float(i.wPos.xz, _NoiseIntensity, noise);                
                float4 finalColor = lerp(_BaseColor, _TopColor, wave);
                return finalColor * noise;
            }
            ENDCG
        }
    }
}
