using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MainCamera : MonoBehaviour
{

    public Transform target;
    public Transform pointOfInterest;

    public float maxCameraDistance;
    public float minCameraDistance;
    private float distance;
    public float zoomedInDistance;

    Vector3 initalDir;

    // Start is called before the first frame update
    void Start()
    {
        initalDir = -transform.forward;// (transform.positionansf - target.position).normalized;
        distance = maxCameraDistance;
    }

    // Update is called once per frame
    void Update()
    {
        float distanceFromPoint = (target.position - pointOfInterest.position).magnitude;
        distance = Mathf.Lerp(maxCameraDistance, minCameraDistance, distanceFromPoint / zoomedInDistance);
        Vector3 targetPos = target.position;
        Vector3 cameraPos = targetPos + initalDir * distance;
        this.transform.position = cameraPos;
    }
}
