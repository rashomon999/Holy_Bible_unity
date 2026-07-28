import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/normalize.dart';

/// Reemplazo de `PlayerPrefs` de Unity, más el guardado automático del progreso
/// (algo que la versión de Unity no hacía: al salir de la escena se perdía todo
/// lo escrito).
class Settings extends ChangeNotifier {
  Settings._(this._prefs)
      : _lang = _prefs.getString(_kLang) ?? 'ES',
        _mode = (_prefs.getString(_kMode) ?? 'lenient') == 'strict'
            ? MatchMode.strict
            : MatchMode.lenient,
        _dark = _prefs.getBool(_kDark) ?? false;

  static const String _kLang = 'lang';
  static const String _kMode = 'match_mode';
  static const String _kDark = 'dark_mode';

  final SharedPreferences _prefs;
  String _lang;
  MatchMode _mode;
  bool _dark;

  static Future<Settings> load() async =>
      Settings._(await SharedPreferences.getInstance());

  String get lang => _lang;
  bool get isSpanish => _lang == 'ES';
  MatchMode get matchMode => _mode;

  /// Claro por defecto: las escenas de Unity eran blancas con texto #323232,
  /// que es lo que ya vieron los usuarios de la prueba cerrada.
  bool get darkMode => _dark;

  Future<void> setDarkMode(bool value) async {
    if (value == _dark) return;
    _dark = value;
    await _prefs.setBool(_kDark, value);
    notifyListeners();
  }

  Future<void> setLang(String value) async {
    if (value == _lang) return;
    _lang = value;
    await _prefs.setString(_kLang, value);
    notifyListeners();
  }

  Future<void> setMatchMode(MatchMode value) async {
    if (value == _mode) return;
    _mode = value;
    await _prefs.setString(_kMode, value == MatchMode.strict ? 'strict' : 'lenient');
    notifyListeners();
  }

  String _draftKey(String passageId, String lang) => 'draft:$passageId:$lang';

  /// Lo que el usuario lleva escrito, indexado por número de hueco.
  Map<int, String> loadDraft(String passageId, String lang) {
    final raw = _prefs.getString(_draftKey(passageId, lang));
    if (raw == null || raw.isEmpty) return <int, String>{};
    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(int.parse(k), v as String));
    } on FormatException {
      return <int, String>{};
    }
  }

  Future<void> saveDraft(
      String passageId, String lang, Map<int, String> answers) async {
    final cleaned = <String, String>{
      for (final entry in answers.entries)
        if (entry.value.trim().isNotEmpty) '${entry.key}': entry.value,
    };
    if (cleaned.isEmpty) {
      await _prefs.remove(_draftKey(passageId, lang));
    } else {
      await _prefs.setString(_draftKey(passageId, lang), json.encode(cleaned));
    }
    notifyListeners();
  }

  Future<void> clearDraft(String passageId, String lang) async {
    await _prefs.remove(_draftKey(passageId, lang));
    notifyListeners();
  }
}
