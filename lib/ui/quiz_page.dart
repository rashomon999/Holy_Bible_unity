import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/passage.dart';
import '../services/settings.dart';
import '../util/normalize.dart';
import 'theme.dart';
import 'widgets/segment_field.dart';

/// UNA sola pantalla para los 12 cuestionarios.
///
/// En Unity había una escena por pasaje y por idioma, cada una con su propio
/// script de ~200 líneas repetidas. Aquí el pasaje entra como parámetro.
class QuizPage extends StatefulWidget {
  const QuizPage({
    super.key,
    required this.passage,
    required this.settings,
  });

  final Passage passage;
  final Settings settings;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late String _lang;
  late PassageLocale _locale;
  late List<TextEditingController> _controllers;
  late List<SegmentStatus> _statuses;
  Timer? _saveTimer;
  String? _message;
  bool _messageIsError = false;

  @override
  void initState() {
    super.initState();
    _lang = widget.settings.lang;
    _bind();
  }

  void _bind() {
    _locale = widget.passage.localized(_lang);
    final draft = widget.settings.loadDraft(widget.passage.id, _lang);
    _controllers = _locale.segments
        .map((s) => TextEditingController(text: draft[s.index] ?? ''))
        .toList(growable: false);
    _statuses = List<SegmentStatus>.filled(
        _locale.segments.length, SegmentStatus.untouched);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _flushSave();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 600), _flushSave);
  }

  void _flushSave() {
    final answers = <int, String>{
      for (var i = 0; i < _locale.segments.length; i++)
        _locale.segments[i].index: _controllers[i].text,
    };
    widget.settings.saveDraft(widget.passage.id, _lang, answers);
  }

  /// Equivalente a `Verificar()`, pero en un bucle en vez de 30 llamadas
  /// escritas a mano. Los huecos vacíos se ignoran, igual que en Unity.
  void _verify() {
    final mode = widget.settings.matchMode;
    final wrong = <int>[];
    var typed = 0;

    final next = <SegmentStatus>[];
    for (var i = 0; i < _locale.segments.length; i++) {
      final segment = _locale.segments[i];
      final text = _controllers[i].text;
      if (text.trim().isEmpty) {
        next.add(SegmentStatus.untouched);
        continue;
      }
      typed++;
      if (answersMatch(text, segment.answer, mode: mode)) {
        next.add(SegmentStatus.correct);
      } else {
        next.add(SegmentStatus.wrong);
        wrong.add(segment.index);
      }
    }

    final strings = Strings.of(_lang);
    setState(() {
      _statuses = next;
      if (typed == 0) {
        _message = strings['nothingTyped'];
        _messageIsError = false;
      } else if (wrong.isEmpty) {
        _message = strings['allCorrect'];
        _messageIsError = false;
      } else {
        _message = '${strings['someWrong']}${wrong.join(', ')}';
        _messageIsError = true;
      }
    });
    _flushSave();
  }

  void _showAnswers() {
    setState(() {
      for (var i = 0; i < _locale.segments.length; i++) {
        _controllers[i].text = _locale.segments[i].answer;
        _statuses[i] = SegmentStatus.correct;
      }
      _message = null;
    });
    _flushSave();
  }

  Future<void> _clear() async {
    final strings = Strings.of(_lang);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(strings['clearConfirm']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings['cancel']),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings['confirm']),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() {
      for (final c in _controllers) {
        c.clear();
      }
      _statuses = List<SegmentStatus>.filled(
          _locale.segments.length, SegmentStatus.untouched);
      _message = null;
    });
    await widget.settings.clearDraft(widget.passage.id, _lang);
  }

  void _switchLanguage(String lang) {
    if (lang == _lang) return;
    _flushSave();
    for (final c in _controllers) {
      c.dispose();
    }
    setState(() {
      _lang = lang;
      _message = null;
      _bind();
    });
    widget.settings.setLang(lang);
  }

  int get _correctCount =>
      _statuses.where((s) => s == SegmentStatus.correct).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final strings = Strings.of(_lang);
    final textStyle = theme.textTheme.bodyLarge!.copyWith(
      fontSize: kPassageFontSize,
      height: 1.5,
      color: scheme.onSurface,
    );

    return Scaffold(
      backgroundColor:
          isLight ? AppColors.canvasLight : AppColors.canvasDark,
      appBar: AppBar(
        title: Text(_locale.title),
        actions: [
          for (final code in const ['ES', 'EN'])
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: TextButton(
                onPressed: () => _switchLanguage(code),
                style: TextButton.styleFrom(
                  minimumSize: const Size(44, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  backgroundColor: _lang == code
                      ? Colors.white.withOpacity(0.22)
                      : Colors.transparent,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  code,
                  style: TextStyle(
                    fontWeight:
                        _lang == code ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 32 de padding externo + 32 de padding de la tarjeta.
                  final maxWidth = constraints.maxWidth - 64;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: _PassageCard(
                      progressLabel:
                          '$_correctCount / ${_locale.segments.length} ${strings['progress']}',
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        spacing: 4,
                        runSpacing: 12,
                        children: [
                          for (var i = 0; i < _locale.segments.length; i++) ...[
                            SegmentField(
                              number: _locale.segments[i].index,
                              controller: _controllers[i],
                              expected: _locale.segments[i].answer,
                              maxWidth: maxWidth,
                              status: _statuses[i],
                              textStyle: textStyle,
                              onChanged: (_) => _scheduleSave(),
                            ),
                            if (_locale.segments[i].punct.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  _locale.segments[i].punct,
                                  style: textStyle.copyWith(
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_message != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _messageIsError
                      ? scheme.errorContainer
                      : scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _messageIsError
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      size: 20,
                      color: _messageIsError
                          ? scheme.onErrorContainer
                          : scheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _message!,
                        style: TextStyle(
                          color: _messageIsError
                              ? scheme.onErrorContainer
                              : scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _verify,
                      icon: const Icon(Icons.check),
                      label: Text(strings['verify']),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _RoundAction(
                    tooltip: strings['showAnswers'],
                    icon: Icons.visibility_outlined,
                    onPressed: _showAnswers,
                  ),
                  const SizedBox(width: 8),
                  _RoundAction(
                    tooltip: strings['clear'],
                    icon: Icons.delete_outline,
                    onPressed: _clear,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PassageCard extends StatelessWidget {
  const _PassageCard({required this.progressLabel, required this.child});

  final String progressLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              progressLabel,
              style: TextStyle(
                color: scheme.onPrimaryContainer,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: scheme.onPrimaryContainer),
          constraints: const BoxConstraints(minWidth: 50, minHeight: 50),
        ),
      ),
    );
  }
}
