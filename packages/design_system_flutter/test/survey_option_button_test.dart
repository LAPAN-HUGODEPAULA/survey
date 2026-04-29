import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:design_system_flutter/theme/color_palette.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('SurveyOptionButton', () {
    testWidgets('uses gradient colors derived from theme', (
      WidgetTester tester,
    ) async {
      const optionIndex = 0;
      const optionCount = 5;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: SurveyOptionButton(
              text: 'Option 1',
              onPressed: () {},
              optionIndex: optionIndex,
              optionCount: optionCount,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final baseColor =
          AppTheme.dark().extension<SurveyOptionColors>()!.palette[optionIndex];
      final hsl = HSLColor.fromColor(baseColor);
      final expectedBottomColor =
          hsl.withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0)).toColor();

      final ink = tester.widget<Ink>(find.byType(Ink));
      final decoration = ink.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      expect(button.style?.backgroundColor?.resolve({}), Colors.transparent);
      expect(gradient.begin, Alignment.topLeft);
      expect(gradient.end, Alignment.bottomRight);
      expect(gradient.colors.first, baseColor);
      expect(gradient.colors.last, expectedBottomColor);
    });
  });

  group('AppTheme', () {
    test('dark theme has SurveyOptionColors extension', () {
      final theme = AppTheme.dark();
      final surveyOptionColors = theme.extension<SurveyOptionColors>();

      expect(surveyOptionColors, isNotNull);
      expect(surveyOptionColors, isA<SurveyOptionColors>());
    });

    test('SurveyOptionColors extension has the correct palette', () {
      final theme = AppTheme.dark();
      final surveyOptionColors = theme.extension<SurveyOptionColors>();

      expect(surveyOptionColors!.palette, equals(ColorPalette.diagnosticScale));
    });

    test('dark theme uses a noble gray background with readable contrast', () {
      final theme = AppTheme.dark();
      final background = theme.scaffoldBackgroundColor;
      final onSurface = theme.colorScheme.onSurface;

      expect(background, equals(const Color(0xFF57595C)));
      expect(_contrastRatio(onSurface, background), greaterThan(4.5));
    });

    test('dark theme exposes LAPAN design tokens', () {
      final theme = AppTheme.dark();

      expect(theme.extension<LapanColorTokens>(), isNotNull);
      expect(theme.extension<LapanSurfaceTokens>(), isNotNull);
      expect(theme.extension<LapanGradientTokens>(), isNotNull);
      expect(theme.extension<LapanSpacingTokens>(), isNotNull);
      expect(theme.extension<LapanInteractionTokens>(), isNotNull);
      expect(theme.textTheme.bodyMedium?.fontFamily, 'Manrope');
      expect(theme.colorScheme.primaryContainer, const Color(0xFFF38A2E));
      expect(theme.colorScheme.onSurface, const Color(0xFFF0F0F3));
      expect(theme.colorScheme.onSurfaceVariant, const Color(0xFFE0D7D0));
    });

    testWidgets('DsStatusBar renders the shared copyright text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(bottomNavigationBar: DsStatusBar()),
        ),
      );

      expect(find.text(dsSharedStatusBarText), findsOneWidget);
    });

    testWidgets('DsScaffold composes app bar body and shared footer', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const DsScaffold(
            title: 'Demo',
            body: Text('Body'),
          ),
        ),
      );

      expect(find.byType(DsPageHeader), findsOneWidget);
      expect(find.text('Demo'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      expect(find.text(dsSharedStatusBarText), findsOneWidget);
    });
  });

  group('DsSurveyProgressIndicator', () {
    testWidgets('supports includeSuccessPage endowment progression', (
      WidgetTester tester,
    ) async {
      Future<double?> pumpProgress({
        required int currentIndex,
        required int total,
        required bool includeSuccessPage,
      }) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DsSurveyProgressIndicator(
                currentIndex: currentIndex,
                total: total,
                includeSuccessPage: includeSuccessPage,
              ),
            ),
          ),
        );
        return tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value;
      }

      expect(
        await pumpProgress(
          currentIndex: 0,
          total: 10,
          includeSuccessPage: true,
        ),
        closeTo(1 / 11, 0.0001),
      );
      expect(
        await pumpProgress(
          currentIndex: 9,
          total: 10,
          includeSuccessPage: true,
        ),
        closeTo(10 / 11, 0.0001),
      );
      expect(
        await pumpProgress(
          currentIndex: 10,
          total: 10,
          includeSuccessPage: true,
        ),
        1.0,
      );
      expect(
        await pumpProgress(
          currentIndex: 9,
          total: 10,
          includeSuccessPage: false,
        ),
        1.0,
      );
    });

    testWidgets('applies a minimum visible progress in endowment mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DsSurveyProgressIndicator(
              currentIndex: 0,
              total: 200,
              includeSuccessPage: true,
            ),
          ),
        ),
      );

      final value = tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value;
      expect(value, 0.02);
    });
  });
}
