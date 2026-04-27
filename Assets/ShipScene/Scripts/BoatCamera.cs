using UnityEngine;
using UnityEngine.InputSystem;

public class BoatCamera : MonoBehaviour
{
    [SerializeField] GameObject objectToFollow;

    [Header("Base Parameters")]
    [SerializeField] float sensitivity;
    [SerializeField] Vector2 maxCamAngle;
    Vector3 viewRotation;

    [Header("Y Damping Parameters")]
    [SerializeField] float minSpeed;
    Vector3 newPos;
    float timer;
    float distMult;
    float objectHeight;
    float height;

    public void GetCameraInput(InputAction.CallbackContext ctx)
    {
        viewRotation.y += ctx.ReadValue<Vector2>().x * sensitivity * Time.deltaTime;
        viewRotation.x += -ctx.ReadValue<Vector2>().y * sensitivity * Time.deltaTime;

        viewRotation.x = Mathf.Clamp(viewRotation.x, maxCamAngle.x, maxCamAngle.y);
        viewRotation.z = 0;

        transform.eulerAngles = viewRotation;
    }

    void Update()
    {
        if(newPos != objectToFollow.transform.position)
        {
            newPos.x = objectToFollow.transform.position.x;
            newPos.z = objectToFollow.transform.position.z;

            objectHeight = objectToFollow.transform.position.y;

            if (objectHeight != transform.position.y)
                timer = 0;

            UpdateHeight();

            transform.position = newPos;
        }
    }

    void UpdateHeight()
    {
        height = transform.position.y;
        
        distMult = Mathf.Abs(objectHeight - height);
        distMult = Mathf.Clamp(distMult, minSpeed, 100);

        timer += Time.deltaTime * distMult;

        newPos.y = Mathf.Lerp(height, objectHeight, timer);
    }
}
