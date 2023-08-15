#ifndef RAY
#define RAY

#include "MathDefines.hlsl"

struct Ray
{
	float3 origin;
	float tMin;
	float3 dir;
	float tMax;

	void Init(float3 origin_,float3 dir_,float tMin_,float tMax_)
	{
		origin = origin_;
		dir = dir_;
		tMin = tMin_;
		tMax = tMax_;
	}

	void Init(float3 origin_,float3 dir_)
	{
		origin = origin_;
		dir = dir_;
		tMin = 0.0;
		tMax = FLT_MAX;
	}

	RayDesc toRayDesc()
	{
		RayDesc desc{};
		desc.Origin = origin;
		desc.TMin = tMin;
		desc.Direction = dir;
		desc.TMax = tMax;

		return desc;
	}
};

#endif