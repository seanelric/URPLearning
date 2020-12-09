Shader "Unity Shader Book/Chapter 6/Specular Pixel-Level"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityInput.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                half3 normal : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                half3 normalWS : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
                half4 _Diffuse;
                half4 _Specular;
                float _Gloss;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                // Transform the vertex from object space to clip space.
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);

                // Transform the vertex from object space to world space.
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);

                // Transform the normal from object space to world space.
                OUT.normalWS = TransformObjectToWorldNormal(IN.normal);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // Get ambient term
                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                Light mainLight = GetMainLight();

                // Compute diffuse term
                half3 diffuse = mainLight.color * _Diffuse.rgb * saturate(dot(IN.normalWS, mainLight.direction));

                // Get the reflect direction in world space
                half3 reflectDir = normalize(reflect(-mainLight.direction, IN.normalWS));
                // Get the view direction in world space
                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - IN.positionWS);
                // Compute specular term
                half3 specular = mainLight.color * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

                return half4((ambient + diffuse + specular), 1.0);
            }
            ENDHLSL
        }
    }

    Fallback "Simple Lit"
}
