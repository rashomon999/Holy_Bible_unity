using UnityEngine;
using UnityEngine.SceneManagement;

public class Menu : MonoBehaviour
{
    void Awake()
    {
        // Si el usuario nunca ha elegido un idioma,
        // usar Español como predeterminado.
        if (!PlayerPrefs.HasKey("lang"))
        {
            PlayerPrefs.SetString("lang", "ES");
            PlayerPrefs.Save();
        }
    }

    private string PrefijoIdioma()
    {
        return PlayerPrefs.GetString("lang");
    }

    public void IrAEclesiastes()
    {
        SceneManager.LoadScene(PrefijoIdioma() + "_Eclesiastes");
    }

    public void IrTimoteo()
    {
        SceneManager.LoadScene(PrefijoIdioma() + "_Timoteo");
    }

    public void IrASalmo_23()
    {
        SceneManager.LoadScene(PrefijoIdioma() + "_Salmo_23");
    }

    public void IrApocalipsis_21_4()
    {
        SceneManager.LoadScene(PrefijoIdioma() + "_Apocalipsis_21_4");
    }

    public void IrAJob_1_18_22()
    {
        SceneManager.LoadScene(PrefijoIdioma() + "_Job_1_18_22");
    }

    public void IrARomanos_2_12_16()
    {
        SceneManager.LoadScene(PrefijoIdioma() + "_Romanos_2_12_16");
    }

    public void SalirDelJuego()
    {
        Application.Quit();
    }
}