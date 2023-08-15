#ifndef CAMERA
#define CAMERA

struct Camera
{
	float fov;
	float aspRatio;
	float nearPlane;
	float farPlane;

	float3 cameraU;
	float3 cameraV;
	float3 cameraW;

	float3 ComputePinholeCameraRay(float2 uv)
	{
		uv = uv * 2.0f - 1.0f;
		return uv.x * cameraU + uv.y * cameraV + 1.0f * cameraW;
	}
};

Camera gCamera;

#endif