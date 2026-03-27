using UnityEngine;
using UnityEngine.VFX;

public class HitShield : MonoBehaviour
{
    [SerializeField] Shader baseShader;
    Material mat;
    [Header("Impact Pulse")]
    [SerializeField] float impactSize;
    [SerializeField] float impactSpeed;
    [SerializeField] float impactRipple;
    [SerializeField] float flashTime;
    [SerializeField] float flashIntensity;
    Vector3 hitPoint;
    float impactRadius;
    float flash;
    float intensity = 1;

    [Header("VFX")]
    [SerializeField] VisualEffect hitVfx;

    void Start()
    {
        mat = transform.GetComponent<MeshRenderer>().material;
    }

    void Update()
    {  
        mat.SetFloat("_impactSize", impactSize);

        impactRadius += Time.deltaTime * impactSpeed;

        mat.SetFloat("_impactTime", impactRadius);
        mat.SetFloat("_ImpactRipple",impactRipple);

        flash -= Time.deltaTime;

        if(flash > 0)
        {
            intensity -= Time.deltaTime * flashTime; 
            intensity = Mathf.Clamp(intensity, 1, 10);
        }

        mat.SetFloat("_FresnelPulseIntensity", intensity);
    }

    public void GetHit(Vector3 hit)
    {
        hitPoint = hit;
        mat.SetVector("_hitPos",hitPoint );
        impactRadius = 0;

        hitVfx.enabled = true;
        hitVfx.SetVector3("HitPos", transform.InverseTransformPoint(hitPoint));
        hitVfx.Play();

        flash = 1;
        intensity = flashIntensity;
    }
}
