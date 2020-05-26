Shader "Unity Shaders Book/Chapter 7/Mask Texture"
{
    Properties
    {
       _Color ("Color Tint", Color) = (1, 1, 1, 1)
       _MainTex ("Main Tex", 2D) = "white" {}
       _BumpTex ("Normal Map", 2D) =  "bump" {}
       _BumpScale ("Bump Scale", Float) = 1.0
       _SpecularMask ("Specular Mask", 2D) =  "white" {}
       _SpecularScale ("Specular Scale", Float) = 1.0
       _Specular ("Specular", Color) = (1, 1, 1, 1)
       _Gloss ("Gloss", Range(8, 256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpTex;
            float _BumpScale;
            sampler2D _SpecularMask;
            float _SpecularScale;
            fixed4 _Specular;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 t2w0 : TEXCOORD1;
                float4 t2w1 : TEXCOORD2;
                float4 t2w2 : TEXCOORD3;
            };


            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                o.t2w0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.t2w1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.t2w2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                float3 worldPos = float3(i.t2w0.w, i.t2w1.w, i.t2w2.w);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed3 bump = UnpackNormal(tex2D(_BumpTex, i.uv));
                bump.xy *= _BumpScale;
                bump.z = sqrt(1 - saturate(dot(bump.xy, bump.xy)));
                bump = normalize(half3(dot(i.t2w0.xyz, bump), dot(i.t2w1.xyz, bump), dot(i.t2w2.xyz, bump)));

                fixed3 albedo = tex2D(_MainTex, i.uv) * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(bump, lightDir));

                fixed3 halfDir = normalize(viewDir + lightDir);
                fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(bump, halfDir)), _Gloss) * specularMask;

                return fixed4(ambient + diffuse + specular, 1.0);
            }

            ENDCG
        }
    }

    Fallback "Specular"
}
