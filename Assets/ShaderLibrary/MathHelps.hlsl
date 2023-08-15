#ifndef MATH_HELP
#define MATH_HELP

float3 SampleUniformSphere(float2 random)
{
	float theta = acos(1 - 2 * random.x);
	float phi = 2 * PI_1 * random.y;

	float sinTheta = sin(theta);

	return float3(sinTheta * cos(phi), sinTheta * sin(phi), cos(theta));
}

float3 SampleUniformHemiSphere(float2 random)
{
	float theta = acos(1 - random.x);
	float phi = 2 * PI_1 * random.y;

	float sinTheta = sin(theta);

	return float3(sinTheta * cos(phi), sinTheta * sin(phi), cos(theta));
}

float3 SampleCosineHemiSphere(float2 random,out float pdf)
{
	float3 p;
	float phi = 2 * PI_1 * random.x;
	float r = sqrt(random.y);
	p.x = r * cos(phi);
	p.y = r * sin(phi);
	p.z = sqrt(1-random.y);
	pdf = p.z * PI_INV_1;
	return p;
}

float2 SampleUniformTriangle(float2 random)
{
	float2 barycentric;
	barycentric.x = 1 - sqrt(random.x);
	barycentric.y = (1-barycentric.x) * random.y;
	return barycentric;
}

#endif