using UnityEngine;

public class KeyboardMover : MonoBehaviour
{
    public RectTransform panel;

    private Vector2 originalPos;

    void Start()
    {
        originalPos = panel.anchoredPosition;
    }

    void Update()
    {
#if UNITY_ANDROID || UNITY_IOS

        if (TouchScreenKeyboard.visible)
        {
            float keyboardHeight = TouchScreenKeyboard.area.height;

            panel.anchoredPosition =
                new Vector2(originalPos.x, keyboardHeight);
        }
        else
        {
            panel.anchoredPosition = originalPos;
        }

#endif
    }
}