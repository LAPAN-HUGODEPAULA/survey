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
    testWidgets('uses color from theme', (WidgetTester tester) async {
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
      final expectedColor = AppTheme.dark()
          .extension<SurveyOptionColors>()!
          .palette[optionIndex]
          .withValues(alpha: 0.8);

      expect(button.style?.backgroundColor?.resolve({}), expectedColor);
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
}
