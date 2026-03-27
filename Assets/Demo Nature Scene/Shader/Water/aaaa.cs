using UnityEngine;

[ExecuteInEditMode]
public class aaaa : MonoBehaviour
{
    void Start()
    {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }
}

