using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MainCamera : MonoBehaviour
{

    public Transform target;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 targetPos = target.position;
        Vector3 cameraPos = targetPos + new Vector3(0f, 10f, -10f);
        this.transform.position = cameraPos;
    }
}
