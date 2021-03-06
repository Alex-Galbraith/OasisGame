﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Grower : MonoBehaviour
{
    public Renderer Renderer;
    public AnimationCurve curve = AnimationCurve.Linear(0,0,1,1);
    public float timeToPlay = 0.4f;
    public float from = -1;
    public float to = 2;

    public float delay = 0;
    // Start is called before the first frame update

    private Collider collider;
    public void Start()
    {
        if (Renderer == null)
        {
            Renderer = GetComponentInChildren<Renderer>();
        }
        Renderer.material = new Material(Renderer.sharedMaterial);

        collider = GetComponentInChildren<Collider>();
        if (collider) collider.enabled = false;
        SetTime(from);

    }

    // Update is called once per frame
    void Update()
    {
        
    }
    [ContextMenu("Play")]
    public void Play(){
        if (collider) { collider.enabled = true; }
        StartCoroutine(PlayRoutine(timeToPlay, from, to));
    }

    private IEnumerator PlayRoutine(float time, float from, float to){
        yield return new WaitForSeconds(delay);
        float nowTime = Time.time;
        float dtime = 0;
        while((dtime = Time.time - nowTime) < time){
            SetTime(from + curve.Evaluate(dtime/time) * (to-from));
            yield return null;
        }
    }

    void SetTime(float time){
        Renderer.material.SetFloat("_DropIn", time);
    }
}
