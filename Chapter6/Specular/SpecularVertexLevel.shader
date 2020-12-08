Shader "Unity Shader Book/Chapter 6/Specular Vertex-Level"
    {
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
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
                float3 normal : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                half3 color :COLOR;
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

                // Get ambient term
                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // Transform the normal from object space to world space.
                half3 normalWS = TransformObjectToWorldNormal(IN.normal);
                // Ge the light struct.
                Light mainLight = GetMainLight();

                // Compute diffuse term
                half3 diffuse = mainLight.color * _Diffuse * saturate(dot(normalWS, mainLight.direction));

                // Get the reflect direction in world space.
                half3 reflectDir = reflect(-mainLight.direction, normalWS);
                half3 cameraPositionWS = GetCameraPositionWS();
                // Get the view direction in world space.
                half3 viewDir = normalize(cameraPositionWS - TransformObjectToWorld(IN.positionOS.xyz).xyz);
                // Compute specular term
                half3 specular = mainLight.color * _Specular * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

                OUT.color = ambient + diffuse + specular;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                return half4(IN.color, 1);
            }

            ENDHLSL
        }
    }

    Fallback "Simple Lit"
}
