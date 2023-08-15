#ifndef RT_HELPS
#define RT_HELPS

#include "Ray.hlsl"
#include "PathPayload.hlsl"
#include "RaytracingParams.hlsl"

bool TraceVisibilityRay(float3 origin,float3 dest)
{
	Ray ray;
	ray.origin = origin;
	
	ray.dir = normalize(dest - origin);
	
	float dis = length(dest - origin);
	ray.tMin = 0;
	ray.tMax = 0.999 * dis;
	PathPayload pathState;
	pathState.pathLength = 0;
	pathState.isShadowRay = true;
	TraceRay(AccelerationStructure, RAY_FLAG_ACCEPT_FIRST_HIT_AND_END_SEARCH, 0xFF,0,1,0,ray.toRayDesc(),pathState);

	if(pathState.pathLength == 0) return true;
	else return false;
}


#endif