import 'package:design_system_flutter/report/report_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:patient_app/core/models/agent_response.dart';
import 'package:patient_app/core/models/survey/instructions.dart';
import 'package:patient_app/core/models/survey/question.dart';
import 'package:patient_app/core/models/survey/survey.dart';
import 'package:patient_app/core/models/survey_response.dart';
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:patient_app/core/repositories/survey_repository.dart';
import 'package:patient_app/features/report/pages/report_page.dart';
import 'package:survey_backend_api/survey_backend_api.dart' as api;

class _FakeSurveyRepository extends SurveyRepository {
  _FakeSurveyRepository()
      : super(
          apiClient: api.DefaultApi(
            Dio(BaseOptions(baseUrl: 'http://localhost')),
            api.standardSerializers,
          ),
          rawClient: Dio(BaseOptions(baseUrl: 'http://localhost')),
        );

  @override
  Future<SurveyResponse> submitResponse(SurveyResponse response) async {
    final report = ReportDocument.fromPlainText(
      text: 'Conteudo do relatorio',
      title: 'Relatorio',
    );
    return response.copyWith(
      id: 'resp-1',
      agentResponse: AgentResponse(report: report),
    );
  }

  @override
  Future<AgentResponse> processClinicalWriter(String content) async {
    return AgentResponse(report: ReportDocument.fromPlainText(text: content, title: 'Relatorio'));
  }
}

void main() {
  testWidgets('ReportPage shows export actions', (tester) async {
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
      finalNotes: null,
    );

    final repository = _FakeSurveyRepository();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppSettings(surveyRepository: repository),
        child: MaterialApp(
          home: ReportPage(
            survey: survey,
            surveyAnswers: const ['A'],
            surveyQuestions: survey.questions,
            surveyRepository: repository,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Salvar como texto'), findsOneWidget);
    expect(find.text('Exportar PDF'), findsOneWidget);
  });
}
