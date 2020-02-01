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

    public delegate void OnItemDeliveredHandler(ItemEnum item);
    public event OnItemDeliveredHandler OnItemDelivered;

    public float gameBoundaryDistance = 75f;

    public void Start()
    {
        mainCamera.OnFinaleFinished += FinishGame;
    }

    public void DropoffItem (ItemEnum item)
    {
        successfulItemCount++;
        OnItemDelivered?.Invoke(item);
        if (successfulItemCount >= itemGoal)
        {
            Debug.Log("YOU WIN!");
        }
    }

    public void FinishGame()
    {
        SceneManager.LoadScene(0);
    }

}
