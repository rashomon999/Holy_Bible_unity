import 'package:flutter_test/flutter_test.dart';
import 'package:holy_bible/util/normalize.dart';

void main() {
  group('modo estricto (equivalente al Normalizar() de Unity)', () {
    test('ignora mayúsculas y espacios de sobra', () {
      expect(
        answersMatch('  Jehová   ES mi Pastor ', 'Jehová es mi pastor',
            mode: MatchMode.strict),
        isTrue,
      );
    });

    test('exige las tildes', () {
      expect(
        answersMatch('Jehova es mi pastor', 'Jehová es mi pastor',
            mode: MatchMode.strict),
        isFalse,
      );
    });
  });

  group('modo tolerante (por defecto)', () {
    test('acepta la frase sin tildes', () {
      expect(
        answersMatch('Jehova es mi pastor', 'Jehová es mi pastor'),
        isTrue,
      );
    });

    test('ignora la puntuación que el usuario agregue de más', () {
      expect(
        answersMatch('nada me faltará.', 'nada me faltará'),
        isTrue,
      );
    });

    test('sigue detectando una frase distinta', () {
      expect(
        answersMatch('nada me faltaba', 'nada me faltará'),
        isFalse,
      );
    });

    test('resuelve la ligadura ĳ que venía de las escenas de Unity', () {
      expect(answersMatch('y me dijo', 'y me dĳo'), isTrue);
    });
  });
}
