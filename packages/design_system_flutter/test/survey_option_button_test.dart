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
          theme: AppTheme.light(),
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
      final expectedColor = AppTheme.light()
          .extension<SurveyOptionColors>()!
          .palette[optionIndex]
          .withValues(alpha: 0.8);

      expect(button.style?.backgroundColor?.resolve({}), expectedColor);
    });
  });

  group('AppTheme', () {
    test('light theme has SurveyOptionColors extension', () {
      final theme = AppTheme.light();
      final surveyOptionColors = theme.extension<SurveyOptionColors>();

      expect(surveyOptionColors, isNotNull);
      expect(surveyOptionColors, isA<SurveyOptionColors>());
    });

    test('SurveyOptionColors extension has the correct palette', () {
      final theme = AppTheme.light();
      final surveyOptionColors = theme.extension<SurveyOptionColors>();

      expect(surveyOptionColors!.palette, equals(ColorPalette.greenToRed));
    });

    test('light theme uses a soft gray background with readable contrast', () {
      final theme = AppTheme.light();
      final background = theme.scaffoldBackgroundColor;
      final onSurface = theme.colorScheme.onSurface;

      expect(background, isNot(equals(Colors.white)));
      expect(_contrastRatio(onSurface, background), greaterThan(7));
    });

    testWidgets('DsStatusBar renders the shared copyright text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
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
          theme: AppTheme.light(),
          home: const DsScaffold(
            title: 'Demo',
            body: Text('Body'),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      expect(find.text(dsSharedStatusBarText), findsOneWidget);
    });
  });
}
