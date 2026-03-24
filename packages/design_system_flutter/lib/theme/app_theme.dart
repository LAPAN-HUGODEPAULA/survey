import 'package:design_system_flutter/theme/color_palette.dart';
import 'package:flutter/material.dart';

@immutable
class SurveyOptionColors extends ThemeExtension<SurveyOptionColors> {
  const SurveyOptionColors({
    required this.palette,
  });

  final List<Color> palette;

  @override
  SurveyOptionColors copyWith({List<Color>? palette}) {
    return SurveyOptionColors(
      palette: palette ?? this.palette,
    );
  }

  @override
  SurveyOptionColors lerp(ThemeExtension<SurveyOptionColors>? other, double t) {
    if (other is! SurveyOptionColors) {
      return this;
    }
    // For simplicity, we're not interpolating colors in the palette.
    // In a real-world scenario, you might want to lerp each color individually.
    return t < 0.5 ? this : other;
  }
}

class AppTheme {
  static ThemeData light() {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: baseScheme.copyWith(
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onTertiary: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.white,
      focusColor: Colors.orange.withOpacity(0.15),
      hoverColor: Colors.orange.withOpacity(0.08),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.black,
          minimumSize: const Size(0, 48),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.black,
          minimumSize: const Size(0, 44),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),
          side: const BorderSide(color: Colors.orange),
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 44),
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.orange,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        SurveyOptionColors(
          palette: ColorPalette.greenToRed,
        ),
      ],
    );
  }
}
