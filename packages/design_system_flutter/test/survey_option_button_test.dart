import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:design_system_flutter/theme/color_palette.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
          .withOpacity(0.8);

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
  });
}