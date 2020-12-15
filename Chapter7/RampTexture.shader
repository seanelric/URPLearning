Shader "Unity Shader Book/Chapter 7/Ramp Texture"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _RampMap ("Ramp Map", 2D) = "white" {}
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8, 256)) = 20
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" }

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                half3 normalOS : NORMAL;
                float4 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                half3 normalWS : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            TEXTURE2D(_RampMap);
            SAMPLER(sampler_RampMap);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _RampMap_ST;
                half4 _Specular;
                float _Gloss;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _RampMap);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_TARGET
            {
                half3 normalWS = normalize(IN.normalWS);
                Light mainLight = GetMainLight();

                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                half halfLambert = 0.5 * dot(normalWS, mainLight.direction) + 0.5;
                half3 rampColor = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, half2(halfLambert, halfLambert)).rgb;
                half3 diffuse = mainLight.color * _BaseColor.rgb * rampColor;

                half3 viewDir = normalize(GetCameraPositionWS() - IN.positionWS);
                half3 halfDir = normalize(viewDir + mainLight.direction);
                half3 specular = mainLight.color * _Specular.rgb * pow(saturate(dot(normalWS, halfDir)), _Gloss);

                return half4(ambient + diffuse + specular, 1);
            }
            ENDHLSL
        }
    }

    Fallback "Simple Lit"
}
