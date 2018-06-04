// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shader Book/Chapter 6/Diffuse Vertex-Level"
{
	Properties
	{
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
	}

	Subshader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Diffuse;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : Color;
			};

			v2f vert(a2v v)
			{
				v2f o;
				// Transform the vertex from object space to projection space
				o.pos = UnityObjectToClipPos(v.vertex);

				// Get ambient term
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// Transform the normal from object space to world space
				// Use Inverse transpose matrix of transform vertex
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				// Get the light direction in world space
				// 只适用于单一平行光源，其他类型或者多光源时得不到正确的结果
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				// Compute diffuse term
				// Unity内置_LightColor0访问该Pass处理的光源颜色和强度信息（必须设置正确的LightMode才能得到正确的值）
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

				o.color = ambient + diffuse;

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				return fixed4(i.color, 1.0);
			}

			ENDCG
		}
	}

	Fallback "Diffuse"
}
