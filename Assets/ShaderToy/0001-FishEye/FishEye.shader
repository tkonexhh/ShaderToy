Shader "XHH/0001-FishEye"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" { }
        _Strength ("Strength", range(0, 3)) = 0.9
        _Radius ("Radius", range(0, 10)) = 3
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" }

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }
            
            Cull Back
            
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag


            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
            
            CBUFFER_START(UnityPerMaterial)
            float _Strength, _Radius;

            CBUFFER_END

            TEXTURE2D(_MainTex);SAMPLER(sampler_MainTex);float4 _MainTex_TexelSize;
            
            struct Attributes
            {
                float4 positionOS: POSITION;
                float2 uv: TEXCOORD0;
                float3 normalOS: NORMAL;
            };


            struct Varyings
            {
                float4 positionCS: SV_POSITION;
                float2 uv: TEXCOORD0;
                float3 normalWS: NORMAL;
            };


            
            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.uv = input.uv;


                return output;
            }


            half4 frag(Varyings input): SV_Target
            {
                float2 uv = input.uv;

                float ratio = float(float(_MainTex_TexelSize.z) / float(_MainTex_TexelSize.w));
                half2 scale = half2(1, 1);
                if (ratio < 1.)
                {
                    scale.x *= ratio;
                }
                else
                {
                    scale.y /= ratio;
                }

                
                half2 uv3 = uv;
                uv3 -= .5;
                uv3 *= scale;
                uv3 += .5;

                half2 center = half2(.5, .5);//中心点
                half2 d = uv3 - center;//距离中心点的偏移
                float r0 = sqrt(dot(center, center));//快速计算长度
                float r = sqrt(dot(d, d));
                // return r;

                float power = _Strength;//(2.0 * 3.141592 / (2.0 * r0)) * (_Strength - 0.5);
                // return power;
                float bind = lerp(r0, lerp(center.x, center.y, step(1., ratio)), step(power, 0.));
                // return bind;
                // return lerp(center.x, center.y, step(1., ratio));


                half2 uv2 = uv;

                if (power > 0.0)
                {
                    uv2 = center + lerp(normalize(d) * tan(r * power) * bind / tan(bind * power), d, smoothstep(0., _Radius, r)) * (1. / scale);
                }
                else if (power < 0.0)
                {
                    uv2 = center + lerp(normalize(d) * atan(r * - power * 10.0) * bind / atan(-power * bind * 10.0), d, smoothstep(0., _Radius, r)) * (1. / scale);
                }
                // return half4(uv2, 0, 1);
                half4 var_MainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv2);
                return var_MainTex;
            }
            
            ENDHLSL

        }
    }
    FallBack "Diffuse"
}