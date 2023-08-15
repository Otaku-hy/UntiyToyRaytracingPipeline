#ifndef RANDOM_NUMBER_GENERATOR
#define RANDOM_NUMBER_GENERATOR

struct LCG
{
	uint state;
};

LCG CreateLCG(uint s0)
{
	LCG rng;
	rng.state = s0;
	return rng;
}

uint NextRandom(inout LCG rng)
{
	const uint A = 1664525u;
    const uint C = 1013904223u;
	rng.state = A * rng.state + C;
	return rng.state;
}

#endif