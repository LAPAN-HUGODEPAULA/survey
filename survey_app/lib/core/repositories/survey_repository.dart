library;
// ignore_for_file: avoid_print

import 'package:survey_app/core/models/survey/survey.dart';
import 'package:survey_app/core/models/survey_response.dart';
import 'package:survey_app/core/services/api_client.dart';

/// Repository responsible for fetching surveys and submitting responses via API.
class SurveyRepository {
  SurveyRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  /// Retrieves every survey available on the backend.
  Future<List<Survey>> fetchAll() async {
    print('[SurveyRepository] Issuing GET /surveys/');
    final data = await _apiClient.getJson('surveys/');
    if (data is! List) {
      print('[SurveyRepository] Unexpected payload type: ${data.runtimeType}');
      throw const FormatException('Unexpected payload when listing surveys.');
    }
    final surveys = data
        .whereType<Map<String, dynamic>>()
        .map(Survey.fromJson)
        .toList(growable: false);
    print('[SurveyRepository] Parsed ${surveys.length} survey(s)');
    return surveys;
  }

  /// Fetches a single survey by its identifier.
  Future<Survey> fetchById(String surveyId) async {
    print('[SurveyRepository] Issuing GET /surveys/$surveyId');
    final data = await _apiClient.getJson('surveys/$surveyId');
    if (data is! Map<String, dynamic>) {
      print('[SurveyRepository] Unexpected payload type: ${data.runtimeType}');
      throw const FormatException('Unexpected payload when loading survey.');
    }
    return Survey.fromJson(data);
  }

  /// Submits a survey response to the backend and returns the saved record.
  Future<SurveyResponse> submitResponse(SurveyResponse response) async {
    print('[SurveyRepository] Posting survey response for surveyId=${response.surveyId}');
    final data = await _apiClient.postJson(
      'survey_responses/',
      response.toJson(),
    );
    if (data is! Map<String, dynamic>) {
      print('[SurveyRepository] Unexpected payload type: ${data.runtimeType}');
      throw const FormatException('Unexpected payload when creating response.');
    }
    return SurveyResponse.fromJson(data);
  }

  void dispose() {
    _apiClient.dispose();
  }
}
