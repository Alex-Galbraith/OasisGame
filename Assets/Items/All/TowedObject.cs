using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TowedObject : MonoBehaviour
{
    public ItemEnum item;
    
    public void SetItem (ItemEnum item)
    {
        this.item = item;
    }
}
