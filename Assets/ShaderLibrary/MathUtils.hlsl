#ifndef MATH_UTILS
#define MATH_UTILS

float3 NextOrigin(float3 p,float3 n)
{
	const float origin = 1.f / 32.f;
    const float fScale = 1.f / 65536.f;
    const float iScale = 256.f;

    // Per-component integer offset to bit representation of fp32 position.
    int3 iOff = int3(n * iScale);
    float3 iPos = asfloat(asint(p) + (p < 0.f ? -iOff : iOff));

    // Select per-component between small fixed offset or above variable offset depending on distance to origin.
    float3 fOff = n * fScale;
    return abs(p) < origin ? p + fOff : iPos;
}

#endif