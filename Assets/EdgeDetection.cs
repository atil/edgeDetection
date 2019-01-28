using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class EdgeDetection : MonoBehaviour
{
    public Camera Camera;
    public Shader EdgeDetectionShader;

    private Material _edgeDetectionMaterial;

    private void Start()
    {
        Camera.depthTextureMode = DepthTextureMode.DepthNormals;
        _edgeDetectionMaterial = new Material(EdgeDetectionShader);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, _edgeDetectionMaterial);
    }
}
