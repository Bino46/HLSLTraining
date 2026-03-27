using UnityEngine;
using UnityEngine.InputSystem;

public class Controller : MonoBehaviour
{
    FlyCam controller;
    [SerializeField] float walkSpeed;
    [SerializeField] float sprintSpeed;
    [SerializeField] float sensitivity;

    [Header("Shoot")]
    [SerializeField] bool canShoot;
    [SerializeField] GameObject prefab;
    [SerializeField] float shootPower;
    float speed;
    LayerMask shieldMask;
    Vector3 inputDirection;
    Vector3 moveDirection;
    Vector2 rotationDirection;

    void Awake()
    {
        controller = new FlyCam();

        controller.Noclip.Forward.performed += FlyForward;
        controller.Noclip.Forward.canceled += FlyForward;

        controller.Noclip.Side.performed += FlySide;
        controller.Noclip.Side.canceled += FlySide;

        controller.Noclip.UpDown.performed += FlyUpDown;
        controller.Noclip.UpDown.canceled += FlyUpDown;

        controller.Noclip.CamRotation.performed += CamRotation;

        controller.Noclip.Zoom.performed += Sprint;
        controller.Noclip.Zoom.canceled += Sprint;

        controller.Noclip.Pew.performed += RaycastPew;

        shieldMask = LayerMask.GetMask("Shield");
    }

    void OnEnable()
    {
        controller.Enable();

        Cursor.lockState= CursorLockMode.Locked;
        Cursor.visible = false;
    }

    void OnDisable()
    {
        controller.Disable();
    }

#region Movement
    void FlyForward(InputAction.CallbackContext ctx)
    {
        inputDirection.z = ctx.ReadValue<float>();
    }

    void FlySide(InputAction.CallbackContext ctx)
    {
        inputDirection.x = ctx.ReadValue<float>();
    }

    void FlyUpDown(InputAction.CallbackContext ctx)
    {
        inputDirection.y = ctx.ReadValue<float>();
    }
    
    void CamRotation(InputAction.CallbackContext ctx)
    {
        rotationDirection += ctx.ReadValue<Vector2>() * Time.deltaTime * sensitivity;
        transform.rotation = Quaternion.Euler(-rotationDirection.y, rotationDirection.x, 0);
    }

    void Sprint(InputAction.CallbackContext ctx)
    {
        float check = ctx.ReadValue<float>();

        if(check == 1)
            speed = sprintSpeed;
        else
            speed = walkSpeed;
    }
    #endregion

    void RaycastPew(InputAction.CallbackContext ctx)
    {
        // RaycastHit hit;
        // if(Physics.Raycast(transform.position, transform.forward,out hit, 1500, shieldMask))
        // {
        //     hit.transform.GetComponent<HitShield>().GetHit(hit.point);
        // }
        if(canShoot)
        {
            GameObject obj = Instantiate<GameObject>(prefab);
            obj.transform.position = transform.position;
            obj.transform.rotation = transform.rotation;

            obj.GetComponent<Rigidbody>().AddForce(transform.forward * shootPower, ForceMode.Impulse);
        }
    }
    
    void Update()
    {
        moveDirection = transform.forward * inputDirection.z + transform.right * inputDirection.x + transform.up * inputDirection.y;
        transform.position += moveDirection * Time.deltaTime * speed;
    }

}
