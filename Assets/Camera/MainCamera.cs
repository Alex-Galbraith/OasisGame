using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MainCamera : MonoBehaviour
{

    public Transform target;
    public Transform pointOfInterest;
    public GameManager gameManager;
    public AudioSource audioManager;
    public AudioSource cancelableSound;
    public AudioClip deliverySound;
    public AudioClip whiteNoiseFadeout;
    public AudioClip pop;
    public CanvasGroup panel;


    public float cinematicDuration;
    private float cinematicTimer;
    public float maxCameraDistance;
    public float minCameraDistance;
    private float distance;
    public float zoomedInDistance;
    private Vector3 origin = Vector3.zero;
    public float boundaryDistance = 75f;
    public float cameraMoveSpeed = 100f;
    private Vector3 currentVelocity;
    private bool doingCinematic;

    Vector3 initalDir;

    public delegate void OnFinaleFinishedHandler();
    public event OnFinaleFinishedHandler OnFinaleFinished;

    // Start is called before the first frame update
    void Start()
    {
        initalDir = -transform.forward;// (transform.positionansf - target.position).normalized;
        distance = maxCameraDistance;

        gameManager.OnItemDelivered += HandleItemDelivered;
    }

    // Update is called once per frame
    void Update()
    {
        if (!doingCinematic)
        {
            float distanceFromPoint = (target.position - pointOfInterest.position).magnitude;
            distance = Mathf.Lerp(maxCameraDistance, minCameraDistance, distanceFromPoint / zoomedInDistance);
            Vector3 targetPos = target.position;
            float distanceFromOrigin = (origin - target.position).magnitude;
            Vector3 cameraPos = targetPos + initalDir * distance;
            this.transform.position = cameraPos;
        }
    }

    public void DoCinematic()
    {
        cinematicTimer = 0f;
        cancelableSound.clip = deliverySound;
        cancelableSound.Play();
        doingCinematic = true;
        StartCoroutine(ShowBase());
    }

    public void FinishCinematic()
    {
        cancelableSound.Stop();
        doingCinematic = false;
        audioManager.PlayOneShot(pop);

    }

    IEnumerator ShowBase()
    {
        while (cinematicTimer < cinematicDuration)
        {
            cinematicTimer += Time.deltaTime;
            this.transform.position = Vector3.MoveTowards(transform.position, pointOfInterest.position + new Vector3(0f, 10f, -10f), Time.deltaTime * cameraMoveSpeed);
            yield return 0;
        }
        FinishCinematic();

    }

    public void HandleItemDelivered (ItemEnum item)
    {
        //DoCinematic();
        DoFinale();
    }

    public void DoFinale ()
    {
        doingCinematic = true;
        float distanceFromPoint = (target.position - pointOfInterest.position).magnitude;
        distance = Mathf.Lerp(maxCameraDistance, minCameraDistance, distanceFromPoint / zoomedInDistance);
        Vector3 targetPos = target.position;
        Vector3 cameraPos = targetPos + initalDir * distance;
        this.transform.position = cameraPos;

        StartCoroutine(FinaleRoutine());
    }

    IEnumerator FinaleRoutine()
    {
        float finaleDuration = 6f;
        float speed = 0f;
        float finaleTimer = 0f;
        panel.gameObject.SetActive(true);
        panel.alpha = 0f;
        while (finaleTimer < finaleDuration)
        {
            panel.alpha += Time.deltaTime / 6;
            speed += Time.deltaTime * 2;
            finaleTimer += Time.deltaTime;
            this.transform.position = Vector3.MoveTowards(transform.position, transform.position + Vector3.up, Time.deltaTime * speed);
            yield return 0;
        }
        yield return 0;
        OnFinaleFinished?.Invoke();
    }
}
