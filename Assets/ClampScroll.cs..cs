using UnityEngine;
using UnityEngine.UI;

public class ClampScroll : MonoBehaviour
{
    public ScrollRect scrollRect;

    // Cuántos píxeles puede bajar desde la posición inicial
    public float maxOffset = 1800f;

    private float startY;

    void Start()
    {
        startY = scrollRect.content.anchoredPosition.y;
    }

    void LateUpdate()
    {
        Vector2 pos = scrollRect.content.anchoredPosition;

        pos.y = Mathf.Clamp(pos.y, startY, startY + maxOffset);

        scrollRect.content.anchoredPosition = pos;
    }
}