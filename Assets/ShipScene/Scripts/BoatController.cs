using UnityEngine;
using UnityEngine.InputSystem;

public class BoatController : MonoBehaviour
{
    FloatObject floatObject;
    [Header("Boat Movement Parameters")]
    [SerializeField] float maxSpeed = 15;
    [SerializeField] [Range(0,1)] float accelerationRate = 0.1f;
    [SerializeField] [Range(0,1)] float backModifier = 0.65f;
    [SerializeField] [Range(0,0.5f)] float stopDrag = 0.08f;
    [SerializeField] float jumpStrength = 30;
    
    [Header("Boat Rotation Parameters")]
    [SerializeField] float maxTurnSpeed = 60;
    [SerializeField] [Range(0,0.5f)] float turnRate = 0.2f;
    [SerializeField] [Range(0,0.75f)] float movingTurnRate = 0.35f;
    [SerializeField] [Range(0,0.5f)] float rotationStopDrag = 0.042f;

    [Header("Other/Debug values")]
    float currSpeed;
    float currJumpTime;
    float currJumpStrength;
    Vector3 rotationVector;
    bool isRotating;
    bool isMoving;
    bool isJumping;
    Vector2 playerInputsDirection;

    #region Input
    public void InputMovement(InputAction.CallbackContext ctx)
    {
        float val = ctx.ReadValue<float>();

        if(val == 0)
            isMoving = false;
        else
            isMoving = true;

        playerInputsDirection.x = val;
    }

    public void InputRotation(InputAction.CallbackContext ctx)
    {
        float val = ctx.ReadValue<float>();

        if(val == 0)
            isRotating = false;
        else
            isRotating = true;

        playerInputsDirection.y = val;
    }

    public void InputJump(InputAction.CallbackContext ctx)
    {
        if(floatObject.GetCurrentFloatingState() == FloatObject.FloatState.Floating)
        {
            floatObject.SwitchState(FloatObject.FloatState.Falling);
            isJumping = true; 

            currJumpStrength = jumpStrength; 
            currJumpTime = 1;  
        }
    }

    #endregion

    #region Movement

    void ApplyInputMovement()
    {
        float speedModifier = 1;

        if(playerInputsDirection.x < 0)
            speedModifier = backModifier; //if we're moving backward, boat will be slower for whatever reason

        currSpeed += playerInputsDirection.x * accelerationRate * speedModifier;
        currSpeed = Mathf.Clamp(currSpeed, -maxSpeed * speedModifier, maxSpeed);
    }
    
    void ApplyInputRotation()
    {
        float dynamicTurnRate = Mathf.Lerp(turnRate, movingTurnRate, currSpeed / maxSpeed);
        rotationVector += Vector3.up * playerInputsDirection.y * dynamicTurnRate;

        rotationVector.y = Mathf.Clamp(rotationVector.y, -maxTurnSpeed, maxTurnSpeed);
    }

    void ApplyJump()
    {
        currJumpTime -= Time.deltaTime;
        currJumpStrength = Mathf.Lerp(0, jumpStrength, currJumpTime);

        if(currJumpTime <= 0)
            isJumping = false;
    }

    void ApplyTransform()
    {
        transform.position += (transform.forward * currSpeed + Vector3.up * currJumpStrength) * Time.deltaTime;
        transform.rotation *= Quaternion.Euler(rotationVector * Time.deltaTime);
    }

    void ApplyMovementDrag()
    {
        if(currSpeed < 0.02f && currSpeed > -0.02f)
            currSpeed = 0;
        else 
            currSpeed += -Mathf.Sign(currSpeed) * stopDrag;
    }

    void ApplyRotationDrag()
    {
        if(rotationVector.y < 0.02f && rotationVector.y > -0.02f)
            rotationVector.y = 0;
        else
            rotationVector.y += -Mathf.Sign(rotationVector.y) * rotationStopDrag;
    }

    #endregion

    void Start()
    {
        floatObject = GetComponent<FloatObject>();
    }

    void Update()
    {
        if(isMoving)
            ApplyInputMovement();
        else
            ApplyMovementDrag();
        
        if(isRotating)
            ApplyInputRotation();
        else
            ApplyRotationDrag();

        if(isJumping)
            ApplyJump();

        ApplyTransform();
    }
}
