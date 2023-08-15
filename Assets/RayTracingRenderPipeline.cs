using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using TMPro.EditorUtilities;
using Unity.Mathematics;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.SceneManagement;
using static UnityEditor.Experimental.GraphView.GraphView;
using static UnityEngine.GraphicsBuffer;

namespace CustomPipeline
{

    public class RayTracingRenderPipeline : RenderPipeline
    {
        // Start is called before the first frame update
        private uint frameCount = 1;
        private Dictionary<int, RayTracingAccelerationStructure> rayTracingAccelerationStructures = new Dictionary<int, RayTracingAccelerationStructure>();

        private RayTracingShader shader = Resources.Load<RayTracingShader>("");
        private ComputeShader cs;

        private bool shouldAcc;

        RenderTexture outputColor;
        RenderTexture accumulate;
        public RayTracingRenderPipeline(RayTracingShader shader,ComputeShader cs, bool shouldAcc) : base()
        {
            this.shader = shader;
            this.cs = cs;
            outputColor = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGBFloat);
            outputColor.enableRandomWrite = true;
            outputColor.Create();
            accumulate = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGBFloat);
            accumulate.enableRandomWrite = true;
            accumulate.Create();
            this.shouldAcc = shouldAcc;
            this.frameCount = 1;
        }

        protected override void Render(ScriptableRenderContext context, UnityEngine.Camera[] cameras)
        {

            var accelerationStructure = BuildAccelerationStructure();

            CommandBuffer cb = new CommandBuffer();

            cb.BuildRayTracingAccelerationStructure(accelerationStructure);
            context.ExecuteCommandBuffer(cb);
            cb.Clear();

            foreach (var camera in cameras)
            {
                CommandBuffer buffer = new CommandBuffer();

                CustomPipeline.Camera gCamera = new CustomPipeline.Camera(camera);

                ComputeBuffer lightDatas = new ComputeBuffer(CustomPipeline.Light.lightDatas.Count, 32);
                lightDatas.SetData(CustomPipeline.Light.lightDatas);

                ComputeBuffer poss = new ComputeBuffer(CustomPipeline.Light.poss.Count, 12);
                poss.SetData(CustomPipeline.Light.poss);

                ComputeBuffer normals = new ComputeBuffer(CustomPipeline.Light.normals.Count, 12);
                normals.SetData(CustomPipeline.Light.normals);

                ComputeBuffer matrixs = new ComputeBuffer(CustomPipeline.Light.matrixs.Count, 48);
                matrixs.SetData(CustomPipeline.Light.matrixs);

                buffer.SetRayTracingShaderPass(shader, "RayTracing");

                buffer.SetGlobalBuffer("lightCollections", lightDatas);
                buffer.SetGlobalBuffer("lightVertexPositions", poss);
                buffer.SetGlobalBuffer("lightVertexNormals", normals);
                buffer.SetGlobalBuffer("lightPrimitiveMatrixs", matrixs);
                buffer.SetGlobalVector("posL", CustomPipeline.Light.pp);
                //buffer.SetRayTracingBufferParam(shader, "lightCollections", lightDatas);
               // buffer.SetRayTracingBufferParam(shader, "lightVertexPositions", poss);
                //buffer.SetRayTracingBufferParam(shader, "lightVertexNormals", normals);
                //buffer.SetRayTracingBufferParam(shader, "lightPrimitiveMatrixs", matrixs);

                buffer.SetRayTracingVectorParam(shader, "cameraU", new Vector4(gCamera.cameraU.x, gCamera.cameraU.y, gCamera.cameraU.z, 0.0f));
                buffer.SetRayTracingVectorParam(shader, "cameraV", new Vector4(gCamera.cameraV.x, gCamera.cameraV.y, gCamera.cameraV.z, 0.0f));
                buffer.SetRayTracingVectorParam(shader, "cameraW", new Vector4(gCamera.cameraW.x, gCamera.cameraW.y, gCamera.cameraW.z, 0.0f));
                buffer.SetRayTracingVectorParam(shader, "posW", new Vector4(gCamera.posW.x, gCamera.posW.y, gCamera.posW.z, 0.0f));
                buffer.SetRayTracingMatrixParam(shader, "cameraToWorld", camera.cameraToWorldMatrix);
                buffer.SetRayTracingIntParam(shader, "frameCount", (int)frameCount);
       
                buffer.SetRayTracingAccelerationStructure(shader, "AccelerationStructure", accelerationStructure);
                buffer.SetRayTracingTextureParam(shader, "RenderTarget", outputColor);
                buffer.DispatchRays(shader, "RayGen", (uint)outputColor.width, (uint)outputColor.height, 1, camera);

                buffer.SetComputeTextureParam(cs, cs.FindKernel("CSMain"), "accumulate", accumulate);
                buffer.SetComputeTextureParam(cs, cs.FindKernel("CSMain"), "current", outputColor);
                buffer.SetComputeIntParam(cs, "frameCount", (int)frameCount);
                if (shouldAcc)
                    cs.EnableKeyword("ACCUMULATE");
                else
                    cs.DisableKeyword("ACCUMULATE");

                buffer.DispatchCompute(cs, cs.FindKernel("CSMain"), outputColor.width / 8, outputColor.height/8, 1);

                buffer.Blit(accumulate, BuiltinRenderTextureType.CameraTarget);

                context.ExecuteCommandBuffer(buffer);
                context.Submit();

                lightDatas.Release();
                poss.Release();
                normals.Release();
                matrixs.Release();

            }

           // Debug.Log(One of C# data stride (12 bytes) and Buffer stride (32 bytes) should be multiple of other.);

            frameCount++;
         
        }

        private RayTracingAccelerationStructure BuildAccelerationStructure(int layer = -1)
        {
            if (rayTracingAccelerationStructures.ContainsKey(layer))
                return rayTracingAccelerationStructures[layer];

            RayTracingAccelerationStructure.RASSettings settings = new RayTracingAccelerationStructure.RASSettings(
                                                                            RayTracingAccelerationStructure.ManagementMode.Automatic,
                                                                            RayTracingAccelerationStructure.RayTracingModeMask.Everything,
                                                                            layer);
            var rayTracingAccelerationStructure = new RayTracingAccelerationStructure(settings);
            rayTracingAccelerationStructure.Build();
            rayTracingAccelerationStructures[layer] = rayTracingAccelerationStructure;

            return rayTracingAccelerationStructure;
        }
    }
}
