using UnityEngine;
using UnityEngine.SceneManagement;

public class LanguageMenu : MonoBehaviour
{
    public GameObject panel;

    public void TogglePanel()
    {
        panel.SetActive(!panel.activeSelf);
    }

    public void SelectSpanish()
    {
        PlayerPrefs.SetString("lang", "ES");
        panel.SetActive(false);

        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }

    public void SelectEnglish()
    {
        PlayerPrefs.SetString("lang", "EN");
        panel.SetActive(false);

        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }
}