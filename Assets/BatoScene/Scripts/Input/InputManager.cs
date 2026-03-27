using UnityEngine;
using UnityEngine.InputSystem;

public class InputManager : MonoBehaviour
{
    [Header("Scripts")]
    PlayerInputMap playerInputs;
    BoatController boatInputs;
    BoatCamera boatCamera;

    [Header("Parameters")]
    [SerializeField] ControllerState state;
    public enum ControllerState {LandControl, SeaControl}

    void OnEnable()
    {
        playerInputs.Enable();
    }

    void OnDisable()
    {
        playerInputs.Disable();
    }

    private void Awake() 
    {
        //Setup Scripts, should be called only once per scene load so its fine
        playerInputs = new PlayerInputMap();

        boatInputs = GameObject.Find("Boat").GetComponent<BoatController>();
        boatCamera = GameObject.Find("CameraController").GetComponent<BoatCamera>();
    }
    
    void Start()
    {   
        InitSeaControls();
        SwitchControl(state);

        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    #region Init Maps

    void InitSeaControls()
    {
        playerInputs.BoatMap.Move.performed += boatInputs.InputMovement;
        playerInputs.BoatMap.Move.canceled += boatInputs.InputMovement;

        playerInputs.BoatMap.Rotate.performed += boatInputs.InputRotation;
        playerInputs.BoatMap.Rotate.canceled += boatInputs.InputRotation;

        playerInputs.BoatMap.Jump.performed += boatInputs.InputJump;

        playerInputs.CameraMap.CameraRotation.performed += boatCamera.GetCameraInput;
    }

    #endregion

    #region Set Active Map
    public void SwitchControl(ControllerState newState)
    {
        ResetControls();

        if(newState == ControllerState.LandControl)
            SetLandControl();
        else
            SetSeaControl();
    }

    void SetSeaControl()
    {
        playerInputs.BoatMap.Enable();
    }

    void SetLandControl()
    {
        // Fill later
    }
    #endregion 

    void ResetControls()
    {
        playerInputs.BoatMap.Disable();

        //playerInputs.LandMap.Disable
    }

}
