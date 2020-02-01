using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightingController : MonoBehaviour
{
    [Range(0,1)]
    public float Niceness;
    public Color NiceAmbientColor;
    public Color UglyAmbientColor;

    public Color UglyWaterColor;
    public Color NiceWaterColor;

    public Color UglyFoamColor;
    public Color NiceFoamColor;

    public Color UglyLightColor;
    public Color NiceLightColor;

    public Material waterMaterial;
    public Light Light;

    public void SetNiceness(float value){
        waterMaterial.SetColor("_DepthColor", Color.Lerp(UglyWaterColor, NiceWaterColor, value));
        waterMaterial.SetColor("_FoamColor", Color.Lerp(UglyFoamColor, NiceFoamColor, value));
        Shader.SetGlobalColor("_AmbientColor", Color.Lerp(UglyAmbientColor, NiceAmbientColor, value));
        Light.color = Color.Lerp(UglyLightColor,NiceLightColor, value);
        Niceness = value;
    }

    /// <summary>
    /// Called when the script is loaded or a value is changed in the
    /// inspector (Called in the editor only).
    /// </summary>
    void OnValidate()
    {
        SetNiceness(Niceness);
    }

}
