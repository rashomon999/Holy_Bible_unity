using UnityEngine;
using TMPro;
using UnityEngine.SceneManagement;

public class Apocalipsis_21_4 : MonoBehaviour
{
    // 28 Inputs
    public TMP_InputField input1, input2, input3, input4, input5;
    public TMP_InputField input6, input7, input8, input9, input10;
    public TMP_InputField input11, input12, input13, input14, input15;
    public TMP_InputField input16, input17, input18, input19, input20;
    public TMP_InputField input21, input22, input23, input24, input25;
    public TMP_InputField input26, input27, input28;

    public TMP_Text resultadoText;

    // 28 Respuestas correctas
    public string respuestaCorrecta1  = "Respuesta1";
    public string respuestaCorrecta2  = "Respuesta2";
    public string respuestaCorrecta3  = "Respuesta3";
    public string respuestaCorrecta4  = "Respuesta4";
    public string respuestaCorrecta5  = "Respuesta5";
    public string respuestaCorrecta6  = "Respuesta6";
    public string respuestaCorrecta7  = "Respuesta7";
    public string respuestaCorrecta8  = "Respuesta8";
    public string respuestaCorrecta9  = "Respuesta9";
    public string respuestaCorrecta10 = "Respuesta10";
    public string respuestaCorrecta11 = "Respuesta11";
    public string respuestaCorrecta12 = "Respuesta12";
    public string respuestaCorrecta13 = "Respuesta13";
    public string respuestaCorrecta14 = "Respuesta14";
    public string respuestaCorrecta15 = "Respuesta15";
    public string respuestaCorrecta16 = "Respuesta16";
    public string respuestaCorrecta17 = "Respuesta17";
    public string respuestaCorrecta18 = "Respuesta18";
    public string respuestaCorrecta19 = "Respuesta19";
    public string respuestaCorrecta20 = "Respuesta20";
    public string respuestaCorrecta21 = "Respuesta21";
    public string respuestaCorrecta22 = "Respuesta22";
    public string respuestaCorrecta23 = "Respuesta23";
    public string respuestaCorrecta24 = "Respuesta24";
    public string respuestaCorrecta25 = "Respuesta25";
    public string respuestaCorrecta26 = "Respuesta26";
    public string respuestaCorrecta27 = "Respuesta27";
    public string respuestaCorrecta28 = "Respuesta28";

    public void Verificar()
    {
        bool hayErrores = false;
        string mensajeErrores = "";

        ValidarInput(input1, respuestaCorrecta1, 1, ref hayErrores, ref mensajeErrores);
        ValidarInput(input2, respuestaCorrecta2, 2, ref hayErrores, ref mensajeErrores);
        ValidarInput(input3, respuestaCorrecta3, 3, ref hayErrores, ref mensajeErrores);
        ValidarInput(input4, respuestaCorrecta4, 4, ref hayErrores, ref mensajeErrores);
        ValidarInput(input5, respuestaCorrecta5, 5, ref hayErrores, ref mensajeErrores);
        ValidarInput(input6, respuestaCorrecta6, 6, ref hayErrores, ref mensajeErrores);
        ValidarInput(input7, respuestaCorrecta7, 7, ref hayErrores, ref mensajeErrores);
        ValidarInput(input8, respuestaCorrecta8, 8, ref hayErrores, ref mensajeErrores);
        ValidarInput(input9, respuestaCorrecta9, 9, ref hayErrores, ref mensajeErrores);
        ValidarInput(input10, respuestaCorrecta10, 10, ref hayErrores, ref mensajeErrores);
        ValidarInput(input11, respuestaCorrecta11, 11, ref hayErrores, ref mensajeErrores);
        ValidarInput(input12, respuestaCorrecta12, 12, ref hayErrores, ref mensajeErrores);
        ValidarInput(input13, respuestaCorrecta13, 13, ref hayErrores, ref mensajeErrores);
        ValidarInput(input14, respuestaCorrecta14, 14, ref hayErrores, ref mensajeErrores);
        ValidarInput(input15, respuestaCorrecta15, 15, ref hayErrores, ref mensajeErrores);
        ValidarInput(input16, respuestaCorrecta16, 16, ref hayErrores, ref mensajeErrores);
        ValidarInput(input17, respuestaCorrecta17, 17, ref hayErrores, ref mensajeErrores);
        ValidarInput(input18, respuestaCorrecta18, 18, ref hayErrores, ref mensajeErrores);
        ValidarInput(input19, respuestaCorrecta19, 19, ref hayErrores, ref mensajeErrores);
        ValidarInput(input20, respuestaCorrecta20, 20, ref hayErrores, ref mensajeErrores);
        ValidarInput(input21, respuestaCorrecta21, 21, ref hayErrores, ref mensajeErrores);
        ValidarInput(input22, respuestaCorrecta22, 22, ref hayErrores, ref mensajeErrores);
        ValidarInput(input23, respuestaCorrecta23, 23, ref hayErrores, ref mensajeErrores);
        ValidarInput(input24, respuestaCorrecta24, 24, ref hayErrores, ref mensajeErrores);
        ValidarInput(input25, respuestaCorrecta25, 25, ref hayErrores, ref mensajeErrores);
        ValidarInput(input26, respuestaCorrecta26, 26, ref hayErrores, ref mensajeErrores);
        ValidarInput(input27, respuestaCorrecta27, 27, ref hayErrores, ref mensajeErrores);
        ValidarInput(input28, respuestaCorrecta28, 28, ref hayErrores, ref mensajeErrores);

        if (hayErrores)
        {
            resultadoText.text = mensajeErrores;
        }
        else
        {
            resultadoText.text = "Todo lo ingresado hasta ahora es correcto.";
        }
    }

    public void MostrarRespuestas()
    {
        if (input1 != null) input1.text = respuestaCorrecta1;
        if (input2 != null) input2.text = respuestaCorrecta2;
        if (input3 != null) input3.text = respuestaCorrecta3;
        if (input4 != null) input4.text = respuestaCorrecta4;
        if (input5 != null) input5.text = respuestaCorrecta5;
        if (input6 != null) input6.text = respuestaCorrecta6;
        if (input7 != null) input7.text = respuestaCorrecta7;
        if (input8 != null) input8.text = respuestaCorrecta8;
        if (input9 != null) input9.text = respuestaCorrecta9;
        if (input10 != null) input10.text = respuestaCorrecta10;
        if (input11 != null) input11.text = respuestaCorrecta11;
        if (input12 != null) input12.text = respuestaCorrecta12;
        if (input13 != null) input13.text = respuestaCorrecta13;
        if (input14 != null) input14.text = respuestaCorrecta14;
        if (input15 != null) input15.text = respuestaCorrecta15;
        if (input16 != null) input16.text = respuestaCorrecta16;
        if (input17 != null) input17.text = respuestaCorrecta17;
        if (input18 != null) input18.text = respuestaCorrecta18;
        if (input19 != null) input19.text = respuestaCorrecta19;
        if (input20 != null) input20.text = respuestaCorrecta20;
        if (input21 != null) input21.text = respuestaCorrecta21;
        if (input22 != null) input22.text = respuestaCorrecta22;
        if (input23 != null) input23.text = respuestaCorrecta23;
        if (input24 != null) input24.text = respuestaCorrecta24;
        if (input25 != null) input25.text = respuestaCorrecta25;
        if (input26 != null) input26.text = respuestaCorrecta26;
        if (input27 != null) input27.text = respuestaCorrecta27;
        if (input28 != null) input28.text = respuestaCorrecta28;
    }

    void LoadNextScene()
    {
        int currentSceneIndex = SceneManager.GetActiveScene().buildIndex;
        SceneManager.LoadScene(currentSceneIndex + 1);
    }

    public void IrAlMenu()
    {
        SceneManager.LoadScene("Menu");
    }

    void ValidarInput(
        TMP_InputField input,
        string respuestaCorrecta,
        int numeroInput,
        ref bool hayErrores,
        ref string mensaje
    )
    {
        // Si el input no existe → se ignora
        if (input == null)
            return;

        // Si está vacío → no se valida
        if (string.IsNullOrWhiteSpace(input.text))
            return;

        // Si está incorrecto
        if (input.text != respuestaCorrecta)
        {
            hayErrores = true;
            mensaje += $"Input {numeroInput} incorrecto\n";
        }
    }
}