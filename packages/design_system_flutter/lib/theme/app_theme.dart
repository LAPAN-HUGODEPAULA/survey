import 'dart:ui';

import 'package:design_system_flutter/theme/color_palette.dart';
import 'package:design_system_flutter/theme/ds_tone_tokens.dart';
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
    return t < 0.5 ? this : other;
  }
}

@immutable
class LapanColorTokens extends ThemeExtension<LapanColorTokens> {
  const LapanColorTokens({
    required this.canvas,
    required this.primaryBase,
    required this.primaryBright,
    required this.secondaryTech,
    required this.tertiaryTech,
    required this.onPrimaryStrong,
    required this.focusFrame,
    required this.ghostOutline,
  });

  final Color canvas;
  final Color primaryBase;
  final Color primaryBright;
  final Color secondaryTech;
  final Color tertiaryTech;
  final Color onPrimaryStrong;
  final Color focusFrame;
  final Color ghostOutline;

  @override
  LapanColorTokens copyWith({
    Color? canvas,
    Color? primaryBase,
    Color? primaryBright,
    Color? secondaryTech,
    Color? tertiaryTech,
    Color? onPrimaryStrong,
    Color? focusFrame,
    Color? ghostOutline,
  }) {
    return LapanColorTokens(
      canvas: canvas ?? this.canvas,
      primaryBase: primaryBase ?? this.primaryBase,
      primaryBright: primaryBright ?? this.primaryBright,
      secondaryTech: secondaryTech ?? this.secondaryTech,
      tertiaryTech: tertiaryTech ?? this.tertiaryTech,
      onPrimaryStrong: onPrimaryStrong ?? this.onPrimaryStrong,
      focusFrame: focusFrame ?? this.focusFrame,
      ghostOutline: ghostOutline ?? this.ghostOutline,
    );
  }

  @override
  LapanColorTokens lerp(
    ThemeExtension<LapanColorTokens>? other,
    double t,
  ) {
    if (other is! LapanColorTokens) {
      return this;
    }
    return LapanColorTokens(
      canvas: Color.lerp(canvas, other.canvas, t) ?? canvas,
      primaryBase: Color.lerp(primaryBase, other.primaryBase, t) ?? primaryBase,
      primaryBright:
          Color.lerp(primaryBright, other.primaryBright, t) ?? primaryBright,
      secondaryTech:
          Color.lerp(secondaryTech, other.secondaryTech, t) ?? secondaryTech,
      tertiaryTech:
          Color.lerp(tertiaryTech, other.tertiaryTech, t) ?? tertiaryTech,
      onPrimaryStrong: Color.lerp(
            onPrimaryStrong,
            other.onPrimaryStrong,
            t,
          ) ??
          onPrimaryStrong,
      focusFrame: Color.lerp(focusFrame, other.focusFrame, t) ?? focusFrame,
      ghostOutline:
          Color.lerp(ghostOutline, other.ghostOutline, t) ?? ghostOutline,
    );
  }
}

@immutable
class LapanGradientTokens extends ThemeExtension<LapanGradientTokens> {
  const LapanGradientTokens({
    required this.primaryAction,
    required this.heroGlow,
  });

  final Gradient primaryAction;
  final Gradient heroGlow;

  @override
  LapanGradientTokens copyWith({
    Gradient? primaryAction,
    Gradient? heroGlow,
  }) {
    return LapanGradientTokens(
      primaryAction: primaryAction ?? this.primaryAction,
      heroGlow: heroGlow ?? this.heroGlow,
    );
  }

  @override
  LapanGradientTokens lerp(
    ThemeExtension<LapanGradientTokens>? other,
    double t,
  ) {
    if (other is! LapanGradientTokens) {
      return this;
    }
    return t < 0.5 ? this : other;
  }
}

@immutable
class LapanSurfaceTokens extends ThemeExtension<LapanSurfaceTokens> {
  const LapanSurfaceTokens({
    required this.floor,
    required this.surface,
    required this.low,
    required this.base,
    required this.high,
    required this.focusFrame,
    required this.glass,
  });

  final Color floor;
  final Color surface;
  final Color low;
  final Color base;
  final Color high;
  final Color focusFrame;
  final Color glass;

  @override
  LapanSurfaceTokens copyWith({
    Color? floor,
    Color? surface,
    Color? low,
    Color? base,
    Color? high,
    Color? focusFrame,
    Color? glass,
  }) {
    return LapanSurfaceTokens(
      floor: floor ?? this.floor,
      surface: surface ?? this.surface,
      low: low ?? this.low,
      base: base ?? this.base,
      high: high ?? this.high,
      focusFrame: focusFrame ?? this.focusFrame,
      glass: glass ?? this.glass,
    );
  }

  @override
  LapanSurfaceTokens lerp(
    ThemeExtension<LapanSurfaceTokens>? other,
    double t,
  ) {
    if (other is! LapanSurfaceTokens) {
      return this;
    }
    return LapanSurfaceTokens(
      floor: Color.lerp(floor, other.floor, t) ?? floor,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      low: Color.lerp(low, other.low, t) ?? low,
      base: Color.lerp(base, other.base, t) ?? base,
      high: Color.lerp(high, other.high, t) ?? high,
      focusFrame: Color.lerp(focusFrame, other.focusFrame, t) ?? focusFrame,
      glass: Color.lerp(glass, other.glass, t) ?? glass,
    );
  }
}

@immutable
class LapanSpacingTokens extends ThemeExtension<LapanSpacingTokens> {
  const LapanSpacingTokens({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.sectionGap,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double sectionGap;

  @override
  LapanSpacingTokens copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? sectionGap,
  }) {
    return LapanSpacingTokens(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      sectionGap: sectionGap ?? this.sectionGap,
    );
  }

  @override
  LapanSpacingTokens lerp(
    ThemeExtension<LapanSpacingTokens>? other,
    double t,
  ) {
    if (other is! LapanSpacingTokens) {
      return this;
    }
    return LapanSpacingTokens(
      xs: lerpDouble(xs, other.xs, t) ?? xs,
      sm: lerpDouble(sm, other.sm, t) ?? sm,
      md: lerpDouble(md, other.md, t) ?? md,
      lg: lerpDouble(lg, other.lg, t) ?? lg,
      xl: lerpDouble(xl, other.xl, t) ?? xl,
      sectionGap: lerpDouble(sectionGap, other.sectionGap, t) ?? sectionGap,
    );
  }
}

@immutable
class LapanInteractionTokens extends ThemeExtension<LapanInteractionTokens> {
  const LapanInteractionTokens({
    required this.hover,
    required this.focus,
    required this.pressed,
    required this.disabled,
  });

  final Color hover;
  final Color focus;
  final Color pressed;
  final Color disabled;

  @override
  LapanInteractionTokens copyWith({
    Color? hover,
    Color? focus,
    Color? pressed,
    Color? disabled,
  }) {
    return LapanInteractionTokens(
      hover: hover ?? this.hover,
      focus: focus ?? this.focus,
      pressed: pressed ?? this.pressed,
      disabled: disabled ?? this.disabled,
    );
  }

  @override
  LapanInteractionTokens lerp(
    ThemeExtension<LapanInteractionTokens>? other,
    double t,
  ) {
    if (other is! LapanInteractionTokens) {
      return this;
    }
    return LapanInteractionTokens(
      hover: Color.lerp(hover, other.hover, t) ?? hover,
      focus: Color.lerp(focus, other.focus, t) ?? focus,
      pressed: Color.lerp(pressed, other.pressed, t) ?? pressed,
      disabled: Color.lerp(disabled, other.disabled, t) ?? disabled,
    );
  }
}

class AppTheme {
  static const Color _floor = Color(0xFF57595C);
  static const Color _surface = Color(0xFF5D5F62);
  static const Color _surfaceLow = Color(0xFF5B5D60);
  static const Color _surfaceBase = Color(0xFF696B6E);
  static const Color _surfaceHigh = Color(0xFF6A6C6F);
  static const Color _surfaceFocus = Color(0xFF6B6D70);
  static const Color _primary = Color(0xFFF38A2E);
  static const Color _primaryBright = Color(0xFFFFB783);
  static const Color _onPrimary = Color(0xFF4F2500);
  static const Color _onSurface = Color(0xFFF0F0F3);
  static const Color _onSurfaceVariant = Color(0xFFE0D7D0);
  static const Color _secondary = Color(0xFFB5C8DF);
  static const Color _tertiary = Color(0xFF86CFFF);
  static const Color _outlineVariant = Color(0xFF564337);

  static ThemeData dark() {
    final colorScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: _primaryBright,
      onPrimary: _onPrimary,
      secondary: _secondary,
      onSecondary: _floor,
      tertiary: _tertiary,
      onTertiary: _floor,
      error: Color(0xFFFF8D7C),
      onError: _floor,
      surface: _surface,
      onSurface: _onSurface,
      outline: _outlineVariant,
      outlineVariant: _outlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: _onSurface,
      onInverseSurface: _surface,
      inversePrimary: _primary,
      surfaceTint: Colors.transparent,
    ).copyWith(
      primaryContainer: _primary,
      onPrimaryContainer: _onPrimary,
      secondaryContainer: const Color(0xFF2A3642),
      onSecondaryContainer: _onSurface,
      tertiaryContainer: const Color(0xFF173449),
      onTertiaryContainer: _onSurface,
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surfaceContainerLowest: _floor,
      surfaceContainerLow: _surfaceLow,
      surfaceContainer: _surfaceBase,
      surfaceContainerHigh: _surfaceHigh,
      surfaceContainerHighest: _surfaceFocus,
      onSurfaceVariant: _onSurfaceVariant,
    );

    final baseTextTheme = _buildTextTheme();
    final interactionTokens = LapanInteractionTokens(
      hover: _primaryBright.withValues(alpha: 0.10),
      focus: _primaryBright.withValues(alpha: 0.18),
      pressed: _primary.withValues(alpha: 0.22),
      disabled: _onSurface.withValues(alpha: 0.38),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: baseTextTheme,
      primaryTextTheme: baseTextTheme,
      scaffoldBackgroundColor: _floor,
      canvasColor: _floor,
      splashFactory: InkSparkle.splashFactory,
      focusColor: interactionTokens.focus,
      hoverColor: interactionTokens.hover,
      highlightColor: interactionTokens.pressed,
      dividerColor: Colors.transparent,
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHigh,
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: _onSurfaceVariant.withValues(alpha: 0.12),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        contentTextStyle: baseTextTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: baseTextTheme.headlineSmall?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        hintStyle: baseTextTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.82),
        ),
        labelStyle: baseTextTheme.labelLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        border: _inputBorder(Colors.transparent),
        enabledBorder: _inputBorder(Colors.transparent),
        focusedBorder: _inputBorder(_primaryBright, width: 2),
        errorBorder: _inputBorder(colorScheme.error),
        focusedErrorBorder: _inputBorder(colorScheme.error, width: 2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: _onPrimary,
          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          disabledForegroundColor: interactionTokens.disabled,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: baseTextTheme.labelLarge?.copyWith(
            color: _onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: _onPrimary,
          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          disabledForegroundColor: interactionTokens.disabled,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: baseTextTheme.labelLarge?.copyWith(
            color: _onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          backgroundColor: Color.alphaBlend(
            _primaryBright.withValues(alpha: 0.18),
            _surfaceHigh,
          ),
          side: BorderSide(
            color: _primaryBright.withValues(alpha: 0.84),
            width: 1.5,
          ),
          foregroundColor: _onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: baseTextTheme.labelLarge?.copyWith(
            color: _onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 44),
          foregroundColor: _onSurface,
          backgroundColor: Color.alphaBlend(
            _primaryBright.withValues(alpha: 0.12),
            _surfaceBase,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: baseTextTheme.labelLarge?.copyWith(
            color: _onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primaryBright,
        linearTrackColor: _surfaceHigh,
        circularTrackColor: _surfaceHigh,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        selectedColor: _primary.withValues(alpha: 0.28),
        disabledColor: colorScheme.surfaceContainerHighest,
        secondarySelectedColor: _primaryBright.withValues(alpha: 0.24),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        labelStyle: baseTextTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        secondaryLabelStyle: baseTextTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        side: BorderSide(
          color: _onSurfaceVariant.withValues(alpha: 0.12),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _surface.withValues(alpha: 0.92),
        shadowColor: Colors.black.withValues(alpha: 0.25),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: _outlineVariant.withValues(alpha: 0.15)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        const SurveyOptionColors(palette: ColorPalette.diagnosticScale),
        const LapanColorTokens(
          canvas: _floor,
          primaryBase: _primary,
          primaryBright: _primaryBright,
          secondaryTech: _secondary,
          tertiaryTech: _tertiary,
          onPrimaryStrong: _onPrimary,
          focusFrame: _surfaceFocus,
          ghostOutline: _outlineVariant,
        ),
        const LapanSurfaceTokens(
          floor: _floor,
          surface: _surface,
          low: _surfaceLow,
          base: _surfaceBase,
          high: _surfaceHigh,
          focusFrame: _surfaceFocus,
          glass: Color(0xCC121416),
        ),
        const LapanSpacingTokens(
          xs: 4,
          sm: 8,
          md: 16,
          lg: 24,
          xl: 32,
          sectionGap: 24,
        ),
        interactionTokens,
        const LapanGradientTokens(
          primaryAction: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primaryBright, _primary],
          ),
          heroGlow: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x33FFB783), Color(0x00121416)],
          ),
        ),
        DsToneTokens.fromProfile(DsToneProfile.professional),
      ],
    );
  }

  static InputBorder _inputBorder(Color color, {double width = 1}) {
    return UnderlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme _buildTextTheme() {
    final base =
        Typography.material2021(platform: TargetPlatform.android).white.apply(
              bodyColor: _onSurface,
              displayColor: _onSurface,
              fontFamily: 'Manrope',
            );

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.4,
        height: 1.02,
        color: _primaryBright,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.1,
        height: 1.05,
        color: _primaryBright,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.1,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.15,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.2,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.2,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontWeight: FontWeight.w500,
        color: _onSurface,
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: _onSurface,
        height: 1.45,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontWeight: FontWeight.w500,
        color: _onSurfaceVariant,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.7,
        color: _onSurface,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: _onSurfaceVariant,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
        color: _onSurfaceVariant,
      ),
    );
  }
}
