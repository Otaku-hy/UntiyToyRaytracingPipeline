using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;

[CreateAssetMenu(menuName = "Rendering/Raytracing")]
public class RayTracingRenderPipelineAsset : RenderPipelineAsset
{
    // Start is called before the first frame update
    [SerializeField]
    public RayTracingShader shader;

    [SerializeField]
    public ComputeShader cs;

    [SerializeField]
    public bool shouldAcc;
    protected override RenderPipeline CreatePipeline()
    {
        return new CustomPipeline.RayTracingRenderPipeline(shader,cs,shouldAcc);
    }
}
