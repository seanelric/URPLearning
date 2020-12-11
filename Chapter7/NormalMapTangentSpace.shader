Shader "Unity Shader Book/Chapter 7/Normal Map In Tangent Space"
{
    Properties
    {
        _BaseColor ("Color Tint", Color) = (1, 1, 1, 1)
        _BaseMap ("Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1.0
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
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 lightTS : TEXCOORD1;
                float3 viewTS : TEXCOORD2;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            
            TEXTURE2D(_BumpMap);
            SAMPLER(sampler_BumpMap);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
                float4 _BumpMap_ST;
                float _BumpScale;
                half4 _Specular;
                float _Gloss;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                
                OUT.uv.xy = TRANSFORM_TEX(IN.uv, _BaseMap);
                OUT.uv.zw = TRANSFORM_TEX(IN.uv, _BumpMap);

                // Compute world to tangent
                half3 normalWS = TransformObjectToWorldNormal(IN.normalOS.xyz);
                half3 tangentWS = TransformObjectToWorldDir(IN.tangentOS.xyz);
                half3 binormalWS = cross(normalWS, tangentWS) * IN.tangentOS.w;

                // wToT = the inverse of tToW = the transpose of tToW as long as tToW is an orthogonal matrix.
                float3x3 worldToTangent = float3x3(tangentWS, binormalWS, normalWS);

                // Transform the light direction from object space to tangent space.
                Light mainLight = GetMainLight();
                OUT.lightTS = mul(worldToTangent, mainLight.direction);

                // Transform the view direction from object space to tangent space.
                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.viewTS = mul(worldToTangent, GetCameraPositionWS() - positionWS);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_TARGET
            {
                half3 lightTS = normalize(IN.lightTS);
                half3 viewTS = normalize(IN.viewTS);

                // Get the texel in the normal map
                half3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, IN.uv.zw));

                Light mainLight = GetMainLight();

                half3 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv.xy).rgb * _BaseColor.rgb;

                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                half3 diffuse = mainLight.color * albedo * saturate(dot(normalTS, lightTS));

                half3 halfDir = normalize(lightTS + viewTS);
                half3 specular = mainLight.color * _Specular.rgb * pow(saturate(dot(normalTS, halfDir)), _Gloss);

                return half4(ambient + diffuse + specular, 1.0);
            }
            ENDHLSL
        }
    }

    Fallback "Simple Lit"
}
