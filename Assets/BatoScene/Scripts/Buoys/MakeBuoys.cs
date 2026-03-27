using System.Collections.Generic;
using UnityEngine;

public class MakeBuoys : MonoBehaviour
{
    public static MakeBuoys _instance;
    [SerializeField] GameObject buoysPrefab;

    void Awake()
    {
        //singleton so that any future floating object will be able to call this and stay lightweight

        if(_instance == null)
            _instance = this;
        else
            Destroy(this);
    }

    public GameObject[] CreateBuoys(Transform objTransform, int count, float radius)
    {
        GameObject[] buoysList = new GameObject[count];

        float step = 2 * Mathf.PI / count;

        for(int i = 0; i < count; i++)
        {
            GameObject newBuoy = Instantiate(buoysPrefab, objTransform);

            Vector2 circlePos;
            circlePos.x = Mathf.Cos(step * i) * radius;
            circlePos.y = Mathf.Sin(step * i) * radius;

            Vector3 newPos = objTransform.position + objTransform.forward * circlePos.x + objTransform.right * circlePos.y;
            newBuoy.transform.position = newPos;
            
            newBuoy.name = "Buoy" + i.ToString();
            buoysList[i] = newBuoy;
        }
        
        return buoysList;
    }
}
