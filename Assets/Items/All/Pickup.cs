using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pickup : MonoBehaviour
{
    public AudioSource audioPlayer;
    public AudioClip pickupSound;
    public TowedObject objectPrefab;

    private void OnTriggerEnter(Collider collision)
    {
        if (collision.CompareTag("Player"))
        {
            audioPlayer.PlayOneShot(pickupSound);
            Destroy(this.gameObject);
            collision.GetComponent<PlayerController>().TowObject(objectPrefab);
        }
        
    }
}
