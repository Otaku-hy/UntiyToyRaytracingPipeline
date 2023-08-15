using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Rendering;

namespace CustomPipeline
{
    struct Camera
    {
        public float fov;
        public float aspRatio;
        public float nearPlane;
        public float farPlane;

        public float3 cameraU;
        public float3 cameraV;
        public float3 cameraW;

        public float3 posW;

        public Camera(UnityEngine.Camera camera)
        {
            this.fov = camera.fieldOfView;
            this.aspRatio = camera.aspect;
            this.nearPlane = camera.nearClipPlane;
            this.farPlane = camera.farClipPlane;

            float4 utmp = camera.cameraToWorldMatrix.GetColumn(0);
            cameraU = utmp.xyz * Mathf.Tan(Mathf.Deg2Rad * fov * 0.5f) * aspRatio;
            float4 vtmp = camera.cameraToWorldMatrix.GetColumn(1);
            cameraV = vtmp.xyz * Mathf.Tan(Mathf.Deg2Rad * fov * 0.5f);
            float4 wtmp = -camera.cameraToWorldMatrix.GetColumn(2);
            cameraW = wtmp.xyz;

            posW = camera.transform.position;

        }
    
    }

}