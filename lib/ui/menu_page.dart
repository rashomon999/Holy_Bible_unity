import 'package:flutter/material.dart';

import '../data/passage_repository.dart';
import '../l10n/strings.dart';
import '../services/settings.dart';
import '../util/normalize.dart';
import 'quiz_page.dart';
import 'theme.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key, required this.repository, required this.settings});

  final PassageRepository repository;
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lang = settings.lang;
    final strings = Strings.of(lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings['appTitle']),
        actions: [
          IconButton(
            tooltip: strings['settings'],
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () => _openSettings(context, strings),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Banda azul de encabezado: idioma + subtítulo.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              decoration: BoxDecoration(
                color: theme.appBarTheme.backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(22),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings['menuSubtitle'],
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 14),
                  _LanguagePicker(
                    lang: lang,
                    onChanged: (value) => settings.setLang(value),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
              child: Column(
                children: [
                  // Los 6 pasajes salen del JSON. Agregar uno no toca este archivo.
                  for (final passage in repository.passages)
                    _PassageTile(
                      title: passage.localized(lang).title,
                      total: passage.localized(lang).segments.length,
                      done: _progress(
                        passage.id,
                        lang,
                        passage
                            .localized(lang)
                            .segments
                            .map((s) => MapEntry(s.index, s.answer)),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              QuizPage(passage: passage, settings: settings),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: scheme.brightness == Brightness.light
          ? AppColors.canvasLight
          : AppColors.canvasDark,
    );
  }

  /// Cuántas frases del borrador guardado coinciden con la respuesta correcta.
  int _progress(
      String id, String lang, Iterable<MapEntry<int, String>> expected) {
    final draft = settings.loadDraft(id, lang);
    if (draft.isEmpty) return 0;
    var count = 0;
    for (final entry in expected) {
      final typed = draft[entry.key];
      if (typed != null &&
          answersMatch(typed, entry.value, mode: settings.matchMode)) {
        count++;
      }
    }
    return count;
  }

  void _openSettings(BuildContext context, Strings strings) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListenableBuilder(
          listenable: settings,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.spellcheck),
                title: Text(strings['strictTitle']),
                subtitle: Text(strings['strictSubtitle']),
                value: settings.matchMode == MatchMode.strict,
                onChanged: (v) => settings
                    .setMatchMode(v ? MatchMode.strict : MatchMode.lenient),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: Text(strings['darkTitle']),
                subtitle: Text(strings['darkSubtitle']),
                value: settings.darkMode,
                onChanged: settings.setDarkMode,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({required this.lang, required this.onChanged});

  final String lang;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _option('ES', 'Español'),
          const SizedBox(width: 4),
          _option('EN', 'English'),
        ],
      ),
    );
  }

  Widget _option(String value, String label) {
    final selected = value == lang;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.blue : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _PassageTile extends StatelessWidget {
  const _PassageTile({
    required this.title,
    required this.total,
    required this.done,
    required this.onTap,
  });

  final String title;
  final int total;
  final int done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ratio = total == 0 ? 0.0 : done / total;
    final complete = total > 0 && done == total;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    complete ? Icons.check : Icons.menu_book_outlined,
                    color: complete
                        ? correctColor(context)
                        : scheme.onPrimaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 6,
                          color: complete ? correctColor(context) : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$done / $total',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.outline),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: scheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
