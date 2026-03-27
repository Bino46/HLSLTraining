using UnityEngine;

public class AuroraManager : MonoBehaviour
{
    [Header("Base")]
    [SerializeField] Shader baseShader;
    [Header("Shells")]
    [SerializeField] Mesh mesh;
    [SerializeField] int ShellCount;
    [SerializeField] float _distanceBetweenShells;

    [Header("Aurora")]
    [SerializeField] float _Scale;
    [SerializeField] float _Speed;
    [SerializeField] float _Thickness;
    [SerializeField] float _BlurrThickness;
    [SerializeField] Color bottomColor;
    [SerializeField] Color topColor;
    [SerializeField] Vector2 colorIntensity;

    [Header("Noise wave")]
    [SerializeField] float _NoiseScale;
    [SerializeField] float _NoiseIntensity;
    [SerializeField] float _NoiseSpeed;
    [SerializeField] float _TopWaveAlphaNoise;
    private GameObject[] shellList;
    void OnEnable()
    {
        Material mat = new Material(baseShader);
        shellList = new GameObject[ShellCount];

        for (int i = 0; i < ShellCount; i++)
        {
            GameObject obj = new GameObject();
            obj.name = "Shell" + i;
            obj.transform.position = Vector3.zero;
            obj.transform.SetParent(transform, false);

            obj.AddComponent<MeshFilter>();
            obj.AddComponent<MeshRenderer>();

            obj.GetComponent<MeshFilter>().mesh = mesh;
            MeshRenderer meshRdr = obj.GetComponent<MeshRenderer>();

            meshRdr.material = mat;
            meshRdr.material.SetFloat("_currentShell", i);
            meshRdr.material.SetFloat("_shellCount", ShellCount);

            meshRdr.material.SetFloat("_Scale", _Scale);
            meshRdr.material.SetFloat("_Speed", _Speed);
            meshRdr.material.SetFloat("_Thickness", _Thickness);
            meshRdr.material.SetFloat("_BlurrThickness", _BlurrThickness);
            meshRdr.material.SetFloat("_distanceBetweenShells", _distanceBetweenShells);

            meshRdr.material.SetFloat("_TopWaveAlphaNoise", _TopWaveAlphaNoise);
            meshRdr.material.SetFloat("_NoiseIntensity", _NoiseIntensity);
            meshRdr.material.SetFloat("_NoiseSpeed", _NoiseSpeed);
            meshRdr.material.SetFloat("_NoiseScale", _NoiseScale);

            meshRdr.material.SetVector("_DownColor", bottomColor);
            meshRdr.material.SetFloat("_DownIntensity", colorIntensity.x);
            meshRdr.material.SetVector("_TopColor", topColor);
            meshRdr.material.SetFloat("_TopIntensity", colorIntensity.y);

            shellList[i] = obj;
        }
    }
    
    void Update()
    {
        for (int i = 0; i < ShellCount; ++i)
        {
            MeshRenderer meshRdr = shellList[i].GetComponent<MeshRenderer>();

            meshRdr.material.SetFloat("_Scale", _Scale);
            meshRdr.material.SetFloat("_Speed", _Speed);
            meshRdr.material.SetFloat("_Thickness", _Thickness);
            meshRdr.material.SetFloat("_BlurrThickness", _BlurrThickness);
            meshRdr.material.SetFloat("_distanceBetweenShells", _distanceBetweenShells);

            meshRdr.material.SetFloat("_TopWaveAlphaNoise", _TopWaveAlphaNoise);
            meshRdr.material.SetFloat("_NoiseIntensity", _NoiseIntensity);
            meshRdr.material.SetFloat("_NoiseSpeed", _NoiseSpeed);
            meshRdr.material.SetFloat("_NoiseScale", _NoiseScale);

            meshRdr.material.SetVector("_DownColor", bottomColor);
            meshRdr.material.SetFloat("_DownIntensity", colorIntensity.x);
            meshRdr.material.SetVector("_TopColor", topColor);
            meshRdr.material.SetFloat("_TopIntensity", colorIntensity.y);
        }
    }
}
