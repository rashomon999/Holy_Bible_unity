import 'package:flutter/material.dart';

/// Paleta azul de la app.
///
/// Las escenas de Unity usaban fondo blanco con texto #323232, así que el tema
/// claro es el que manda: es el que ya conocen tus usuarios. El oscuro es azul
/// marino, no negro.
class AppColors {
  static const Color blue = Color(0xFF1B5FA8);
  static const Color blueDeep = Color(0xFF12457C);
  static const Color blueLight = Color(0xFF4C8FD6);
  static const Color blueSoft = Color(0xFFE7F0FA);

  static const Color canvasLight = Color(0xFFF3F7FC);
  static const Color inkLight = Color(0xFF1F2A37);

  static const Color canvasDark = Color(0xFF0E1826);
  static const Color surfaceDark = Color(0xFF16233A);
  static const Color inkDark = Color(0xFFE6EDF6);

  static const Color correct = Color(0xFF2E7D32);
  static const Color correctDark = Color(0xFF7BC47F);
}

ThemeData buildTheme(Brightness brightness) =>
    brightness == Brightness.dark ? _dark() : _light();

ThemeData _light() {
  const scheme = ColorScheme.light(
    primary: AppColors.blue,
    onPrimary: Colors.white,
    primaryContainer: AppColors.blueSoft,
    onPrimaryContainer: AppColors.blueDeep,
    secondary: AppColors.blueLight,
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: AppColors.inkLight,
    error: Color(0xFFC0392B),
    onError: Colors.white,
    errorContainer: Color(0xFFFDECEA),
    onErrorContainer: Color(0xFF8C2A1E),
    outline: Color(0xFFB6C6DA),
    outlineVariant: Color(0xFFCBD8E7),
  );
  return _base(scheme).copyWith(
    scaffoldBackgroundColor: AppColors.canvasLight,
  );
}

ThemeData _dark() {
  const scheme = ColorScheme.dark(
    primary: Color(0xFF7FB3F0),
    onPrimary: Color(0xFF06203C),
    primaryContainer: Color(0xFF1D3557),
    onPrimaryContainer: Color(0xFFD7E7FA),
    secondary: Color(0xFF9CC6F5),
    onSecondary: Color(0xFF06203C),
    surface: AppColors.surfaceDark,
    onSurface: AppColors.inkDark,
    error: Color(0xFFFF8A80),
    onError: Color(0xFF3B0906),
    errorContainer: Color(0xFF4A1A15),
    onErrorContainer: Color(0xFFFFD9D4),
    outline: Color(0xFF44597A),
    outlineVariant: Color(0xFF33465F),
  );
  return _base(scheme).copyWith(
    scaffoldBackgroundColor: AppColors.canvasDark,
  );
}

ThemeData _base(ColorScheme scheme) {
  final bool isLight = scheme.brightness == Brightness.light;
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    appBarTheme: AppBarTheme(
      backgroundColor: isLight ? AppColors.blue : AppColors.surfaceDark,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        minimumSize: const Size(0, 50),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.primary.withOpacity(0.5)),
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: scheme.primary),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: isLight ? AppColors.blueSoft : const Color(0xFF22344F),
    ),
  );
}

/// Verde de "correcto" adaptado al brillo actual.
Color correctColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? AppColors.correctDark
        : AppColors.correct;

/// Tamaño base del texto del pasaje. El alto de los huecos, su ancho mínimo y
/// la separación entre líneas se derivan de aquí.
const double kPassageFontSize = 18;
