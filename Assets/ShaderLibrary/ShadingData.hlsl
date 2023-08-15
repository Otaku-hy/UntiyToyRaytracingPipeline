#ifndef SHADING_DATA
#define SHADING_DATA

#include "MathUtils.hlsl"

#include "UnityRaytracingMeshUtils.cginc"

struct ShadingData
{
	float3 posW;
	float3 faceNormal;
	float3 T;
	float3 B;
	float3 N;

	float3 wo;
	float3 emission;

	float2 uv;

	float3 NextRayOrigin(float3 wi)      /// use adapted algorithm
	{
		return NextOrigin(posW,dot(wi,faceNormal) >= 0 ? faceNormal : -faceNormal);
	}
};

float3 toLocal(ShadingData sd,float3 dir)
{
	return normalize(float3(dot(sd.T,dir),dot(sd.B,dir),dot(sd.N,dir)));
}

float3 toWorld(ShadingData sd,float3 dir)
{
	return normalize(dir.x * sd.T + dir.y * sd.B + dir.z * sd.N);
}

struct Vertex
{
	float3 pos;
	float3 normal;
	float3 tangent;
	float2 uv;
};

Vertex PrepareVertexData(uint vertexIdx)
{
	Vertex v;
	v.pos = UnityRayTracingFetchVertexAttribute3(vertexIdx,kVertexAttributePosition);
	v.normal = UnityRayTracingFetchVertexAttribute3(vertexIdx,kVertexAttributeNormal);
	v.tangent = UnityRayTracingFetchVertexAttribute3(vertexIdx,kVertexAttributeTangent);
	v.uv = UnityRayTracingFetchVertexAttribute2(vertexIdx,kVertexAttributeTexCoord0);
	return v;
}

ShadingData PrepareShadingData(uint primitiveIdx, float3 barycentrics, float3 wo)
{
	uint3 triangleIndices = UnityRayTracingFetchTriangleIndices(PrimitiveIndex());
	Vertex v0,v1,v2;
	v0 = PrepareVertexData(triangleIndices.x);
	v1 = PrepareVertexData(triangleIndices.y);
	v2 = PrepareVertexData(triangleIndices.z);

	ShadingData sd{};
	sd.posW = v0.pos * barycentrics.x + v1.pos * barycentrics.y+ v2.pos * barycentrics.z; 
	sd.faceNormal = v0.normal * barycentrics.x + v1.normal * barycentrics.y+ v2.normal * barycentrics.z; 
	sd.T = v0.tangent * barycentrics.x + v1.tangent * barycentrics.y+ v2.tangent * barycentrics.z; 
	sd.uv = v0.uv * barycentrics.x + v1.uv * barycentrics.y+ v2.uv * barycentrics.z; 
	float3x3 objectToWorld = (float3x3)ObjectToWorld3x4();
	sd.faceNormal = normalize(mul(objectToWorld,sd.faceNormal));
	sd.T = normalize(mul(objectToWorld,sd.T));
	sd.posW = mul(ObjectToWorld3x4(),float4(sd.posW,1.0)).xyz;

	sd.N = sd.faceNormal;
	sd.B = normalize(cross(sd.N,sd.T));

	sd.wo = -wo;

	return sd;
}

#endif