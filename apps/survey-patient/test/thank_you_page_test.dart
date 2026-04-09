import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/core/models/survey/instructions.dart';
import 'package:patient_app/core/models/survey/question.dart';
import 'package:patient_app/core/models/survey/survey.dart';
import 'package:patient_app/core/models/survey_response.dart' as survey_ui;
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:patient_app/core/repositories/survey_repository.dart';
import 'package:patient_app/features/survey/pages/thank_you_page.dart';
import 'package:provider/provider.dart';

class _FakeSurveyRepository extends SurveyRepository {
  _FakeSurveyRepository();

  int _statusCalls = 0;

  @override
  Future<survey_ui.SurveyResponse> submitResponse(
    survey_ui.SurveyResponse response,
  ) async {
    return survey_ui.SurveyResponse(
      id: 'PROTO-123',
      surveyId: response.surveyId,
      creatorId: response.creatorId,
      testDate: response.testDate,
      screenerId: response.screenerId,
      promptKey: response.promptKey,
      patient: response.patient,
      answers: response.answers,
    );
  }

  @override
  Future<Map<String, dynamic>> startClinicalWriterTask(
    String content, {
    String? promptKey,
  }) async {
    return <String, dynamic>{
      'taskId': 'task-1',
      'aiProgress': <String, dynamic>{
        'stage': 'organizing_data',
        'stageLabel': 'Organizando dados do caso',
      },
    };
  }

  @override
  Future<Map<String, dynamic>> getClinicalWriterTaskStatus(
    String taskId,
  ) async {
    _statusCalls += 1;
    if (_statusCalls == 1) {
      return <String, dynamic>{
        'status': 'processing',
        'aiProgress': <String, dynamic>{
          'stage': 'analyzing_signals',
          'stageLabel': 'Análise preliminar em preparo',
        },
      };
    }

    return <String, dynamic>{
      'status': 'completed',
      'result': <String, dynamic>{
        'medicalRecord':
            'Síntese inicial: os sinais sugerem atenção ao conforto visual.',
        'aiProgress': <String, dynamic>{
          'stage': 'reviewing_content',
          'stageLabel': 'Relatório disponível',
        },
      },
    };
  }
}

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
          theme: AppTheme.dark(),
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
    expect(find.text('Adicionar informações'), findsOneWidget);
    expect(find.text('Iniciar nova avaliação'), findsOneWidget);
  });

  testWidgets(
    'ThankYouPage handoff shows protocol only after registration and then reveals clinical content',
    (tester) async {
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
        ],
        prompt: null,
        finalNotes: null,
      );

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppSettings(),
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: ThankYouPage(
              survey: survey,
              surveyAnswers: const ['A'],
              surveyQuestions: survey.questions,
              surveyRepository: _FakeSurveyRepository(),
            ),
          ),
        ),
      );

      expect(find.text('PROTO-123'), findsNothing);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('PROTO-123'), findsOneWidget);
      expect(
        find.text(
          'Sua avaliação foi salva. Este código identifica o atendimento para futuras consultas:',
        ),
        findsOneWidget,
      );
      expect(find.text('Análise preliminar em preparo'), findsWidgets);

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Relatório disponível'), findsOneWidget);
      expect(
        find.textContaining('Síntese inicial: os sinais sugerem atenção'),
        findsOneWidget,
      );
    },
  );
}
