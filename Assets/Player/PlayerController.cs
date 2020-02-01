using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    [HideInInspector]
    public Rigidbody rb;

    private float speed = 4f;
    private Vector3 direction = Vector3.zero;
    private float lookSpeed = 1f;
    private Quaternion lookRotation;


    // Start is called before the first frame update
    void Start()
    {
        rb = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        var forward = Input.GetAxisRaw("Vertical");
        var horizontal = Input.GetAxisRaw("Horizontal");
 

        DoMove(forward, horizontal);
        lookRotation = Quaternion.LookRotation(direction);
        UpdateFacing();
        if (forward == -1f)
        {
            rb.drag = 4f;
        }
        else
        {
            rb.drag = 0.5f;
        }

    }

    void DoMove (float f, float h)
    {
        Vector3 forwardVector = Vector3.zero;
        Vector3 horizontalVector = Vector3.zero;
        if (f == 1) forwardVector = transform.forward;
        if (h == -1) horizontalVector = -transform.right;
        if (h == 1) horizontalVector = transform.right;

        direction = (forwardVector + horizontalVector);
        rb.AddForce(forwardVector * speed);
    }

    void UpdateFacing()
    {
        if (direction != Vector3.zero)
        {
            transform.rotation = Quaternion.Slerp(transform.rotation, lookRotation, Time.deltaTime * lookSpeed);
        }
    }
}
