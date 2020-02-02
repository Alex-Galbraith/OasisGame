using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    private int itemGoal = 5;
    private int successfulItemCount = 0;
    public bool canPlay = false;
    public MainCamera mainCamera;
    public LightingController lightingController;
    public GrowerGroup lilyPadGroup1;
    public GrowerGroup lilyPadGroup2;
    public GrowerGroup TreeGroup1;
    public GrowerGroup TreeGroup2;
    public GrowerGroup TreeGroup3;

    public delegate void OnItemDeliveredHandler(ItemEnum item);
    public event OnItemDeliveredHandler OnItemDelivered;

    public float gameBoundaryDistance = 75f;

    public void Start()
    {
        lightingController = GetComponent<LightingController>();
        mainCamera.OnFinaleFinished += FinishGame;
        lightingController.SetNiceness(0f);
    }

    public void DropoffItem(ItemEnum item)
    {
        successfulItemCount++;
        OnItemDelivered?.Invoke(item);
        StartCoroutine(ImproveWater());
        if (successfulItemCount == 2) {
            lilyPadGroup1.Grow();
        }
        if (successfulItemCount == 4)
        {
            lilyPadGroup2.Grow();
        }
        if (item == ItemEnum.Seeds)
        {
            Debug.Log("TREES!");
            StartCoroutine(GrowTrees());
        }

        if (successfulItemCount >= itemGoal)
        {
            mainCamera.DoFinale();
        }
    }

    public void FinishGame()
    {
        SceneManager.LoadScene(0);
    }

    IEnumerator ImproveWater()
    {
        Debug.Log("Improve water");
        float speed = 0.25f;
        var targetNiceness = Mathf.Lerp(0f, 1f, (float)successfulItemCount / (float)itemGoal);
        Debug.Log(targetNiceness);
        Debug.Log(lightingController.Niceness);
        while (lightingController.Niceness < targetNiceness)
        {
            Debug.Log(lightingController.Niceness);
            lightingController.SetNiceness(lightingController.Niceness += Time.deltaTime * speed);
            yield return 0;
        }
    }

    IEnumerator GrowTrees()
    {
        TreeGroup1.Grow();
        yield return new WaitForSeconds(0.5f);
        TreeGroup2.Grow();
        yield return new WaitForSeconds(0.5f);
        TreeGroup3.Grow();
    }

}
