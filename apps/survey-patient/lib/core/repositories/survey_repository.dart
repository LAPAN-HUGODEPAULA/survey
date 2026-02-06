library;

import 'dart:convert';
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:patient_app/core/models/agent_response.dart';
import 'package:patient_app/core/models/survey/instructions.dart' as ui;
import 'package:patient_app/core/models/survey/question.dart' as ui;
import 'package:patient_app/core/models/survey/survey.dart' as ui;
import 'package:patient_app/core/models/survey_response.dart' as ui;
import 'package:patient_app/core/services/api_config.dart';
import 'package:survey_backend_api/survey_backend_api.dart' as api;

/// Repository responsible for fetching surveys and submitting responses via API.
class SurveyRepository {
  SurveyRepository({api.DefaultApi? apiClient, Dio? rawClient})
    : _api =
          apiClient ??
          api.DefaultApi(
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.dioBaseUrl,
                headers: ApiConfig.defaultHeaders,
              ),
            ),
            api.standardSerializers,
          ),
      _rawClient =
          rawClient ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.dioBaseUrl,
              headers: ApiConfig.defaultHeaders,
            ),
          );

  final api.DefaultApi _api;
  final Dio _rawClient;

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
    final payload = response.toJson();
    final data = await _postJson('patient_responses/', payload);
    return ui.SurveyResponse.fromJson(data);
  }

  /// Sends content to the Clinical Writer agent via backend proxy.
  Future<AgentResponse> processClinicalWriter(String content) async {
    final requestId = _generateRequestId();
    final body = {
      'input_type': 'survey7',
      'content': content,
      'locale': 'pt-BR',
      'prompt_key': 'default',
      'output_format': 'report_json',
      'metadata': {
        'source_app': 'survey-patient',
        'request_id': requestId,
      },
    };
    final data = await _postJson('clinical_writer/process', body);
    return AgentResponse.fromJson(data);
  }

  ui.Survey _mapSurvey(api.Survey source) {
    return ui.Survey(
      id: source.id ?? '',
      surveyDisplayName: source.surveyDisplayName,
      surveyName: source.surveyName,
      surveyDescription: source.surveyDescription,
      creatorId: source.creatorId,
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

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final response = await _rawClient.postUri(
      ApiConfig.resolve(path),
      data: payload,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    throw const FormatException('Unexpected response payload.');
  }

  String _generateRequestId() {
    final random = Random();
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    return 'req_${timestamp}_${random.nextInt(9999)}';
  }

  void dispose() {
    // no-op for now
  }
}
