using System;
using UnityEngine;

public class GrassScript : MonoBehaviour
{
    [SerializeField] Mesh mesh;
    [SerializeField] Shader s_grass;
    public bool updateStatics;
    public int _ShellCount;
    private GameObject[] shellList;
    [Header("Material")]
    public Color _Color;
    public float _Seed;
    public float _Scale;
    [Range(-0.5f, 0.5f)] public float _Density;
    public float _SpaceBetweenShells;
    public float _heightAttenuation;
    public float _maxLength;
    public float _thickness;
    public float _minThickness;
    public float _MaxHeight;
    [Header("Wind")]
    public Texture _windNoise;
    public float _windAmount;
    public float _windStrength;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void OnEnable()
    {
        Material mat = new Material(s_grass);
        shellList = new GameObject[_ShellCount];

        for (int i = 0; i < _ShellCount; i++)
        {
            shellList[i] = new GameObject("Shell " + i.ToString());

            shellList[i].AddComponent<MeshFilter>();
            shellList[i].AddComponent<MeshRenderer>();

            shellList[i].GetComponent<MeshFilter>().mesh = mesh;
            shellList[i].GetComponent<MeshRenderer>().material = mat;

            shellList[i].transform.SetParent(transform, false);
            shellList[i].transform.position = transform.position;

            shellList[i].GetComponent<MeshRenderer>().material.SetVector("_BaseColor", _Color);
            shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_Seed", _Seed);
            shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_Scale", _Scale);
            shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_Density", _Density);

            shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_spaceBetweenShells", _SpaceBetweenShells);
            shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_currentShell", i);
            shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_shellCount", _ShellCount);
            shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_thickness", _thickness);
            shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_minThickness", _minThickness);
            shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_maxHeight", _MaxHeight);

            shellList[i].GetComponent<MeshRenderer>().material.SetTexture("_WindNoise", _windNoise);
            shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_windAmount", _windAmount);
            shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_windStrength", _windStrength);
        }
    }

    void Update()
    {
        if (updateStatics)
        {
            for (int i = 0; i < _ShellCount; ++i)
            {
                shellList[i].GetComponent<MeshRenderer>().material.SetVector("_BaseColor", _Color);
                shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_Seed", _Seed);
                shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_Scale", _Scale);
                shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_Density", _Density);

                shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_spaceBetweenShells", _SpaceBetweenShells);
                shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_currentShell", i);
                shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_shellCount", _ShellCount);
                shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_thickness", _thickness);
                shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_minThickness", _minThickness);
                shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_maxHeight", _MaxHeight);

                shellList[i].GetComponent<MeshRenderer>().material.SetTexture("_WindNoise", _windNoise);
                shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_windAmount", _windAmount);
                shellList[i].GetComponent<MeshRenderer>().material.SetFloat("_windStrenght", _windStrength);
            }
        }
    }
}
