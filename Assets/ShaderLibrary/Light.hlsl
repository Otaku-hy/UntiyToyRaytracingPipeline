#ifndef LIGHT
#define LIGHT

#include "SampleGenerator.hlsl"
#include "MathHelps.hlsl"
#include "ShadingData.hlsl"
#include "MathDefines.hlsl"

struct LightData
{
    int3 trianglesIdx;
    int primitiveIdx;
    float4 intensity;
};

struct TriangleLightHit
{
    float3 pos;
    float3 normal;

    uint primitiveIdx;
};

StructuredBuffer<LightData> lightCollections;
StructuredBuffer<float3> lightVertexPositions;
StructuredBuffer<float3> lightVertexNormals;
StructuredBuffer<float3x4> lightPrimitiveMatrixs;

cbuffer PointLight
{
    float3 posL;
};

struct LightSample
{
    float3 Li;
    float3 wi;
    float3 pos;

    float pdf;
};

uint GetLightCount()
{
    uint count,stride;
    lightCollections.GetDimensions(count,stride);
    return count;
}


bool SampleLight(ShadingData sd, inout SampleGenerator sg, out LightSample s)
{
    s.pdf = 1.0f;
    s.Li = 1.0f;

    uint count = GetLightCount();
    uint index = min(count * sampleNext1D(sg),count - 1);

    LightData data = lightCollections[index];
    float3 Le = data.intensity.x;

    float3 pos0 = lightVertexPositions[data.trianglesIdx.x].xyz;
    float3 pos1 = lightVertexPositions[data.trianglesIdx.y].xyz;
    float3 pos2 = lightVertexPositions[data.trianglesIdx.z].xyz;
    float3 normal0 = lightVertexNormals[data.trianglesIdx.x].xyz;
    float3 normal1 = lightVertexNormals[data.trianglesIdx.y].xyz;
    float3 normal2 = lightVertexNormals[data.trianglesIdx.z].xyz;
    
    float3x4 objToWorld = lightPrimitiveMatrixs[data.primitiveIdx];
    
    pos0 = mul(objToWorld,float4(pos0,1.0f)).xyz;
    pos1 = mul(objToWorld,float4(pos1,1.0f)).xyz;
    pos2 = mul(objToWorld,float4(pos2,1.0f)).xyz;

    float2 barycentrics = SampleUniformTriangle(sampleNext2D(sg));
    float area = length(cross((pos1 - pos0),(pos2-pos0))) * 0.5f;

    float3 sPos = (1 - barycentrics.x - barycentrics.y) * pos0 + barycentrics.x * pos1 + barycentrics.y * pos2; 
    float3 sNormal = (1 - barycentrics.x - barycentrics.y) * normal0 + barycentrics.x * normal1 + barycentrics.y * normal2; 
    //sPos = mul(objToWorld,float4(sPos,1.0f));
    sNormal = mul(objToWorld,float4(sNormal,0.0f));

    float3 dir = sPos - sd.posW;
    s.pos = sPos;
    s.wi = normalize(dir);

    float cosTheta = dot(sNormal,-s.wi);
    if(cosTheta <= 0.f) return false;

    float projArea = min(FLT_MAX,area * cosTheta);
    s.pdf = dot(dir,dir) / projArea;

    s.pdf *= 1.0f / count;
    
    s.Li = s.pdf > 0.f ? Le / s.pdf : float3(0,0,0);
    return true;
}

void PointLight(ShadingData sd, inout SampleGenerator sg, out LightSample s)
{
    float3 dir = normalize(posL - sd.posW);
    s.wi = dir;
    s.pos = posL;
    s.Li = 1.0;
}

float GetTriangleLightPdf(TriangleLightHit thit,float3 pos)
{
    uint count = GetLightCount();

    uint3 triangleIndices = UnityRayTracingFetchTriangleIndices(thit.primitiveIdx);
	Vertex v0,v1,v2;
	v0 = PrepareVertexData(triangleIndices.x);
	v1 = PrepareVertexData(triangleIndices.y);
	v2 = PrepareVertexData(triangleIndices.z);

    float3 pos0 = mul(ObjectToWorld3x4(),float4(v0.pos,1.0)).xyz; 
    float3 pos1 = mul(ObjectToWorld3x4(),float4(v1.pos,1.0)).xyz;
    float3 pos2 = mul(ObjectToWorld3x4(),float4(v2.pos,1.0)).xyz;

    float3 dir = thit.pos - pos;
    float3 wi = normalize(dir);

    float area = length(cross((pos1 - pos0),(pos2-pos0))) * 0.5f;

    float projArea = area * saturate(dot(-wi,thit.normal));
    
    float pdf = dot(dir,dir) / projArea;
    pdf *= 1.0f / count;

    return pdf;
}



#endif