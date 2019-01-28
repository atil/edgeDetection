Shader "EdgeDetection/EdgeDetection"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define PI 3.14159265358979323846264338327
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float angleBetween(float3 a, float3 b)
			{
				return abs(acos(dot(a, b) / (length(a) * length(b)))) * 180 / PI;
			}

			sampler2D_float _CameraDepthNormalsTexture;
			float2 _CameraDepthNormalsTexture_TexelSize;
			sampler2D _MainTex;


			float4 frag (v2f i) : SV_Target
			{
				float dx = _CameraDepthNormalsTexture_TexelSize.x; // 1 / texturewidth
				float dy = _CameraDepthNormalsTexture_TexelSize.y; // 1 / textureheight

				float2 uv_topLeft = i.uv + float2(-dx, -dy);
				float2 uv_topRight = i.uv + float2(dx, -dy);
				float2 uv_mid = i.uv;
				float2 uv_botLeft = i.uv + float2(-dx, dy);
				float2 uv_botRight = i.uv + float2(dx, dy);

				float depth_topLeft;
				float depth_topRight;
				float depth_mid;
				float depth_botLeft;
				float depth_botRight;

				float3 normal_topLeft;
				float3 normal_topRight;
				float3 normal_mid;
				float3 normal_botLeft;
				float3 normal_botRight;

				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, uv_topLeft), depth_topLeft, normal_topLeft);
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, uv_topRight), depth_topRight, normal_topRight);
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, uv_mid), depth_mid, normal_mid);
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, uv_botLeft), depth_botLeft, normal_botLeft);
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, uv_botRight), depth_botRight, normal_botRight);

				float depthDiff = (depth_topLeft + depth_topRight + depth_botLeft + depth_botRight) / 4 - depth_mid;
				float angleDiff = max(angleBetween(normal_topLeft, normal_botRight), 
									  angleBetween(normal_topRight, normal_botLeft));

				float isEdge = 0;
				if (depthDiff > 0.001 || angleDiff > 10)
				{
					isEdge = 1;
				}

				float4 edgeColor = float4(1, 0, 0, 1);
				float4 sceneColor = tex2D(_MainTex, i.uv);

				return lerp(sceneColor, edgeColor, isEdge);
			}
			ENDCG
		}
	}
}
