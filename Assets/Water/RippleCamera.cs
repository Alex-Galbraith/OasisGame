using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class RippleCamera : MonoBehaviour
{
    public new Camera camera;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Shader.SetGlobalMatrix("_RippleWorldToClip",  camera.projectionMatrix * camera.worldToCameraMatrix );
    }
}
