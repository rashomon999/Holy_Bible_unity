using UnityEngine;
using UnityEngine.SceneManagement;

public class Menu : MonoBehaviour
{
    public void IrAEclesiastes()
    {
        SceneManager.LoadScene("Eclesiastes");
    }

    public void IrTimoteo()
    {
        SceneManager.LoadScene("Timoteo");
    }

    public void IrASalmo_23()
    {
        SceneManager.LoadScene("Salmo_23");
    }

    public void IrApocalipsis_21_4()
    {
        SceneManager.LoadScene("Apocalipsis_21_4");
    }


    public void SalirDelJuego()
    {
        Application.Quit();
    }
}
