import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/core/models/survey/instructions.dart';
import 'package:patient_app/core/models/survey/question.dart';
import 'package:patient_app/core/models/survey/survey.dart';
import 'package:patient_app/features/survey/pages/survey_page.dart';

void main() {
  testWidgets('Survey page renders shared status bar', (tester) async {
    final survey = Survey(
      id: 'survey-1',
      surveyDisplayName: 'Questionário Demo',
      surveyName: 'Questionário Demo',
      surveyDescription: '',
      creatorId: 'creator',
      createdAt: DateTime(2024, 1, 1),
      modifiedAt: DateTime(2024, 1, 1),
      instructions: Instructions(
        preamble: '',
        questionText: 'Pergunta de instrução',
        answers: const ['Sim', 'Não'],
      ),
      questions: [
        Question(
          id: 1,
          questionText: 'Pergunta 1',
          answers: ['Resposta 1', 'Resposta 2'],
        ),
      ],
      promptAssociations: const [],
      finalNotes: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: SurveyPage(survey: survey),
      ),
    );

    expect(find.text('Pergunta 1'), findsOneWidget);
    expect(find.byType(DsScaffold), findsOneWidget);
    expect(find.text(dsSharedStatusBarText), findsOneWidget);
  });
}
