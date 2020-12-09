Shader "Unity Shader Book/Chapter 7/Single Texture"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _BaseMap ("Base Map", 2D) = "white" {}
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityInput.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                half3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                half3 normalWS : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            /**
             * 纹理与采样器的分离定义:
             * 内置管线是和纹理设置绑定的，修改不灵活。
             * 分离后可以在 Shader 内部自由组合而不受外部设置的限制。
             */
            TEXTURE2D(_BaseMap);
            /**
             * 采样器的定义(纹理与采样器分离定义),采样器是指纹理的过滤模式与重复模式,此功能在OpenGL ES2.0上不支持，相当于没写.
             * 1.SAMPLER(sampler_textureName):sampler+纹理名称，这种定义形式是表示采用textureName这个纹理Inspector面板中的采样方式.
             * 2.SAMPLER(_filter_wrap):比如SAMPLER(point_clamp),使用自定义的采样器设置，自定义的采样器一定要同时包含过滤模式<filter>与重复模式<wrap>的设置.
             * 3.SAMPLER(_filter_wrapU_wrapV):比如SAMPLER(linear_clampU_mirrorV),可同时设置重复模式的U与V的不同值.
             * 4.filter:point/linear/triLinear
             * 5.wrap:clamp/repeat/mirror/mirrorOnce
             */
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _BaseColor;
                half4 _Specular;
                float _Gloss;
            CBUFFER_END

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normal);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                Light mainLight = GetMainLight();

                // Use texture to sample the diffuse color
                half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
                half3 albedo = texColor.rgb * _BaseColor.rgb;

                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                half3 diffuse = mainLight.color * albedo * saturate(dot(IN.normalWS, mainLight.direction));

                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - IN.positionWS);
                half3 halfDir = normalize(viewDir + mainLight.direction);
                half3 specular = mainLight.color * _Specular * pow(saturate(dot(IN.normalWS, halfDir)), _Gloss);

                return half4((ambient + diffuse + specular), 1.0);
            }
            ENDHLSL
        }
    }

    Fallback "Simple Lit"
}
