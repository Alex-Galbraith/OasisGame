using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrowerGroup : MonoBehaviour
{
    public Grower[] growers;

    private void Start()
    {
        growers = GetComponentsInChildren<Grower>();
    }

    public void Grow()
    {
        foreach(Grower grower in growers)
        {
            grower.Play();
        }
    }
}
