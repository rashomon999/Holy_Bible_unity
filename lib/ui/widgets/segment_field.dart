import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

enum SegmentStatus { untouched, correct, wrong }

/// Un hueco del cuestionario.
///
/// El ancho NO está escrito a mano: se mide la frase esperada con un
/// [TextPainter] y el campo toma ese ancho (con un mínimo y un máximo). Esa era
/// la parte que en Unity tocaba ajustar campo por campo en el Inspector; aquí
/// una frase larga produce un campo largo automáticamente, y si no cabe en la
/// línea el campo ocupa el ancho disponible y hace wrap.
class SegmentField extends StatelessWidget {
  const SegmentField({
    super.key,
    required this.number,
    required this.controller,
    required this.expected,
    required this.maxWidth,
    required this.status,
    required this.textStyle,
    this.onChanged,
  });

  final int number;
  final TextEditingController controller;
  final String expected;
  final double maxWidth;
  final SegmentStatus status;
  final TextStyle textStyle;
  final ValueChanged<String>? onChanged;

  static const double _minWidth = 90;
  static const double _horizontalPadding = 18;

  double _measure() {
    final painter = TextPainter(
      text: TextSpan(text: expected, style: textStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width + _horizontalPadding;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final natural = _measure();
    final width = math.max(_minWidth, math.min(natural, maxWidth));
    final wraps = natural > maxWidth;

    final Color accent = switch (status) {
      SegmentStatus.correct => correctColor(context),
      SegmentStatus.wrong => scheme.error,
      SegmentStatus.untouched => scheme.outline,
    };
    final Color fill = switch (status) {
      SegmentStatus.correct => correctColor(context).withOpacity(0.08),
      SegmentStatus.wrong => scheme.error.withOpacity(0.07),
      SegmentStatus.untouched => scheme.primary.withOpacity(0.045),
    };

    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: textStyle,
        maxLines: wraps ? null : 1,
        minLines: 1,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.sentences,
        cursorColor: scheme.primary,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: fill,
          hintText: '$number',
          hintStyle: textStyle.copyWith(
            color: scheme.outline,
            fontSize: textStyle.fontSize! * 0.75,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          enabledBorder: UnderlineInputBorder(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            borderSide: BorderSide(color: accent, width: 1.4),
          ),
          focusedBorder: UnderlineInputBorder(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            borderSide: BorderSide(color: scheme.primary, width: 2),
          ),
          suffixIcon: status == SegmentStatus.wrong
              ? Icon(Icons.close, size: 16, color: scheme.error)
              : null,
          suffixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }
}
