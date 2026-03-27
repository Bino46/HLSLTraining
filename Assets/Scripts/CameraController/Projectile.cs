using System.Collections.Generic;
using UnityEngine;

public class Projectile : MonoBehaviour
{
    void OnCollisionEnter(Collision collision)
    {
        if(collision.gameObject.layer == 7)
        {
            collision.gameObject.GetComponent<HitShield>().GetHit(collision.GetContact(0).point);
            Destroy(gameObject);
        }
    }
}
