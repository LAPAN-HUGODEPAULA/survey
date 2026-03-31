import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/core/models/survey/instructions.dart';
import 'package:patient_app/core/models/survey/question.dart';
import 'package:patient_app/core/models/survey/survey.dart';
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:patient_app/features/survey/pages/thank_you_page.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('ThankYouPage shows summary and CTA buttons', (tester) async {
    final survey = Survey(
      id: 'survey-1',
      surveyDisplayName: 'Survey Demo',
      surveyName: 'Survey Demo',
      surveyDescription: '',
      creatorId: 'Creator',
      createdAt: DateTime(2024, 1, 1),
      modifiedAt: DateTime(2024, 1, 2),
      instructions: Instructions(
        preamble: '<p>Intro</p>',
        questionText: 'Q',
        answers: const ['A', 'B'],
      ),
      questions: [
        Question(id: 1, questionText: 'Pergunta 1', answers: ['A', 'B']),
        Question(id: 2, questionText: 'Pergunta 2', answers: ['A', 'B']),
      ],
      prompt: null,
      finalNotes: null,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppSettings(),
        child: MaterialApp(
          home: ThankYouPage(
            survey: survey,
            surveyAnswers: const ['A', 'B'],
            surveyQuestions: survey.questions,
            skipAgentFetch: true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Radar das respostas'), findsOneWidget);
    expect(find.text('Avaliação preliminar'), findsOneWidget);
    expect(find.text('Adicionar Informações'), findsOneWidget);
    expect(find.text('Iniciar nova avaliação'), findsOneWidget);
  });
}
