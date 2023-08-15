#ifndef SAMPLE_GENERATOR
#define SAMPLE_GENERATOR

#include "HashUtils.hlsl"
#include "RNG.hlsl"

struct SampleGenerator
{
	LCG rng;

	void Init(uint2 pixel,uint sampleNumber/* usually use frame count as the number*/)
	{
		uint seed = blockCipherTEA(interleave_32bit(pixel), sampleNumber).x;
		rng = CreateLCG(seed);
	}

	uint next()
	{
		return NextRandom(rng);
	}
	
};

float sampleNext1D(inout SampleGenerator sg)
{
	uint rand = sg.next();
	return (rand >> 8) *  5.96046448e-8;
}

float2 sampleNext2D(inout SampleGenerator sg)
{
	float2 sample;
	sample.x = sampleNext1D(sg);
	sample.y = sampleNext1D(sg);
	return sample;
}

float3 sampleNext3D(inout SampleGenerator sg)
{
	float3 sample;
	sample.x = sampleNext1D(sg);
	sample.y = sampleNext1D(sg);
	sample.z = sampleNext1D(sg);
	return sample;
}

float4 sampleNext4D(inout SampleGenerator sg)
{
	float4 sample;
	sample.x = sampleNext1D(sg);
	sample.y = sampleNext1D(sg);
	sample.z = sampleNext1D(sg);
	sample.w = sampleNext1D(sg);
	return sample;
}

#endif