#ifndef PATH_PAYLOAD
#define PATH_PAYLOAD

#include "SampleGenerator.hlsl"
#include "Ray.hlsl"

struct PathPayload
{
	bool isTerminated;
	bool isShadowRay;
	bool isPrimaryHit;

	float3 direction;
	float3 originPos;
	float3 thp;

	float pdf;

	SampleGenerator sg;
	float3 outputcolor;
	uint pathLength;

	Ray GetNextRay()
	{
		Ray ray;
		ray.Init(originPos,direction);
		return ray;
	}
};

struct AttributeData
{
	float2 barycentrics;
};

#endif