import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:patient_app/core/models/agent_response.dart';
import 'package:patient_app/core/models/survey/survey.dart' as ui;
import 'package:patient_app/core/models/survey_response.dart' as ui;
import 'package:patient_app/core/services/api_config.dart';
import 'package:survey_backend_api/survey_backend_api.dart' as api;

/// Repository responsible for fetching surveys and submitting responses via API.
class SurveyRepository {
  SurveyRepository({api.DefaultApi? apiClient, Dio? rawClient})
    : _rawClient = rawClient ?? ApiConfig.createDio();

  final Dio _rawClient;

  /// Retrieves every survey available on the backend.
  Future<List<ui.Survey>> fetchAll() async {
    debugPrint('SurveyRepository.fetchAll: request start');
    final response = await _rawClient.get<Object?>(
      ApiConfig.requestPath('surveys/'),
      options: Options(responseType: ResponseType.plain),
    );
    final data = _decodeJsonBody(response.data);
    if (data is! List) {
      debugPrint(
        'SurveyRepository.fetchAll: unexpected payload ${data.runtimeType}',
      );
      throw const FormatException('Unexpected surveys payload.');
    }

    final surveys = data
        .map(
          (entry) => ui.Survey.fromJson(
            Map<String, dynamic>.from(entry as Map<Object?, Object?>),
          ),
        )
        .toList(growable: false);
    debugPrint('SurveyRepository.fetchAll: parsed ${surveys.length} surveys');
    return surveys;
  }

  /// Fetches a single survey by its identifier.
  Future<ui.Survey> fetchById(String surveyId) async {
    final response = await _rawClient.get<Object?>(
      ApiConfig.requestPath('surveys/$surveyId'),
      options: Options(responseType: ResponseType.plain),
    );
    final data = _decodeJsonBody(response.data);
    if (data is! Map) {
      throw const FormatException('Questionário não encontrado');
    }
    return ui.Survey.fromJson(Map<String, dynamic>.from(data));
  }

  /// Submits a survey response to the backend and returns the saved record.
  Future<ui.SurveyResponse> submitResponse(ui.SurveyResponse response) async {
    final payload = response.toJson();
    final data = await _postJson('patient_responses/', payload);
    return ui.SurveyResponse.fromJson(data);
  }

  /// Searches reference medications by query text.
  Future<List<String>> searchMedications(String query, {int limit = 10}) async {
    final normalized = query.trim();
    if (normalized.length < 3) {
      return const <String>[];
    }

    final response = await _rawClient.get<Object?>(
      ApiConfig.requestPath('medications/search', <String, dynamic>{
        'q': normalized,
        'limit': limit,
      }),
      options: Options(responseType: ResponseType.plain),
    );
    final data = _decodeJsonBody(response.data);
    final rawResults = data is Map<String, dynamic> ? data['results'] : null;
    if (rawResults is! List) {
      return const <String>[];
    }
    return rawResults
        .whereType<Map<String, dynamic>>()
        .map((item) => item['substance']?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  /// Sends content to the Clinical Writer agent via backend proxy.
  Future<AgentResponse> processClinicalWriter(
    String content, {
    String? accessPointKey,
    String? promptKey,
    String? surveyId,
    String flowKey = 'thank_you.auto_analysis',
  }) async {
    final requestId = _generateRequestId();
    final metadata = <String, dynamic>{
      'source_app': 'survey-patient',
      'flow_key': flowKey,
      'request_id': requestId,
    };
    if (surveyId != null) {
      metadata['surveyId'] = surveyId;
    }
    final body = {
      'input_type': 'survey7',
      'content': content,
      'locale': 'pt-BR',
      'accessPointKey': accessPointKey,
      'prompt_key': promptKey ?? 'default',
      'output_format': 'report_json',
      'metadata': metadata,
    };
    final data = await _postJson('clinical_writer/process', body);
    return AgentResponse.fromJson(data);
  }

  Future<Map<String, dynamic>> startClinicalWriterTask(
    String content, {
    String? accessPointKey,
    String? promptKey,
    String? surveyId,
    String flowKey = 'thank_you.auto_analysis',
  }) async {
    final requestId = _generateRequestId();
    final metadata = <String, dynamic>{
      'source_app': 'survey-patient',
      'flow_key': flowKey,
      'request_id': requestId,
    };
    if (surveyId != null) {
      metadata['surveyId'] = surveyId;
    }
    final body = {
      'input_type': 'survey7',
      'content': content,
      'locale': 'pt-BR',
      'accessPointKey': accessPointKey,
      'prompt_key': promptKey ?? 'default',
      'output_format': 'report_json',
      'asyncMode': true,
      'metadata': metadata,
    };
    return _postJson('clinical_writer/process', body);
  }

  Future<Map<String, dynamic>> getClinicalWriterTaskStatus(String taskId) {
    return _getJson('clinical_writer/status/$taskId');
  }

  Future<void> sendReportEmail({
    required String responseId,
    required String reportText,
  }) async {
    await _postJson('patient_responses/$responseId/send_report_email', {
      'reportText': reportText,
    });
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final response = await _rawClient.post<Object?>(
      ApiConfig.requestPath(path),
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

  Future<Map<String, dynamic>> _getJson(String path) async {
    final response = await _rawClient.get<Object?>(ApiConfig.requestPath(path));
    final data = _decodeJsonBody(response.data);
    if (data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data);
    }
    throw const FormatException('Unexpected response payload.');
  }

  Object? _decodeJsonBody(Object? data) {
    if (data is String) {
      return jsonDecode(data);
    }
    return data;
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
