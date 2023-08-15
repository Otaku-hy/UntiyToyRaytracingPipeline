using System.Numerics;
using Unity.Mathematics;

namespace CustomPipeline
{
    public struct LightData
    {
        public int3 trianglesIdx;
        public int primitiveIdx;
        public float4 intensity;
    }
}