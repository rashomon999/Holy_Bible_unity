import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/passage.dart';

/// Carga los pasajes desde `assets/data/passages.json`.
///
/// Un solo archivo alimenta los 12 cuestionarios (6 pasajes x 2 idiomas) que en
/// Unity eran 12 escenas separadas. Para añadir un pasaje nuevo basta con
/// añadir un objeto a ese JSON.
class PassageRepository {
  PassageRepository._(this.passages);

  final List<Passage> passages;

  static PassageRepository? _cache;

  static Future<PassageRepository> load() async {
    final cached = _cache;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString('assets/data/passages.json');
    final decoded = json.decode(raw) as Map<String, dynamic>;
    final list = (decoded['passages'] as List<dynamic>)
        .map((e) => Passage.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return _cache = PassageRepository._(List.unmodifiable(list));
  }

  Passage? byId(String id) {
    for (final passage in passages) {
      if (passage.id == id) return passage;
    }
    return null;
  }
}
