using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    [HideInInspector]
    public Rigidbody rb;

    private float speed = 4f;
    private Vector3 direction = Vector3.zero;
    private float lookSpeed = 1.4f;
    private Quaternion lookRotation;
    public TowedObject towedObject;
    public GameManager gameManager;
    public Transform homeBase;
    public bool isTowing = false;


    // Start is called before the first frame update
    void Start()
    {
        rb = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        if (!gameManager.canPlay) return;
        var forward = Input.GetAxisRaw("Vertical");
        var horizontal = Input.GetAxisRaw("Horizontal");
 
        DoMove(forward, horizontal);
        if (direction != Vector3.zero) lookRotation = Quaternion.LookRotation(direction);
        UpdateFacing();
        if (forward == -1f)
        {
            rb.drag = 4f;
        }
        else
        {
            rb.drag = 0.5f;
        }
        // Restrict movement if outside the game boundary.
        if ((Vector3.zero - transform.position).magnitude > gameManager.gameBoundaryDistance)
        {
            Vector3 velocityVector = rb.velocity.normalized;
            Vector3 offsetPos = (transform.position - homeBase.position).normalized;
            var dot = Mathf.Max(0, Vector3.Dot(velocityVector, offsetPos));
            rb.velocity = rb.velocity - dot * offsetPos;
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

    public void TowObject (TowedObject towedObject)
    {
        isTowing = true;
        this.towedObject = Instantiate(towedObject);
        this.towedObject.transform.SetParent(GameObject.Find("Tow").transform);
        this.towedObject.transform.localPosition = new Vector3(0f, 0f, -1f);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Dropoff"))
        {
            isTowing = false;
            if (towedObject != null)
            {
                gameManager.DropoffItem(towedObject.item);
                Destroy(towedObject.gameObject);
            }
        }
    }
}
