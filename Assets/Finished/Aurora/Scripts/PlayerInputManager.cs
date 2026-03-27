using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerInputManager : MonoBehaviour
{
    [Header("Scripts")]
    PlayerActions inputs;
    ControllerV2 playerController;
    public enum ControllerType{Magic, RPG}
    [SerializeField] ControllerType controllerType;

    [Header("Magic controller")]
    [SerializeField] GameObject playerUi;

    [Header("Hidden variables")]
    bool switchMain;

    void Awake()
    {
        inputs = new PlayerActions();
    }

    void OnEnable()
    {
        inputs.Enable();
    }

    void OnDisable()
    {
        inputs.Disable();
    }
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        playerController = GetComponent<ControllerV2>();
    
        inputs.Movement.Forward.performed += playerController.MovePlayerForward;
        inputs.Movement.Forward.canceled += playerController.MovePlayerForward;
        inputs.Movement.Right.performed += playerController.MovePlayerSide;
        inputs.Movement.Right.canceled += playerController.MovePlayerSide;

        inputs.Movement.View.performed += playerController.MoveCamera;


        inputs.Movement.Sprint.performed += playerController.Sprint;
        inputs.Movement.Sprint.canceled += playerController.Sprint;

        inputs.Movement.Jump.performed += playerController.Jump;

        SetupSpecifics();
    }

    void SetupSpecifics()
    {
        switch (controllerType)
        {
            case ControllerType.RPG:
                SetupRPG();
                break;
        }
    }

    void SetupRPG()
    {

    }
}
