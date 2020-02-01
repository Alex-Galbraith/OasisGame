using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pickup : MonoBehaviour
{
    public AudioSource audioPlayer;
    public AudioClip pickupSound;

    private void OnTriggerEnter(Collider collision)
    {
        audioPlayer.PlayOneShot(pickupSound);
        if (collision.CompareTag("Player"))
        {
            Destroy(this.gameObject);
        }
        
    }
}
