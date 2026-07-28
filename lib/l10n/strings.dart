/// Textos de la interfaz. En Unity esto vivía duplicado dentro de cada escena
/// (una escena ES y otra EN por pasaje); aquí es un mapa.
class Strings {
  const Strings._(this._values);

  final Map<String, String> _values;

  static const Strings es = Strings._({
    'appTitle': 'Santa Biblia',
    'menuSubtitle': 'Escribe cada frase de memoria',
    'language': 'Idioma',
    'verify': 'Verificar',
    'showAnswers': 'Mostrar respuestas',
    'clear': 'Borrar',
    'back': 'Menú',
    'allCorrect': 'Todo lo ingresado hasta ahora es correcto.',
    'someWrong': 'Hay frases incorrectas: ',
    'nothingTyped': 'Aún no has escrito nada.',
    'progress': 'correctas',
    'settings': 'Ajustes',
    'strictTitle': 'Comparación estricta',
    'strictSubtitle': 'Exigir tildes y signos de puntuación exactos',
    'darkTitle': 'Modo oscuro',
    'darkSubtitle': 'Fondo azul marino en lugar de blanco',
    'clearConfirm': '¿Borrar todo lo escrito en este pasaje?',
    'cancel': 'Cancelar',
    'confirm': 'Borrar',
    'blank': 'Frase',
    'completed': 'completado',
  });

  static const Strings en = Strings._({
    'appTitle': 'Holy Bible',
    'menuSubtitle': 'Type each phrase from memory',
    'language': 'Language',
    'verify': 'Check',
    'showAnswers': 'Show answers',
    'clear': 'Clear',
    'back': 'Menu',
    'allCorrect': 'Everything you have typed so far is correct.',
    'someWrong': 'Incorrect phrases: ',
    'nothingTyped': 'You have not typed anything yet.',
    'progress': 'correct',
    'settings': 'Settings',
    'strictTitle': 'Strict comparison',
    'strictSubtitle': 'Require exact accents and punctuation',
    'darkTitle': 'Dark mode',
    'darkSubtitle': 'Navy background instead of white',
    'clearConfirm': 'Clear everything typed in this passage?',
    'cancel': 'Cancel',
    'confirm': 'Clear',
    'blank': 'Phrase',
    'completed': 'completed',
  });

  static Strings of(String lang) => lang == 'EN' ? en : es;

  String operator [](String key) => _values[key] ?? key;
}
