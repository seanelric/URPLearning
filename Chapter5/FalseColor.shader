Shader "Unity Shader Book/Chapter 5/False Color"
{
    SubShader
    {
        Tags {"RenderPipeline" = "UniversalPipeline"}

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 color : Color;
                float4 texcoord : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
            };

            struct Varyings
            {
                float4 pos : SV_POSITION;
                half4 color : COLOR0;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.pos = TransformObjectToHClip(IN.vertex.xyz);

                // Visual normal direction
                OUT.color = half4(IN.normal * 0.5 + half3(0.5, 0.5, 0.5), 1.0);

                // Visual tangent direction
                // OUT.color = half4(IN.tangent * 0.5 + half3(0.5, 0.5, 0.5), 1.0);

                // Visual binormal direction
                // half3 binormal = cross(IN.normal, IN.tangent.xyz) * IN.tangent.w;
                // OUT.color = half4(binormal * 0.5 + half3(0.5, 0.5, 0.5), 1.0);

                // Visual first texture coordinate
                // OUT.color = half4(IN.texcoord.xy, 0.0, 1.0);
                
                // Visual second texture coordinate
                // OUT.color = half4(IN.texcoord1.xy, 0.0, 1.0);

                // Visual fractional part of first texture coordinate
                // OUT.color = frac(IN.texcoord);
                // if (any(saturate(IN.texcoord) - IN.texcoord))
                // {
                //     OUT.color.b = 0.5;
                // }
                // OUT.color.a = 1.0;

                // Visual fractional part of second texture coordinate
                // OUT.color = frac(IN.texcoord1);
                // if (any(saturate(IN.texcoord1) - IN.texcoord1))
                // {
                //     OUT.color.b = 0.5;
                // }
                // OUT.color.a = 1.0;

                // Visual vertex color
                // OUT.color = IN.color;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                return IN.color;
            }
            ENDHLSL
        }
    }
}