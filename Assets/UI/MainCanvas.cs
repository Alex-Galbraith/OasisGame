using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MainCanvas : MonoBehaviour
{
    public CanvasGroup BackingCanvas;
    private CanvasGroup cg;
    private float fadeSpeed = 0.5f;
    public bool doneIntro = false;
    private bool canFadeOut = false;
    public bool skipIntro = false;

    public GameManager gameManager;
    public AudioSource audioManager;
    public AudioClip chime;

    // Start is called before the first frame update
    void Start()
    {
        cg = GetComponent<CanvasGroup>();
        StartCoroutine(FadeIn());

        if(skipIntro)
        {
            doneIntro = true;
            gameManager.canPlay = true;
            BackingCanvas.gameObject.SetActive(false);
            cg.gameObject.SetActive(false);
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.anyKey && !doneIntro && canFadeOut)
        {
            StopAllCoroutines();
            doneIntro = true;
            StartCoroutine(FadeOut());
        }
    }

    IEnumerator FadeIn()
    {
        cg.alpha = 0;
        while (BackingCanvas.alpha > 0.4f)
        {
            BackingCanvas.alpha -= Time.deltaTime * fadeSpeed/4;
            yield return 0;
        }
        while (cg.alpha < 1)
        {
            cg.alpha += Time.deltaTime * fadeSpeed;

            yield return 0;
        }
        canFadeOut = true;
    }

    IEnumerator FadeOut()
    {
        audioManager.PlayOneShot(chime);
        cg.alpha = 1;
        fadeSpeed = 1f;
        while (cg.alpha > 0)
        {
            BackingCanvas.alpha -= Time.deltaTime * fadeSpeed;
            cg.alpha -= Time.deltaTime * fadeSpeed;
            yield return 0;
        }
        BackingCanvas.gameObject.SetActive(false);
        gameManager.canPlay = true;
    }
}
