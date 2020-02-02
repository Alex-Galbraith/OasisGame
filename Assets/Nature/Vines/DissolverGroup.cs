using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DissolverGroup : MonoBehaviour
{
    private Dissolver[] dissolvers;

    // Start is called before the first frame update
    void Start()
    {
        dissolvers = GetComponentsInChildren<Dissolver>();
    }

    public void Play()
    {
        foreach(var dissolver in dissolvers)
        {
            dissolver.Play();
        }
    }
}
