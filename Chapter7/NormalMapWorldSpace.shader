Shader "Unity Shader Book/Chapter 7/Normal Map In World Space"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _BaseMap ("Base Map", 2D) = "white" {}
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
                half3 normalOS : NORMAL;
                half4 tangentOS : TANGENT;
                float4 uv : TEXCOORD0;
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

                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                half3 normalWS = TransformObjectToWorldNormal(IN.normalOS);
                half3 tangentWS = TransformObjectToWorldDir(IN.tangentOS.xyz);
                half3 binormalWS = cross(normalWS, tangentWS) * IN.tangentOS.w;

                // Compute the matrix that transform directions from tangent space to world space
                // Put the world position in w component for optimization
                OUT.t2w0 = float4(tangentWS.x, binormalWS.x, normalWS.x, positionWS.x);
                OUT.t2w1 = float4(tangentWS.y, binormalWS.y, normalWS.y, positionWS.y);
                OUT.t2w2 = float4(tangentWS.z, binormalWS.z, normalWS.z, positionWS.z);

                return OUT;
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                // Get the position in world space
                float3 positionWS = float3(i.t2w0.w, i.t2w1.w, i.t2w2.w);

                // Compute the light and view direction in world space
                Light mainLight = GetMainLight();
                float3 viewdir = normalize(GetCameraPositionWS() - positionWS);

                // Get the normal in tangent space
                half3 normal = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, i.uv.zw));
                // Transform the normal from tangent space to world space
                // 因为变换矩阵是正交矩阵，可以使用变换顶点的矩阵来变换法线
                normal = normalize(half3(dot(i.t2w0.xyz, normal), dot(i.t2w1.xyz, normal), dot(i.t2w2.xyz, normal)));

                // Compute final color
                half3 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv.xy).rgb * _BaseColor.rgb;

                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                half3 diffuse = mainLight.color * albedo * saturate(dot(normal, mainLight.direction));

                half3 halfDir = normalize(viewdir + mainLight.direction);
                half3 specular = mainLight.color * _Specular.rgb * pow(saturate(dot(normal, halfDir)), _Gloss);

                return half4(ambient + diffuse + specular, 1.0);
            }
            ENDHLSL
        }
    }

    Fallback "Simple Lit"
}
