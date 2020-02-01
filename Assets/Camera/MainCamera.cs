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
    public AudioClip finaleMusic;
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
    private float buildingYOffset = 2f;

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
        cancelableSound.Play();
        //doingCinematic = true;
        StartCoroutine(ShowBase());
    }

    public void FinishCinematic()
    {
        cancelableSound.Stop();
        doingCinematic = false;

    }

    IEnumerator ShowBase()
    {
        var normalMax = maxCameraDistance;
        while (cinematicTimer < cinematicDuration)
        {
            cinematicTimer += Time.deltaTime;
            this.maxCameraDistance += Time.deltaTime * 8;
            yield return 0;
        }
        while (maxCameraDistance > normalMax)
        {
            this.maxCameraDistance -= Time.deltaTime * 8;
            yield return 0;
        }
        maxCameraDistance = normalMax;
        FinishCinematic();
    }

    public void HandleItemDelivered (ItemEnum item)
    {
        cancelableSound.clip = deliverySound;
        DoCinematic();
        //DoFinale();
    }

    public void DoFinale ()
    {
        //doingCinematic = true;
        gameManager.canPlay = false;
        cancelableSound.PlayOneShot(finaleMusic);
        float distanceFromPoint = (target.position - pointOfInterest.position).magnitude;
        distance = maxCameraDistance;
        Vector3 targetPos = target.position;
        Vector3 cameraPos = targetPos + initalDir * distance;
        this.transform.position = cameraPos;

        StartCoroutine(FadeOutMusic(audioManager));
        StartCoroutine(FinaleRoutine());
    }

    IEnumerator FinaleRoutine()
    {
        float finaleDuration = 12f;
        float speed = 0f;
        float finaleTimer = 0f;
        panel.gameObject.SetActive(true);
        panel.alpha = 0f;
        while (finaleTimer < finaleDuration)
        {
            panel.alpha += Time.deltaTime / 12;
            speed += Time.deltaTime / 8;
            finaleTimer += Time.deltaTime;
            this.maxCameraDistance += speed;
            yield return 0;
        }
        StartCoroutine(FadeOutMusic(cancelableSound, 0.5f));
        while (cancelableSound.volume > 0)
        {
            yield return 0;
        }
        yield return 0;
        OnFinaleFinished?.Invoke();
    }

    IEnumerator FadeOutMusic(AudioSource source, float speed=1f)
    {
        var startVolume = source.volume;
        while (startVolume > 0)
        {
            startVolume -= Time.deltaTime * speed;
            source.volume = startVolume;
            yield return 0;
        }
        source.Stop();
    }
}
