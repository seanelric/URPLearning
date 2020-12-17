Shader "Unity Shader Book/Chapter 8/Alpha Blend Both Sided"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _BaseMap ("Base Map", 2D) = "white" {}
        _AlphaScale ("Alpha Scale", Range(0, 1)) = 1
    }

    // Reuse for every Pass 
    HLSLINCLUDE
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

    struct Attributes
    {
        float4 positionOS : POSITION;
        half3 normalOS : NORMAL;
        float2 uv : TEXCOORD0;
    };

    struct Varyings
    {
        float4 positionHCS : SV_POSITION;
        half3 normalWS : TEXCOORD1;
        float2 uv : TEXCOORD2;
    };

    TEXTURE2D(_BaseMap);
    SAMPLER(sampler_BaseMap);

    CBUFFER_START(UnityPerMaterial)
        half4 _BaseColor;
        float4 _BaseMap_ST;
        half _AlphaScale;
    CBUFFER_END

    Varyings vert(Attributes IN)
    {
        Varyings OUT;
        OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
        OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
        OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
        return OUT;
    }

    half4 frag(Varyings IN) : SV_TARGET
    {
        half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);

        half3 normalWS = normalize(IN.normalWS);
        Light mainLight = GetMainLight();

        half3 albedo = _BaseColor.rgb * texColor.rgb;

        half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

        half3 diffuse = mainLight.color * albedo * saturate(dot(normalWS, mainLight.direction));

        return half4(ambient + diffuse, texColor.a * _AlphaScale);
    }
    ENDHLSL

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"	
        }

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        // Renders only back faces
        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            Cull Front

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDHLSL
        }

        // Renders only front faces
        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            Cull Back

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDHLSL
        }
    }

    Fallback "Simple Lit"
}
