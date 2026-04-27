using UnityEngine;

public class FloatObject : MonoBehaviour
{
    [Header("Buoys Parameters")]
    [SerializeField] float maxBoatTilt = 120;
    [SerializeField] int buoysCount = 6;
    [SerializeField] float buoysRadius = 3;
    [SerializeField] float buoyResistance = 3;
    float waveLift;
    private SingleBuoy[] buoysList;
    private Vector2[] relativeBuoyPosition;
    Vector2 tiltDirection;
    [SerializeField] GameObject tiltDebug;
    
    [Header("Object Buoyancy Parameters")]
    [SerializeField] float gravity = 9.81f;
    [SerializeField] float boatWeight = 5;
    [SerializeField] float depthOffset = -0.2f;
    [SerializeField] float archimedeModifier;
    [SerializeField] float hitWaterDrag;
    [SerializeField] Mesh mesh;

    [Header("Other/Debug")]
    float timeInAir;
    float currentDepth;
    float currGravityIntensity;
    float currHeightMovement;
    float objectVolume;
    float crossSection;
    bool canWobble;
    bool unlockYPos;
    bool needResurface;
    public enum FloatState{Floating, Falling, Submerged}
    public FloatState currentState;

    #region Setup
    void Start()
    {
        objectVolume = mesh.bounds.size.x * mesh.bounds.size.y * mesh.bounds.size.z;
        crossSection = mesh.bounds.size.x * mesh.bounds.size.z;
        GetBuoys();
    }
    
    public void GetBuoys() // Called once per Start or when in need to reset the buoys
    {
        GameObject[] temp = MakeBuoys._instance.CreateBuoys(transform, buoysCount, buoysRadius);

        buoysList = new SingleBuoy[buoysCount];

        relativeBuoyPosition = new Vector2[buoysCount];
        Vector2 relativePos;

        for(int i = 0; i < buoysCount; i++)
        {
            buoysList[i] = temp[i].GetComponent<SingleBuoy>();

            relativePos.x = temp[i].transform.localPosition.z;
            relativePos.y = temp[i].transform.localPosition.x;

            relativeBuoyPosition[i] = relativePos.normalized;
        }
    }

    #endregion

    #region Physics
    void ApplyPhysicsFromState()
    {
        HeightCheck();

        switch(currentState)
        {
            case FloatState.Falling:
                Fall();
                break;

            case FloatState.Submerged:
                FloatToSurface();
                break;
        }
    }
    public Vector2 GetBuoysValue()
    {
        for(int i = 0; i < buoysList.Length; i++)
        {
            tiltDirection -= relativeBuoyPosition[i] * buoysList[i].GetValue();
        }

        tiltDirection = Vector2.ClampMagnitude(tiltDirection, maxBoatTilt);

        tiltDebug.transform.localPosition = Vector3.forward * tiltDirection.x + Vector3.right * tiltDirection.y;

        return tiltDirection;
    }

    void Wobble()
    {
        Vector3 newPos = transform.position;
        newPos.y = waveLift;
        transform.position = newPos;

        TiltWithWaves(buoyResistance);
    }
    void TiltWithWaves(float resisance)
    {
        tiltDirection = GetBuoysValue() / resisance;
        transform.rotation = Quaternion.Euler(tiltDirection.x, transform.rotation.eulerAngles.y, -tiltDirection.y);
    }

    void Fall()
    {
        timeInAir += Time.deltaTime;
        currGravityIntensity -= gravity * boatWeight * timeInAir * Time.deltaTime;

        currHeightMovement = currGravityIntensity;  
    }

    void FloatToSurface()
    {   
        float waterDrag = 0.5f * Mathf.Pow(currHeightMovement, 2) * crossSection * hitWaterDrag;
        float archimede = objectVolume * gravity * archimedeModifier;

        if(waterDrag > archimede && !needResurface)
            currHeightMovement += waterDrag * Time.deltaTime;
        else
        {
            needResurface = true;
            currHeightMovement += archimede * Time.deltaTime;
        }

        TiltWithWaves(buoyResistance * Mathf.Abs(0.8f-currentDepth));
        currGravityIntensity = 0;
    } 

    #endregion

    #region State control
    void HeightCheck()
    {
        waveLift = WaveHeight._instance.GetWaveHeight(transform.position.x); 
        currentDepth = transform.position.y - waveLift;

        if(currentDepth < depthOffset) //Below water
        {
            SwitchState(FloatState.Submerged);
        }
        else if(currentDepth > -depthOffset) //Over water
        {
            SwitchState(FloatState.Falling);
        }
        else if(currentDepth > depthOffset && currentDepth < -depthOffset ) //On Water
        {
            SwitchState(FloatState.Floating);
        }
    }

    public void SwitchState(FloatState newState)
    {
        if(currentState != newState)
        {
            if(currentState == FloatState.Submerged && newState == FloatState.Floating)
            {
                canWobble = true;
                currHeightMovement = 0;
                timeInAir = 0;
                unlockYPos = false;
                needResurface = false;
            }
            else if(currentState == FloatState.Floating && newState == FloatState.Falling)
            {
                unlockYPos = true;
                canWobble = false;
            }
            else
                canWobble = false;
            
            currentState = newState;    
        }
    }

    public FloatState GetCurrentFloatingState()
    {
        return currentState;
    }

    #endregion

    void Update()
    {
        ApplyPhysicsFromState();

        if(canWobble && !unlockYPos)
            Wobble();

        transform.position += Vector3.up * currHeightMovement * Time.deltaTime;
    }
}
