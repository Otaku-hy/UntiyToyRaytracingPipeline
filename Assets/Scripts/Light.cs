using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;

namespace CustomPipeline
{
    [ExecuteInEditMode]
    public class Light : MonoBehaviour
    {
        public static List<LightData> lightDatas = new List<LightData>();
        public static List<Vector3> poss = new List<Vector3>();
        public static List<Vector3> normals = new List<Vector3>();
        public static List<float3x4> matrixs = new List<float3x4>();  
        public static Vector3 pp = Vector3.zero;
        // Start is called before the first frame update
        private Mesh mesh;
        void Start()
        {
 
        }

        // Update is called once per frame
        void Update()
        {
            lightDatas.Clear();
            poss.Clear();
            normals.Clear();
            matrixs.Clear();

            mesh = GetComponent<MeshFilter>().sharedMesh;
            Vector3[] pos = mesh.vertices;
            Vector3[] normal = mesh.normals;

            float4x4 mat = GetComponent<Transform>().localToWorldMatrix;
            pp = mat.c3.xyz;
            float3x4 toWorld = new float3x4(mat.c0.xyz, mat.c1.xyz, mat.c2.xyz,mat.c3.xyz);
            poss.AddRange(pos);
            normals.AddRange(normal);
            matrixs.Add(toWorld);

            List<int> triangles = new List<int>();
            mesh.GetTriangles(triangles, 0);
            for (int i = 0; i < triangles.Count / 3; i++)
            {
                LightData data = new LightData();
                data.trianglesIdx = new int3(triangles[i], triangles[i + 1], triangles[i + 2]);
                data.primitiveIdx = 0;
                data.intensity = new float4(100, 0, 0, 0);
                lightDatas.Add(data);
            }
            //Debug.Log(triangles.Count);
        }
    }
}
