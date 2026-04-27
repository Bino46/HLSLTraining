using UnityEngine;

public class SingleBuoy : MonoBehaviour
{
    float waterHeight;

    void Update()
    {
        waterHeight = WaveHeight._instance.GetWaveHeight(transform.position.x) - transform.position.y;
    }

    public float GetValue()
    {
        return waterHeight;
    }
}
