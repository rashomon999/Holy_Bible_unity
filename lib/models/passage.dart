/// Modelo de datos del cuestionario.
///
/// En Unity cada pasaje era una escena con 19-30 campos públicos
/// (`input1..input30`, `respuestaCorrecta1..respuestaCorrecta30`). Aquí un
/// pasaje es simplemente una lista de [Segment]: agregar un pasaje nuevo es
/// agregar un objeto al JSON, no crear una escena ni un script.
library;

class Segment {
  const Segment({required this.index, required this.answer, this.punct = ''});

  /// Número visible del hueco (1-based), el que se muestra al reportar errores.
  final int index;

  /// Frase correcta. Cada hueco es una oración/frase delimitada por puntuación.
  final String answer;

  /// Signo de puntuación que se dibuja inmediatamente después del hueco.
  final String punct;

  factory Segment.fromJson(Map<String, dynamic> json) => Segment(
        index: json['i'] as int,
        answer: json['answer'] as String,
        punct: (json['punct'] as String?) ?? '',
      );
}

class PassageLocale {
  const PassageLocale({required this.title, required this.segments});

  final String title;
  final List<Segment> segments;

  factory PassageLocale.fromJson(Map<String, dynamic> json) => PassageLocale(
        title: json['title'] as String,
        segments: (json['segments'] as List<dynamic>)
            .map((e) => Segment.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
      );
}

class Passage {
  const Passage({required this.id, required this.order, required this.locales});

  final String id;
  final int order;
  final Map<String, PassageLocale> locales;

  PassageLocale localized(String lang) =>
      locales[lang] ?? locales.values.first;

  factory Passage.fromJson(Map<String, dynamic> json) => Passage(
        id: json['id'] as String,
        order: json['order'] as int,
        locales: (json['locales'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
              key, PassageLocale.fromJson(value as Map<String, dynamic>)),
        ),
      );
}
