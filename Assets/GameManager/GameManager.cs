using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    private int itemGoal = 5;
    private int successfulItemCount = 0;

    public void DropoffItem (ItemEnum item)
    {
        successfulItemCount++;
        Debug.Log(successfulItemCount);
        if (successfulItemCount >= itemGoal)
        {
            Debug.Log("YOU WIN!");
        }
    }
}
