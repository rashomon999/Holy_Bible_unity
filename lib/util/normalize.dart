/// Normalización de texto para comparar la respuesta del usuario con la correcta.
///
/// Reemplaza al método `Normalizar()` que estaba duplicado en cada script de
/// Unity (Apocalipsis_21_4.cs, Eclesiastes.cs, Salmo_23.cs...). Aquí vive una
/// sola vez y está cubierto por tests.
library;

const Map<String, String> _accents = {
  'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a', 'ã': 'a', 'å': 'a',
  'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e',
  'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i',
  'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o', 'õ': 'o',
  'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u',
  'ñ': 'n', 'ç': 'c', 'ý': 'y', 'ÿ': 'y',
  'ĳ': 'ij', 'æ': 'ae', 'œ': 'oe',
};

final RegExp _whitespace = RegExp(r'\s+');
final RegExp _notWordChars = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);

/// Qué tan estricta es la comparación.
enum MatchMode {
  /// Igual que Unity: minúsculas + espacios colapsados. Tildes y signos cuentan.
  strict,

  /// Ignora tildes y signos de puntuación. Recomendado: el usuario escribe en
  /// un teclado móvil, castigarlo por una tilde no mide si memorizó el pasaje.
  lenient,
}

String stripAccents(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_accents[char] ?? char);
  }
  return buffer.toString();
}

String normalize(String input, {MatchMode mode = MatchMode.lenient}) {
  var text = input.toLowerCase().trim();
  if (mode == MatchMode.lenient) {
    text = stripAccents(text);
    text = text.replaceAll(_notWordChars, ' ');
  }
  return text.replaceAll(_whitespace, ' ').trim();
}

bool answersMatch(String typed, String expected,
    {MatchMode mode = MatchMode.lenient}) {
  return normalize(typed, mode: mode) == normalize(expected, mode: mode);
}
