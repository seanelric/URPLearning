Shader "Unity Shader Book/Chapter 7/Mask Texture In World Space"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _BaseMap ("Base Map", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "white" {}
        _BumpScale ("Bump Scale", Float) = 1.0
        _SpecularMask ("Specular Mask", 2D) = "white" {}
        _SpecularScale ("Specular Scale", Float) = 1.0
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
                half4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 t2w0 : TEXCOORD1;
                float4 t2w1 : TEXCOORD2;
                float4 t2w2 : TEXCOORD3;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            TEXTURE2D(_BumpMap);
            SAMPLER(sampler_BumpMap);

            TEXTURE2D(_SpecularMask);
            SAMPLER(sampler_SpecularMask);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
                float4 _BumpMap_ST;
                float4 _SpecularMask_ST;
                float _BumpScale;
                float _SpecularScale;
                half4 _Specular;
                float _Gloss;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv.xy = TRANSFORM_TEX(IN.uv, _BaseMap);
                OUT.uv.zw = TRANSFORM_TEX(IN.uv, _BumpMap);

                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                half3 normalWS = TransformObjectToWorldNormal(IN.normalOS);
                half3 tangentWS = TransformObjectToWorldDir(IN.tangentOS.xyz);
                half3 binormalWS = cross(normalWS, tangentWS) * IN.tangentOS.w;

                OUT.t2w0 = float4(tangentWS.x, binormalWS.x, normalWS.x, positionWS.x);
                OUT.t2w1 = float4(tangentWS.y, binormalWS.y, normalWS.y, positionWS.y);
                OUT.t2w2 = float4(tangentWS.z, binormalWS.z, normalWS.z, positionWS.z);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_TARGET
            {
                float3 positionWS = float3(IN.t2w0.w, IN.t2w1.w, IN.t2w2.w);
                half3 viewWS = normalize(GetCameraPositionWS() - positionWS.xyz);
                Light mainLight = GetMainLight();

                half3 normal = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, IN.uv.zw));
                normal.xy *= _BumpScale;
                normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));
                normal = normalize(half3(dot(IN.t2w0.xyz, normal), dot(IN.t2w1.xyz, normal), dot(IN.t2w2.xyz, normal)));

                half3 albedo = _BaseColor.rgb * SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv.xy).rgb;

                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                half3 diffuse = mainLight.color * albedo * saturate(dot(normal, mainLight.direction));

                half3 halfDir = normalize(viewWS + mainLight.direction);
                half specularMask = SAMPLE_TEXTURE2D(_SpecularMask, sampler_SpecularMask, IN.uv.xy).r * _SpecularScale;
                half3 specular = mainLight.color * _Specular.rgb * pow(saturate(dot(normal, halfDir)), _Gloss) * specularMask;

                return half4(ambient + diffuse + specular, 1.0);
            }
            ENDHLSL
        }
    }

    Fallback "Simple Lit"
}
