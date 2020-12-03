Shader "Unity Shader Book/Chapter 5/Simple"
{
	Properties
	{
		_BaseColor ("Base Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader
	{
		/**
		 * SubShader Tags define when and under which conditions
		 * a SubShader block or a pass is executed.
		 */
		Tags {"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}

		Pass
		{
			// The HLSL code block. Untiy SRP uses the HLSL language.
			HLSLPROGRAM
			// This line defines the name of the vertex shader.
			#pragma vertex vert
			// This line defines the name of the fragment shader.
			#pragma fragment frag

			/**
			 * The Core.hlsl file contains definitions of frequently used HLSL
			 * macros and functions, and also contains #include refrerences to other
			 * HLSL files (for example, Common.hlsl, SpaceTransforms.hlsl, etc.).
			 */
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			/**
			 * To make the Unity shader SRP Batcher compatible, declare all
			 * properties related to a Material in a single CBUFFER block with
			 * the name UnityPerMaterial.
			 */
			CBUFFER_START(UnityPerMaterial)
				// The following line declares the _BaseColor variable, so that you
				// can use it in the fragment shader.
				half4 _BaseColor;
			CBUFFER_END
			
			/**
			 * The structure definition defines which variables it contains.
			 * This example uses the Attributes structure as an input structure in
			 * the vertex shader.
			 */
			struct Attributes
			{
				// This variable contains the vertex positions in object space.
				float4 positionOS : POSITION;
			};

			struct Varyings
			{
				// The positions in this struct must have the SV_POSITION semantic.
				float4 positionHCS : SV_POSITION;
			};

			/**
			 * The vertex shader definition with properties defined in the Varyings
			 * structure. The type of the vert function must match the (struct)
			 * that it returns.
			 */
			Varyings vert(Attributes IN)
			{
				// Declaring the output object (OUT) with the Varyings struct.
				Varyings OUT;
				// The TransformObjectToHClip function transforms vertex positions
				// from object space to homogenous clip space.
				OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
				// Returning the output.
				return OUT;
			}

			/** The fragment shader definition */
			half4 frag() : SV_TARGET
			{
				return _BaseColor;
			}
			ENDHLSL
		}
	}
}
