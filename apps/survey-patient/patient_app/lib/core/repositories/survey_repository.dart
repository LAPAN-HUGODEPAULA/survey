library;

import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:patient_app/core/models/agent_response.dart';
import 'package:patient_app/core/models/patient.dart';
import 'package:patient_app/core/models/screener.dart';
import 'package:patient_app/core/models/survey/instructions.dart' as ui;
import 'package:patient_app/core/models/survey/question.dart' as ui;
import 'package:patient_app/core/models/survey/survey.dart' as ui;
import 'package:patient_app/core/models/survey_response.dart' as ui;
import 'package:patient_app/core/services/api_config.dart';
import 'package:survey_backend_api/survey_backend_api.dart' as api;

/// Repository responsible for fetching surveys and submitting responses via API.
class SurveyRepository {
  SurveyRepository({api.DefaultApi? apiClient})
      : _api = apiClient ??
            api.DefaultApi(
              Dio(
                BaseOptions(
                  baseUrl: ApiConfig.baseUrl,
                  headers: const {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                  },
                ),
              ),
              api.standardSerializers,
            );

  final api.DefaultApi _api;

  /// Retrieves every survey available on the backend.
  Future<List<ui.Survey>> fetchAll() async {
    final response = await _api.listSurveys();
    final BuiltList<api.Survey> data = response.data ?? BuiltList<api.Survey>();
    return data.map(_mapSurvey).toList(growable: false);
  }

  /// Fetches a single survey by its identifier.
  Future<ui.Survey> fetchById(String surveyId) async {
    final response = await _api.getSurvey(surveyId: surveyId);
    final api.Survey? data = response.data;
    if (data == null) {
      throw const FormatException('Survey not found');
    }
    return _mapSurvey(data);
  }

  /// Submits a survey response to the backend and returns the saved record.
  Future<ui.SurveyResponse> submitResponse(ui.SurveyResponse response) async {
    final apiResponse = await _api.createPatientResponse(
      surveyResponse: _mapSurveyResponseToApi(response),
    );
    final api.SurveyResponseWithAgent? created = apiResponse.data;
    if (created == null) {
      throw const FormatException('Unexpected empty payload when creating response.');
    }
    return _mapSurveyResponseWithAgent(created);
  }

  ui.Survey _mapSurvey(api.Survey source) {
    return ui.Survey(
      id: source.id ?? '',
      surveyDisplayName: source.surveyDisplayName,
      surveyName: source.surveyName,
      surveyDescription: source.surveyDescription,
      creatorName: source.creatorName,
      creatorContact: source.creatorContact,
      createdAt: source.createdAt.toLocal(),
      modifiedAt: source.modifiedAt.toLocal(),
      instructions: ui.Instructions(
        preamble: source.instructions.preamble,
        questionText: source.instructions.questionText,
        answers: source.instructions.answers.toList(growable: false),
      ),
      questions: source.questions
          .map(
            (q) => ui.Question(
              id: q.id,
              questionText: q.questionText,
              answers: q.answers.toList(growable: false),
            ),
          )
          .toList(growable: false),
      finalNotes: source.finalNotes,
    );
  }

  ui.SurveyResponse _mapSurveyResponseWithAgent(api.SurveyResponseWithAgent source) {
    final answers = source.answers?.toList(growable: false) ?? const <api.Answer>[];
    final patient = source.patient;

    return ui.SurveyResponse(
      id: source.id,
      agentResponse: source.agentResponse == null
          ? null
          : AgentResponse(
              classification: source.agentResponse?.classification,
              medicalRecord: source.agentResponse?.medicalRecord,
              errorMessage: source.agentResponse?.errorMessage,
            ),
      surveyId: source.surveyId ?? '',
      creatorName: source.creatorName ?? '',
      creatorContact: source.creatorContact ?? '',
      testDate: source.testDate?.toLocal() ?? DateTime.now(),
      screener: Screener(
        name: source.screenerName ?? '',
        email: source.screenerEmail ?? '',
      ),
      patient: patient != null ? _mapPatientFromApi(patient) : Patient.initial(),
      answers: answers
          .map(
            (ans) => ui.Answer(
              id: ans.id ?? 0,
              answer: ans.answer ?? '',
            ),
          )
          .toList(growable: false),
    );
  }

  Patient _mapPatientFromApi(api.Patient source) {
    return Patient(
      name: source.name ?? '',
      email: source.email ?? '',
      birthDate: source.birthDate ?? '',
      gender: source.gender ?? '',
      ethnicity: source.ethnicity ?? '',
      educationLevel: source.educationLevel ?? '',
      profession: source.profession ?? '',
      medication: source.medication?.toList(growable: false) ?? const <String>[],
      diagnoses: source.diagnoses?.toList(growable: false) ?? const <String>[],
    );
  }

  api.SurveyResponse _mapSurveyResponseToApi(ui.SurveyResponse source) {
    return api.SurveyResponse((b) {
      b
        ..surveyId = source.surveyId
        ..creatorName = source.creatorName
        ..creatorContact = source.creatorContact
        ..testDate = source.testDate.toUtc()
        ..screenerName = source.screener.name
        ..screenerEmail = source.screener.email
        ..patient.replace(_mapPatientToApi(source.patient))
        ..answers.replace(
          source.answers.map(
            (ans) => api.Answer(
              (ab) => ab
                ..id = ans.id
                ..answer = ans.answer,
            ),
          ),
        );
    });
  }

  api.Patient _mapPatientToApi(ui.Patient source) {
    return api.Patient(
      (p) => p
        ..name = source.name
        ..email = source.email
        ..birthDate = source.birthDate
        ..gender = source.gender
        ..ethnicity = source.ethnicity
        ..educationLevel = source.educationLevel
        ..profession = source.profession
        ..medication.replace(source.medication)
        ..diagnoses.replace(source.diagnoses),
    );
  }

  void dispose() {
    // no-op for now
  }
}
