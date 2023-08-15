Shader "Custom/TestShader"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "while" {}
        _Emissive ("Emission", float) = 0.0
    }
    SubShader
    {
    
       pass
       {
       Name "RayTracing"
       Tags {"LightMode"="RayTracing"}

       HLSLPROGRAM
 
       
       #pragma raytracing test

       #include "./ShaderLibrary/PathPayload.hlsl"
       #include "./ShaderLibrary/ShadingData.hlsl"
       #include "./ShaderLibrary/BSDF.hlsl"
       #include "./ShaderLibrary/RaytracingParams.hlsl"
       #include "./ShaderLibrary/RaytracingHelps.hlsl"
       #include "./ShaderLibrary/Light.hlsl"

       #include "UnityRaytracingMeshUtils.cginc"

       Texture2D<float4> _MainTex;
       SamplerState sampler_MainTex;
       float _Emissive;
       
       [shader("closesthit")]
       void ClosestHitShader(inout PathPayload pathState : SV_RayPayload, AttributeData attributeData : SV_IntersectionAttributes)
       {
            pathState.pathLength++;

            if(pathState.isShadowRay) return;
            
            float3 barycentrics = float3(1.0 - attributeData.barycentrics.x - attributeData.barycentrics.y, attributeData.barycentrics.x, attributeData.barycentrics.y);
            ShadingData sd = PrepareShadingData(PrimitiveIndex(),barycentrics,pathState.direction);
            sd.emission = _Emissive;
       
            if(any(sd.emission) > 0.0f)
            {
                TriangleLightHit thit;
                thit.primitiveIdx = PrimitiveIndex();
                thit.pos = sd.posW;
                thit.normal =sd.faceNormal;
               
                float pdf = GetTriangleLightPdf(thit,pathState.originPos);

                float weight = pathState.pdf / (pdf + pathState.pdf);
                if(pathState.isPrimaryHit)
                    weight = 1.0f;

                pathState.outputcolor += pathState.thp * sd.emission * weight; 
            }

            pathState.isTerminated = true;
            return;

       }

       ENDHLSL
       }
    }
}
