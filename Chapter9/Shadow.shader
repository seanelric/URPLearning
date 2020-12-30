Shader "Unity Shader Book/Chapter 9/Shadow"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(9, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" }

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            // For receive shadows correctly from main light.
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            // For receive shadows correctly from additional light.
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                half3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                half3 normalWS : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half4 _Specular;
                float _Gloss;
            CBUFFER_END

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                // In World space
                half3 normalWS = normalize(IN.normalWS);
                half3 viewDirWS = normalize(GetCameraPositionWS() - IN.positionWS);

                /**
                 * Compute lighting
                 * Reference "UniversalFragmentBlinnPhong" function in Lighting.hlsl
                 */
                // Main light
                float4 shadowCoord = TransformWorldToShadowCoord(IN.positionWS);
                Light mainLight = GetMainLight(shadowCoord);
                half3 attenuatedLightColor = mainLight.color * mainLight.distanceAttenuation * mainLight.shadowAttenuation;
                half3 diffuse = LightingLambert(attenuatedLightColor, mainLight.direction, normalWS);
                half3 specular = LightingSpecular(attenuatedLightColor, mainLight.direction, normalWS, viewDirWS, _Specular, _Gloss);

                // Additional lights
                uint pixelLightCount = GetAdditionalLightsCount();
                for (uint i = 0u; i < pixelLightCount; ++i)
                {
                    Light light = GetAdditionalLight(i, IN.positionWS);
                    attenuatedLightColor = light.color * light.distanceAttenuation * light.shadowAttenuation;
                    diffuse += LightingLambert(attenuatedLightColor, light.direction, normalWS);
                    specular += LightingSpecular(attenuatedLightColor, light.direction, normalWS, viewDirWS, _Specular, _Gloss);
                }

                diffuse *= _BaseColor.rgb;

                return half4(diffuse + specular, 1.0);
            }
            ENDHLSL
        }

        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }

    FallBack "Simple Lit"
}
