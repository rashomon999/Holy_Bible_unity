# Santa Biblia — versión Flutter

Reescritura del proyecto Unity `Holy_Bible` como app Flutter, con el **contenido
real extraído de las 12 escenas** (`Assets/Scenes/ES/*.unity` y
`Assets/Scenes/EN/*.unity`): las 200+ respuestas correctas y los signos de
puntuación que separaban cada hueco ya están en
`assets/data/passages.json`. No hay que volver a escribir nada.

---

## Índice

1. [Cómo correrlo](#cómo-correrlo)
2. [La idea general en 1 minuto](#la-idea-general-en-1-minuto)
3. [Estructura de carpetas](#estructura-de-carpetas)
4. [Cada archivo explicado](#cada-archivo-explicado)
5. [Cómo se conecta todo (flujo completo)](#cómo-se-conecta-todo-flujo-completo)
6. [Recetas: "quiero cambiar X, ¿dónde toco?"](#recetas-quiero-cambiar-x-dónde-toco)
7. [Agregar un pasaje nuevo](#agregar-un-pasaje-nuevo)
8. [Qué cambió respecto a Unity](#qué-cambió-respecto-a-unity)
9. [Notas sobre los datos extraídos](#notas-sobre-los-datos-extraídos)

---

## Cómo correrlo

Necesitas Flutter.

```bash
cd holy_bible
flutter create . --project-name holy_bible --platforms android,ios
flutter pub get
flutter run
```

`flutter create .` sobre una carpeta existente **solo agrega** las carpetas
nativas (`android/`, `ios/`); no toca `lib/`, `assets/` ni `pubspec.yaml`.

Para el bundle de Play Store:

```bash
flutter build appbundle --release
```

Tests:

```bash
flutter test
```

---

## La idea general en 1 minuto

En Unity tenia **12 escenas** (6 pasajes × 2 idiomas) y cada una llevaba su
propio script con ~200 líneas repetidas. Aquí el diseño es al revés:

> **Una sola pantalla de cuestionario + un solo archivo de datos.**

- Los **datos** (títulos, frases correctas, signos de puntuación) viven en
  `assets/data/passages.json`.
- La **pantalla** (`QuizPage`) recibe un pasaje como parámetro y se dibuja
  sola a partir de él. La misma pantalla sirve para Salmo 23 en español que
  para Job 1:18-22 en inglés.
- Todo lo demás son piezas de apoyo: cargar el JSON, guardar el progreso,
  comparar respuestas, colores.

Consecuencia práctica: agregar el pasaje número 7 no requiere escribir código,
solo agregar un objeto al JSON.

---

## Estructura de carpetas

```
holy_bible/
├── pubspec.yaml                    dependencias (flutter, shared_preferences)
├── analysis_options.yaml           reglas del linter de Dart
├── assets/
│   └── data/
│       └── passages.json           ★ TODO el contenido de los cuestionarios
├── lib/
│   ├── main.dart                   arranque de la app
│   ├── models/
│   │   └── passage.dart            Passage / PassageLocale / Segment (datos puros)
│   ├── data/
│   │   └── passage_repository.dart carga y cachea passages.json
│   ├── services/
│   │   └── settings.dart           idioma, modo oscuro, borradores (ex-PlayerPrefs)
│   ├── util/
│   │   └── normalize.dart          comparación de respuestas (con tests)
│   ├── l10n/
│   │   └── strings.dart            textos de la interfaz en ES/EN
│   └── ui/
│       ├── theme.dart              paleta azul + temas claro/oscuro
│       ├── menu_page.dart          menú principal con progreso por pasaje
│       ├── quiz_page.dart          LA pantalla del cuestionario (una para todos)
│       └── widgets/
│           └── segment_field.dart  un hueco individual, se autodimensiona
├── test/
│   └── normalize_test.dart         tests de la comparación de respuestas
└── tool/                           scripts Python que extrajeron los datos de Unity
                                    (ya cumplieron su función; no se usan en la app)
```

Las carpetas siguen una convención común en Flutter:
`models` = formas de los datos, `data` = de dónde salen, `services` = estado
que persiste, `util` = funciones sueltas, `l10n` = idiomas, `ui` = pantallas.

---

## Cada archivo explicado

### `assets/data/passages.json` — el contenido

No es código, pero es el archivo más importante: es el reemplazo de tus 12
escenas de Unity. Su forma:

```json
{
  "version": 1,
  "passages": [
    {
      "id": "apocalipsis_21_4",        ← identificador interno (para guardar progreso)
      "order": 1,                       ← posición en el menú
      "locales": {
        "ES": {
          "title": "Apocalipsis 21:4-8",
          "segments": [
            { "i": 1, "answer": "Enjugará Dios toda lágrima...", "punct": ";" },
            { "i": 2, "answer": "y ya no habrá muerte",          "punct": "," }
          ]
        },
        "EN": { "title": "Revelation 21:4-8", "segments": [ ... ] }
      }
    }
  ]
}
```

Cada `segment` es **un hueco** del cuestionario: `i` es el número visible,
`answer` la frase que el usuario debe escribir, y `punct` el signo (`,` `;`
`.` `:`) que se dibuja después del hueco, fuera de él.

### `lib/models/passage.dart` — la forma de los datos

Tres clases pequeñas, sin lógica, que son el JSON convertido a objetos Dart:

| Clase | Qué representa | Campos |
|---|---|---|
| `Segment` | un hueco | `index`, `answer`, `punct` |
| `PassageLocale` | un pasaje EN UN idioma | `title`, `segments` |
| `Passage` | un pasaje completo | `id`, `order`, `locales` (mapa `"ES"/"EN"` → `PassageLocale`) |

El método clave es `passage.localized('ES')`: te da el título y los huecos en
ese idioma (y si no existe, cae al primero disponible). Cada clase tiene su
`fromJson`, que es lo que usa el repositorio al leer el archivo.

Equivalencia con Unity: esto reemplaza los campos públicos
`respuestaCorrecta1..respuestaCorrecta30` que llenabas en el Inspector.

### `lib/data/passage_repository.dart` — el cargador

Una sola responsabilidad: leer `passages.json` **una vez**, convertirlo en
`List<Passage>`, ordenarla por `order` y quedarse con el resultado en caché
(`_cache`) para que las siguientes llamadas sean instantáneas.

- `PassageRepository.load()` → se llama en `main()` antes de arrancar la UI.
- `repository.passages` → la lista que pinta el menú.
- `repository.byId('salmo_23')` → búsqueda puntual (disponible por si la
  necesitas, hoy la app navega pasando el objeto directamente).

### `lib/services/settings.dart` — estado persistente (ex-PlayerPrefs)

Es el reemplazo de `PlayerPrefs` de Unity, con algo que Unity no tenía:
**el progreso del usuario se guarda solo**. Extiende `ChangeNotifier`, así que
cuando algo cambia, la UI que lo escucha se redibuja sola.

Qué guarda (vía `shared_preferences`, el almacenamiento clave-valor del
teléfono):

| Clave | Qué es | Métodos |
|---|---|---|
| `lang` | idioma actual (`ES`/`EN`) | `lang`, `setLang()` |
| `match_mode` | comparación estricta o tolerante | `matchMode`, `setMatchMode()` |
| `dark_mode` | modo oscuro sí/no | `darkMode`, `setDarkMode()` |
| `draft:<pasaje>:<idioma>` | lo que el usuario lleva escrito en cada cuestionario | `loadDraft()`, `saveDraft()`, `clearDraft()` |

Los borradores se guardan como JSON `{"1": "Jehová es mi pastor", "5": "..."}`
(número de hueco → texto escrito). Nota que el borrador es **por pasaje Y por
idioma**: lo escrito en Salmo 23 ES no se mezcla con Salmo 23 EN.

### `lib/util/normalize.dart` — el juez de las respuestas

Reemplaza al método `Normalizar()` que estaba copiado y pegado en cada script
de Unity. Aquí vive una sola vez y tiene tests.

- `normalize(texto, mode)` — limpia un texto: minúsculas, espacios colapsados,
  y en modo tolerante además quita tildes y signos de puntuación.
- `answersMatch(escrito, esperado, mode)` — la función que usa toda la app:
  normaliza ambos lados y los compara.
- `enum MatchMode`:
  - `strict` — como Unity: la tilde y la coma cuentan.
  - `lenient` (por defecto) — "y ya no habra muerte" cuenta como correcta
    aunque falte la tilde. El usuario escribe en un teclado de celular;
    castigarlo por una tilde no mide si memorizó el pasaje.

El usuario elige el modo en Ajustes (⚙ del menú).

### `lib/l10n/strings.dart` — los textos de la interfaz

Los botones y mensajes ("Verificar", "Borrar", "Todo lo ingresado hasta ahora
es correcto...") en español e inglés, como dos mapas constantes.
`Strings.of(lang)['verify']` devuelve el texto en el idioma activo.

Ojo con la distinción: **este archivo es la interfaz**; el contenido bíblico
va en `passages.json`. Son cosas separadas a propósito.

### `lib/ui/theme.dart` — colores y estilo

- `AppColors` — la paleta azul completa como constantes con nombre:
  `blue #1B5FA8` (color principal), `blueSoft #E7F0FA` (fondos de chips),
  `canvasLight #F3F7FC` (fondo de pantalla claro), `canvasDark #0E1826`
  (fondo oscuro, azul marino, no negro), y los verdes de "correcto".
- `buildTheme(brightness)` — construye el `ThemeData` de Material 3 claro u
  oscuro: color del AppBar, forma y altura de los botones, barras de progreso.
  Todas las pantallas heredan de aquí; por eso cambiar un color en este
  archivo cambia la app entera.
- `correctColor(context)` — el verde de "correcto" adaptado al brillo actual
  (verde oscuro en tema claro, verde claro en tema oscuro, para que siempre
  tenga contraste).
- `kPassageFontSize = 18` — tamaño base del texto de los pasajes. El alto y
  ancho mínimo de los huecos se derivan de él.

### `lib/main.dart` — el arranque

Hace tres cosas, en orden:

1. `Settings.load()` — lee las preferencias guardadas del teléfono.
2. `PassageRepository.load()` — lee y parsea `passages.json`.
3. `runApp(HolyBibleApp(...))` — arranca la UI con ambos ya listos.

`HolyBibleApp` envuelve el `MaterialApp` en un `ListenableBuilder` que escucha
a `Settings`: si el usuario cambia idioma o modo oscuro, la app entera se
redibuja. `themeMode` sale de `settings.darkMode`, **no** del sistema — así un
teléfono configurado en dark mode no fuerza la app a oscuro; manda lo que el
usuario elija en Ajustes.

### `lib/ui/menu_page.dart` — el menú principal

Reemplaza tu escena `Menu.unity`. Es un `StatelessWidget` que recibe el
repositorio y los settings, y pinta:

- **Banda azul superior** con el subtítulo y el selector de idioma
  (`_LanguagePicker`, el par de botones ES/Español | EN/English).
- **Una tarjeta por pasaje** (`_PassageTile`): título, barra de progreso,
  contador `hecho / total`, y un check verde cuando está completo al 100%.
  La lista sale de `repository.passages` con un simple `for` — por eso un
  pasaje nuevo en el JSON aparece aquí sin tocar este archivo.
- **Ajustes** (icono ⚙): un panel inferior con los switches de comparación
  estricta y modo oscuro.

El progreso que muestra cada tarjeta lo calcula `_progress()`: carga el
borrador guardado de ese pasaje y cuenta cuántas frases escritas ya coinciden
con la respuesta correcta (usando el mismo `answersMatch` del cuestionario,
así el menú y la pantalla nunca discrepan).

Al tocar una tarjeta: `Navigator.push(QuizPage(passage: ..., settings: ...))`.
Así es como el pasaje "viaja" del menú al cuestionario.

### `lib/ui/quiz_page.dart` — la pantalla del cuestionario

El corazón de la app. **Una sola clase para los 12 cuestionarios**: recibe el
`Passage` por constructor y todo lo demás se deriva de él. Es `StatefulWidget`
porque mantiene estado vivo mientras el usuario escribe.

Su estado (`_QuizPageState`):

| Campo | Qué es |
|---|---|
| `_lang` / `_locale` | idioma activo y el contenido del pasaje en ese idioma |
| `_controllers` | un `TextEditingController` por hueco (el texto que hay en cada campo) |
| `_statuses` | el estado de cada hueco: `untouched` / `correct` / `wrong` |
| `_saveTimer` | temporizador del autoguardado |
| `_message` | el mensaje de resultado de abajo (o `null` si no hay) |

Sus métodos, que son el ciclo de vida completo de una sesión de estudio:

- `_bind()` — al entrar (o cambiar idioma): carga el borrador guardado con
  `settings.loadDraft()` y crea un controller por hueco, pre-llenado con lo
  que el usuario había escrito la última vez.
- `_scheduleSave()` / `_flushSave()` — el autoguardado. Cada tecla reinicia un
  timer de 600 ms; cuando el usuario deja de escribir, se guarda el borrador.
  (Sin esto pasaría lo de Unity: salir de la pantalla = perderlo todo.)
- `_verify()` — el equivalente a tu `Verificar()`, pero un `for` sobre los
  segmentos en vez de 30 llamadas escritas a mano. Por cada hueco con texto
  llama `answersMatch()`; los vacíos se ignoran (igual que en Unity). Al final
  arma el mensaje: todo correcto / "Hay frases incorrectas: 3, 7" / aún no
  escribiste nada.
- `_showAnswers()` — el botón del ojo: llena todos los campos con la
  respuesta correcta.
- `_clear()` — el botón de basura: pide confirmación con un diálogo y borra
  campos + borrador guardado.
- `_switchLanguage()` — cambia ES↔EN sin salir de la pantalla: guarda el
  borrador del idioma actual, descarta los controllers y re-hace `_bind()`
  con el otro idioma.

En el `build`, el pasaje se pinta como un `Wrap` (texto que fluye y salta de
línea solo) alternando `SegmentField` (el hueco) y el signo de puntuación de
cada segmento. Abajo: el mensaje de resultado y la fila de botones.

Clases auxiliares privadas del mismo archivo: `_PassageCard` (la tarjeta
blanca con el chip de progreso "n / total correctas") y `_RoundAction` (los
botones cuadrados del ojo y la basura).

### `lib/ui/widgets/segment_field.dart` — un hueco

El widget más pequeño y el que más trabajo hace. Representa **un** campo de
texto del cuestionario.

Lo importante es que **su ancho no está escrito a mano** (eso era lo que en
Unity ajustabas campo por campo en el Inspector). Aquí:

1. `_measure()` mide la frase esperada con un `TextPainter` — literalmente
   "¿cuántos píxeles ocuparía este texto?" — respetando el tamaño de fuente
   del sistema del teléfono (`MediaQuery.textScalerOf`).
2. Le suma `_chrome` (28 px): el padding interno del campo, el cursor y una
   holgura. Sin esa holgura la última letra quedaba cortada
   ("muerte" → "muert").
3. Si la respuesta está mal y aparece la ✗, suma `_suffixWidth` (22 px) para
   que el icono no tape texto.
4. El resultado se acota entre `_minWidth` (90) y el `maxWidth` que le pasa
   `QuizPage` (el ancho disponible de la tarjeta). Si la frase es más larga
   que la línea, el campo ocupa todo el ancho y hace wrap a varias líneas.

También pinta el estado con color: gris (sin tocar), verde (correcta), rojo
con ✗ (incorrecta), y muestra el número del hueco como hint gris cuando está
vacío.

### `test/normalize_test.dart` y `tool/`

- Los tests cubren `normalize.dart`: tildes, mayúsculas, espacios, la
  ligadura `ĳ`, modo estricto vs tolerante. Se corren con `flutter test`.
- `tool/` son los scripts Python que usé para extraer las respuestas de tus
  escenas `.unity`. Ya cumplieron su función; no forman parte de la app y
  puedes ignorarlos (o borrarlos).

---

## Cómo se conecta todo (flujo completo)

```
                       arranque
                          │
   main.dart ── Settings.load() ──────────┐  (preferencias del teléfono)
       │    └── PassageRepository.load() ─┤  (lee passages.json → List<Passage>)
       ▼                                  │
  HolyBibleApp ◄──── escucha ──── Settings│
       │  buildTheme() ← theme.dart       │
       ▼                                  │
   MenuPage ──── repository.passages ─────┘
       │   └─ _progress() usa Settings.loadDraft() + normalize.answersMatch()
       │
       │  usuario toca "Salmo 23"
       ▼
   Navigator.push( QuizPage(passage: salmo23, settings: settings) )
       │
       ▼
   QuizPage
       ├─ _bind():    settings.loadDraft() → llena los TextEditingController
       ├─ build():    por cada Segment → SegmentField (+ su signo de puntuación)
       │                  └─ SegmentField mide segment.answer y se autodimensiona
       ├─ escribir:   onChanged → _scheduleSave() → 600 ms → settings.saveDraft()
       ├─ Verificar:  _verify() → answersMatch(escrito, segment.answer, matchMode)
       │                  └─ pinta cada hueco verde/rojo + mensaje de resultado
       └─ volver:     dispose() guarda el borrador una última vez
                          │
                          ▼
   MenuPage se redibuja (escucha a Settings) → la barra de progreso refleja
   lo que acabas de completar
```

Y la dependencia entre archivos, en una línea cada una:

- `main.dart` conoce a **todos** los de arriba (los crea y los conecta).
- `menu_page.dart` y `quiz_page.dart` usan `settings`, `strings`,
  `normalize`, `theme` y los modelos.
- `segment_field.dart` solo conoce `theme.dart`. No sabe qué es un pasaje;
  recibe una frase esperada y un estado.
- `passage.dart`, `normalize.dart`, `strings.dart` y `theme.dart` no dependen
  de nadie (por eso son fáciles de testear y de reutilizar).

---

## Recetas: "quiero cambiar X, ¿dónde toco?"

| Quiero... | Archivo | Qué buscar |
|---|---|---|
| Agregar/editar un pasaje o corregir una respuesta | `assets/data/passages.json` | el objeto del pasaje |
| Cambiar el azul de la app / los colores | `lib/ui/theme.dart` | `AppColors` |
| Cambiar el tamaño de letra de los pasajes | `lib/ui/theme.dart` | `kPassageFontSize` |
| Hacer los huecos más anchos/estrechos | `lib/ui/widgets/segment_field.dart` | `_chrome`, `_minWidth` |
| Cambiar un texto de botón o mensaje | `lib/l10n/strings.dart` | la clave correspondiente |
| Ajustar la tolerancia de la comparación | `lib/util/normalize.dart` | `normalize()` / `MatchMode` |
| Cambiar cada cuánto se autoguarda | `lib/ui/quiz_page.dart` | `_scheduleSave()` (600 ms) |
| Agregar un tercer idioma | `passages.json` (nuevo locale) + `strings.dart` (nuevo mapa) + los botones ES/EN en `menu_page.dart` y `quiz_page.dart` |
| Cambiar cómo se ve una tarjeta del menú | `lib/ui/menu_page.dart` | `_PassageTile` |
| Agregar un ajuste nuevo | `lib/services/settings.dart` (guardarlo) + `menu_page.dart` → `_openSettings` (el switch) |

---

## Agregar un pasaje nuevo

Solo `assets/data/passages.json`:

```json
{
  "id": "juan_3_16",
  "order": 7,
  "locales": {
    "ES": {
      "title": "Juan 3:16",
      "segments": [
        { "i": 1, "answer": "Porque de tal manera amó Dios al mundo", "punct": "," },
        { "i": 2, "answer": "que ha dado a su Hijo unigénito", "punct": "," }
      ]
    },
    "EN": { "title": "John 3:16", "segments": [] }
  }
}
```

Guardas, `r` en la terminal de `flutter run`, y el pasaje ya está en el menú.
Cero código.

---

## Qué cambió respecto a Unity

| | Unity | Flutter |
|---|---|---|
| Pasajes | 12 escenas (`ES_*`, `EN_*`) | 1 pantalla + 1 JSON |
| Respuestas | 30 campos públicos por escena, puestos a mano en el Inspector | lista en `passages.json` |
| Validación | `Verificar()` con 30 llamadas escritas una por una | un `for` sobre los segmentos |
| Agregar un pasaje | crear escena, script, arrastrar 30 inputs | agregar un objeto al JSON |
| Ancho de cada hueco | ajustado a mano campo por campo | medido a partir de la frase esperada |
| Progreso del usuario | se perdía al salir de la escena | se guarda solo |
| Tildes / puntuación | una tilde de menos = error | modo tolerante por defecto, estricto opcional |

---

## Notas sobre los datos extraídos

- El orden de los huecos y los signos (`,` `;` `.` `:`) se reconstruyó a partir
  de la posición real de cada objeto en las escenas de Unity, no se inventaron.
- Los campos que en el Inspector seguían con el valor por defecto
  (`Respuesta27`, `Respuesta28`...) se omitieron. Por eso algunos pasajes tienen
  menos huecos en inglés que en español: son los que te faltaba traducir.
  Cantidades actuales:

  | Pasaje | ES | EN |
  |---|---|---|
  | Apocalipsis 21:4-8 | 26 | 29 |
  | Eclesiastés 9:7-10 | 19 | 13 |
  | Job 1:18-22 | 19 | 16 |
  | Romanos 2:12-16 | 16 | 14 |
  | Salmo 23 | 15 | 16 |
  | 1 Timoteo 2:9-13 | 15 | 11 |

- La ligadura `ĳ` que aparecía en varias respuestas (`dĳo`, `hĳos`) se
  normalizó a `ij`; además `normalize.dart` la acepta por si queda alguna.