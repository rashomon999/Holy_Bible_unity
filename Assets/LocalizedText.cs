using TMPro;
using UnityEngine;

public class LocalizedText : MonoBehaviour
{
    [TextArea]
    public string spanishText;

    [TextArea]
    public string englishText;

    private TMP_Text textComponent;

    void Start()
    {
        textComponent = GetComponent<TMP_Text>();

        string lang = PlayerPrefs.GetString("lang", "ES");

        if (lang == "EN")
            textComponent.text = englishText;
        else
            textComponent.text = spanishText;
    }
}