Shader "Unlit/Grass"
{
    Properties
    {
        _BaseColor("Color", Color) = (1,1,1,1)
        _Seed("Seed", Float) = 1.0
        _Scale("Scale", Float) = 1.0
        _Density("Density", Range(-0.5,0.5)) = 1.0

        _currentShell("Current Shell", Float) = 1.0
        _shellCount("_ShellCount", Float) = 1.0
        _thickness("Thickness", Float) = 1.0
        _minThickness("Min Thickness", Float) = 1.0
        _maxHeight("Max Height", Float) = 1.0
        _spaceBetweenShells("Space Between Shells", Float) = 1.0

        _WindNoise("Wind Texture", 2D) = "white" {}
        _windAmount("Wind Amount", Float) = 1.0
        _windStrength("Wind Strength", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 windWave : TEXCOORD1;
            };

            float hash(uint seed) {
				// integer hash copied from Hugo Elias
				seed = (seed << 13U) ^ seed;
				seed = seed * (seed * seed * 15731U + 0x789221U) + 0x1376312589U;
				return float(seed & uint(0x7fffffffU)) / float(0x7fffffff);
			}

            float4 _BaseColor;

            float _Seed;
            float _Scale;
            float _Density;

            float _currentShell;
            float _shellCount;
            float _thickness;
            float _minThickness;
            float _spaceBetweenShells;
            float _maxHeight;

            float4 _WindNoise_ST;
            sampler2D _WindNoise;

            float _windAmount;
            float _windStrength;

            v2f vert (appdata v)
            {
                v2f o;
                o.windWave = TRANSFORM_TEX(v.uv, _WindNoise);

                v.vertex += (_spaceBetweenShells * _currentShell)/_maxHeight * float4(v.normal, 0);
                
                float displacement = _currentShell / _shellCount * _windStrength;

                float2 noiseUV = v.uv * 0.3;
                noiseUV += _Time.y * float2(1,1) * _windAmount;
                float4 noiseTex = tex2Dlod(_WindNoise, float4(noiseUV,0,0));

                v.vertex.x += displacement * noiseTex.x;

                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv = v.uv;

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 extendedUV = i.uv * _Scale;

                float2 cellCoord = floor(extendedUV);
                cellCoord.x += hash(-cellCoord) * _Scale;
                cellCoord.y += hash(cellCoord) * _Scale;
                
                float2 newUV = cellCoord + frac(extendedUV);

                float2 fracUV = frac(newUV) * 2 - 1;

                float2 noiseUV = i.uv * 0.3;
                noiseUV += _Time.y * _windAmount;
                float4 noiseTex = tex2Dlod(_WindNoise, float4(noiseUV,0,0));
                
                uint2 tid = newUV;
				uint seed = tid.x + 100 * tid.y + 100 * 10;
                
                float shellHeight = _currentShell / _shellCount;

                float lengthFromCenter = length(fracUV);

                lengthFromCenter += 1-lerp(_thickness,_minThickness,_currentShell/_shellCount);

                float3 color = round(hash(seed * _Seed) + _Density) * step(lengthFromCenter,0.2);
                if(color.x <= 0) discard;

                color *= lerp(float4(0,0.02,0,1), _BaseColor, shellHeight);
                
                return float4(color,0);
            }
            ENDCG
        }
    }
}

            // float4 frag (v2f i) : SV_Target
            // {
            //     float2 extendedUV = i.uv * _Scale;
                
            //     float2 fracUV = frac(extendedUV) * 2 - 1;
            //     return float4(fracUV, 1,1);

            //     float2 noiseUV = i.uv*  0.3;
            //     noiseUV += _Time.y * _windAmount;
            //     float4 noiseTex = tex2Dlod(_WindNoise, float4(noiseUV,0,0));
                
            //     uint2 tid = extendedUV;
			// 	uint seed = tid.x + 100 * tid.y + 100 * 10;
                
            //     float shellHeight = _currentShell / _shellCount;

            //     float lengthFromCenter = length(fracUV);

            //     lengthFromCenter += 1-lerp(_thickness,_minThickness,_currentShell/_shellCount);

            //     float3 color = round(hash(seed * _Seed) + _Density) * step(lengthFromCenter,0.2);
            //     if(color.x <= 0) discard;

            //     color *= lerp(float4(0,0.02,0,1), _BaseColor, shellHeight);
                
            //     return float4(color,0);
            // }
