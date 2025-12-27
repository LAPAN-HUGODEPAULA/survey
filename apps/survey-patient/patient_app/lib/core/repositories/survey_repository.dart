library;

import 'package:patient_app/core/models/survey/survey.dart';
import 'package:patient_app/core/models/survey_response.dart';
import 'package:patient_app/core/services/api_client.dart';

/// Repository responsible for fetching surveys and submitting responses via API.
class SurveyRepository {
  SurveyRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  /// Retrieves every survey available on the backend.
  Future<List<Survey>> fetchAll() async {
    final data = await _apiClient.getJson('surveys/');
    if (data is! List) {
      throw const FormatException('Unexpected payload when listing surveys.');
    }
    final surveys = data
        .whereType<Map<String, dynamic>>()
        .map(Survey.fromJson)
        .toList(growable: false);
    return surveys;
  }

  /// Fetches a single survey by its identifier.
  Future<Survey> fetchById(String surveyId) async {
    final data = await _apiClient.getJson('surveys/$surveyId');
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected payload when loading survey.');
    }
    return Survey.fromJson(data);
  }

  /// Submits a survey response to the backend and returns the saved record.
  Future<SurveyResponse> submitResponse(SurveyResponse response) async {
    final data = await _apiClient.postJson(
      'patient_responses/',
      response.toJson(),
    );
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected payload when creating response.');
    }
    return SurveyResponse.fromJson(data);
  }

  void dispose() {
    _apiClient.dispose();
  }
}
