Shader "Unlit/Aurora"
{
    Properties
    {
        _Scale("_Scale", Float) = 1.0
        _Speed("_Speed", Float) = 1.0
        _Thickness("_Thickness", Float) = 1.0
        _BlurThickness("_BlurThickness", Float) = 1.0
        _distanceBetweenShells("_distanceBetweenShells", Float) = 1

        _NoiseIntensity("_NoiseIntensity", Float) = 1.0
        _NoiseSpeed("_NoiseSpeed", Float) = 1.0
        
        _DownColor("_DownColor", Color) = (1,1,1,1)
        _DownIntensity("_DownIntensity", Float) = 1.0
        _TopColor("_TopColor", Color) = (1,1,1,1)
        _TopIntensity("_TopIntensity", Float) = 1.0

        _currentShell("_currentShell", Float) = 1.0
        _shellCount("_shellCount", Float) = 1.0
    }
    SubShader
    {
        // Tags {"RenderType"="Opaque"}
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "GradientNoise.cginc" 
            
            #define PI 3.14158

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            
            float _Scale;
            float _Speed;
            float _Thickness;
            float _BlurrThickness;
            
            float _NoiseScale;
            float _NoiseIntensity;
            float _NoiseSpeed;
            float _TopWaveAlphaNoise;
            
            float4 _DownColor;
            float _DownIntensity;
            float4 _TopColor;
            float _TopIntensity;
            
            float _shellCount;
            float _currentShell;
            float _distanceBetweenShells;

            v2f vert (appdata v)
            {
                v2f o;

                v.vertex.y += _distanceBetweenShells * _currentShell;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float NoisyWave(float axis, float x, float scale)
            {
                return axis + abs((sin(x) + 0.5 * sin(PI * x) - 0.2 * sin(4 * PI * x + PI/2))) * scale;
            }

            float4 frag (v2f i) : SV_Target
            {
                float shellNormalized = _currentShell / _shellCount;
                
                float2 modifiedUV = i.uv;
                modifiedUV.x *= 2.5;
                //modifiedUV.x += _Time.y * _Speed;

                float x = modifiedUV.x + _Time.y * _NoiseSpeed;
                float input = NoisyWave(shellNormalized, x + 2, _TopWaveAlphaNoise);
                
                float heightNoise = saturate(smoothstep(0,1.2,input));

                float noise = 0;
                Unity_GradientNoise_float(x, _NoiseScale, noise);
                noise += _NoiseIntensity;
                noise = clamp(noise,-0.5,1);
                noise *= heightNoise;
                
                x = modifiedUV.x + _Time.y * _Speed;
                float input2 = NoisyWave(i.uv.y, x, _Scale) - 0.75;
                float mainWave = smoothstep(_Thickness,0.0, abs(input2));
                float blurrWave = smoothstep(_BlurrThickness,0.0, abs(input2)) * 0.6;

                float finalWave = mainWave + blurrWave;
                
                float4 color = lerp(_TopColor * _TopIntensity , _DownColor * _DownIntensity, shellNormalized);
                color = color * finalWave * noise;

                return float4(color);
            }
            ENDCG
        }
    }
}
