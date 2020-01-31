using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class EnableDepthTexture : MonoBehaviour {
    // Use this for initialization
    void Start() {
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
    }
}
