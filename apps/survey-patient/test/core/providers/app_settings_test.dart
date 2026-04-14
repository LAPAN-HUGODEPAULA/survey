import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/core/models/patient.dart';
import 'package:patient_app/core/models/survey/instructions.dart';
import 'package:patient_app/core/models/survey/question.dart';
import 'package:patient_app/core/models/survey/survey.dart';
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:patient_app/core/repositories/survey_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survey_backend_api/survey_backend_api.dart' as api;

void main() {
  group('AppSettings.loadAvailableSurveys', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test(
      'times out and clears the loading flag when the repository hangs',
      () async {
        final settings = AppSettings(
          surveyRepository: _HangingSurveyRepository(),
          surveyLoadTimeout: const Duration(milliseconds: 20),
        );

        await settings.loadAvailableSurveys();

        expect(settings.isLoadingSurveys, isFalse);
        expect(settings.availableSurveys, isEmpty);
        expect(settings.surveyLoadError, contains('Tempo limite'));
      },
    );

    test('selects the preferred survey when it is available', () async {
      final preferredSurvey = _buildSurvey(id: 'lapan_q7', name: 'Survey 7');
      final fallbackSurvey = _buildSurvey(id: 'other', name: 'Other Survey');
      final settings = AppSettings(
        surveyRepository: _FakeSurveyRepository([
          fallbackSurvey,
          preferredSurvey,
        ]),
        surveyLoadTimeout: const Duration(milliseconds: 20),
      );

      await settings.loadAvailableSurveys();

      expect(settings.isLoadingSurveys, isFalse);
      expect(settings.surveyLoadError, isNull);
      expect(settings.selectedSurveyId, 'lapan_q7');
      expect(settings.selectedSurvey?.surveyName, 'Survey 7');
    });

    test(
      'restartAssessmentFlow prepares the quick restart navigation state',
      () async {
        final settings = AppSettings(
          surveyRepository: _FakeSurveyRepository([
            _buildSurvey(id: 'lapan_q7', name: 'Survey 7'),
          ]),
          surveyLoadTimeout: const Duration(milliseconds: 20),
        );

        settings.setPatientData(
          name: 'Paciente',
          email: 'paciente@example.com',
          birthDate: '01/01/2000',
          gender: 'Feminino',
          ethnicity: 'Branca',
          educationLevel: 'Superior',
          profession: 'Pesquisadora',
          medication: 'Nenhuma',
          diagnoses: const ['Enxaqueca'],
        );

        await settings.restartAssessmentFlow();

        expect(settings.patient, Patient.initial());
        expect(settings.hasAcceptedInitialNotice, isFalse);
        expect(
          settings.consumePostNoticeNavigationTarget(),
          PostNoticeNavigationTarget.survey,
        );
        expect(
          settings.consumePostNoticeNavigationTarget(),
          PostNoticeNavigationTarget.welcome,
        );
      },
    );
  });
}

class _FakeSurveyRepository extends SurveyRepository {
  _FakeSurveyRepository(this._surveys)
    : super(
        apiClient: api.DefaultApi(
          Dio(BaseOptions(baseUrl: 'http://localhost')),
          api.standardSerializers,
        ),
        rawClient: Dio(BaseOptions(baseUrl: 'http://localhost')),
      );

  final List<Survey> _surveys;

  @override
  Future<List<Survey>> fetchAll() async => _surveys;
}

class _HangingSurveyRepository extends SurveyRepository {
  _HangingSurveyRepository()
    : super(
        apiClient: api.DefaultApi(
          Dio(BaseOptions(baseUrl: 'http://localhost')),
          api.standardSerializers,
        ),
        rawClient: Dio(BaseOptions(baseUrl: 'http://localhost')),
      );

  @override
  Future<List<Survey>> fetchAll() => Completer<List<Survey>>().future;
}

Survey _buildSurvey({required String id, required String name}) {
  return Survey(
    id: id,
    surveyDisplayName: name,
    surveyName: name,
    surveyDescription: '<p>Descricao</p>',
    creatorId: 'creator',
    createdAt: DateTime(2026, 1, 1),
    modifiedAt: DateTime(2026, 1, 1),
    instructions: Instructions(
      preamble: '<p>Preambulo</p>',
      questionText: 'Pergunta',
      answers: const ['Sim', 'Nao'],
    ),
    questions: [
      Question(
        id: 1,
        questionText: 'Como voce esta?',
        answers: const ['Bem', 'Mal'],
      ),
    ],
    prompt: null,
  );
}
