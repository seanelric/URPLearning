Shader "Unity Shader Book/Chapter 5/Simple Shader"
{
	Properties
	{
		// 声明一个Color类型的属性
		_Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader
	{
		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			// 在CG代码中，我们需要定义一个与属性名称和类型都匹配的变量
			fixed4 _Color;

			// Vertex shader inputs
			struct a2v
			{
				// ‘POSITION’ tells Unity, use vertex position of object space to fill 'vertex'
				float3 vertex : POSITION;
				// NORMAL tells Unity, use normal direction of object space to fill 'normal'
				float3 normal : NORMAL;
				// first texture coordinate
				float2 uv0 : TEXCOORD0;
			};

			// vertex shader outputs ("vertex to fragment")
			struct v2f
			{
				// 'SV_POSITION' tells Unity, vertex is positionfof clip space
				float4 vertex : SV_POSITION;
				// Use to save information of color
				fixed3 color : COLOR0;
			};

			v2f vert(a2v v)
			{
				v2f o;
				// transform position to clip space
				o.vertex = UnityObjectToClipPos(v.vertex);
				// Mapping weight from normal[-1.0, 1.0] to color[0, 1.0]
				o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 c = i.color;
				// 使用Color属性控制颜色输出
				c *= _Color.rgb;

				return fixed4(c, 1.0);
			}
			ENDHLSL
		}
	}
}
