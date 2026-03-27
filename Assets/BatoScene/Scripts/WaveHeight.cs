using UnityEngine;

public class WaveHeight : MonoBehaviour
{
    public static WaveHeight _instance;
    [SerializeField] Material seaMat;
    [SerializeField] bool modifiyValuesInRealTime;
    [SerializeField] float _WaveIntensity;
    [SerializeField] float _WaveSpeed;
    [SerializeField] float _WaveStrength;
    float currTime;

    void Awake()
    {
        if(_instance == null)
            _instance = this;
        else
            Destroy(this);
    }

    public float GetWaveHeight(float x)
    {
        float val = x * _WaveIntensity + currTime * _WaveSpeed;
        float height = Mathf.Sin(val) * _WaveStrength;

        return height;
    }

    void Update()
    {
        currTime += Time.deltaTime;

        if(modifiyValuesInRealTime)
            SetMaterialValues();

        seaMat.SetFloat("_ElapsedTime", currTime);
    }

    void SetMaterialValues()
    {
        seaMat.SetFloat("_Wave2Intensity", _WaveIntensity);
        seaMat.SetFloat("_Wave2Speed", _WaveSpeed);
        seaMat.SetFloat("_Wave2Strength", _WaveStrength * 0.01f);
    }
}
