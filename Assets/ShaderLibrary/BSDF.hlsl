#ifndef BSDF
#define BSDF

#include "ShadingData.hlsl"
#include "MathDefines.hlsl"
#include "MathHelps.hlsl"
#include "SampleGenerator.hlsl"

#define kCosThreshold 0.005

struct BSDFSample
{
	float3 wi;
	float pdf;
	float3 thp;
};

struct LambertianDiffuse
{
	float3 albedo;

	void Init(float3 albedo)
	{
		this.albedo = albedo;
	}

	bool sample(ShadingData sd, inout SampleGenerator sg, out BSDFSample s)
	{
		float pdf;

		float3 lo = toLocal(sd,sd.wo);
		float3 li = SampleCosineHemiSphere(sampleNext2D(sg),pdf);
		if(lo.z < kCosThreshold || li.z < kCosThreshold)
			return false;

		s.pdf = pdf;
		s.thp = albedo;
		s.wi = toWorld(sd,li);

		return true;
	}

	float3 eval(ShadingData sd, float3 wi)
	{
		float3 lo = toLocal(sd,sd.wo);
		float3 li = toLocal(sd,wi);
		if(lo.z < kCosThreshold || li.z < kCosThreshold)
			return 0;
		return albedo * PI_INV_1 * li.z;
	}

	float evalPdf(ShadingData sd, float3 wi)
	{
		float3 lo = toLocal(sd,sd.wo);
		float3 li = toLocal(sd,wi);
		if(lo.z < kCosThreshold || li.z < kCosThreshold)
			return 0;
		return PI_INV_1 * li.z;
	}

};



#endif