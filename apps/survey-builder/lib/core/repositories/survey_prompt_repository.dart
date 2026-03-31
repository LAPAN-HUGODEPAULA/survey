import 'dart:convert';

import 'package:design_system_flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:survey_builder/core/models/survey_prompt_draft.dart';
import 'package:survey_builder/core/services/api_config.dart';

class SurveyPromptRepository {
  SurveyPromptRepository({Dio? client})
    : _client = client ?? ApiConfig.createDio();

  final Dio _client;

  Future<List<SurveyPromptDraft>> listPrompts() async {
    final response = await _client.get<Object?>(
      ApiConfig.requestPath('survey_prompts/'),
    );
    final decoded = _coerceJson(response.data);
    if (decoded is! List) {
      throw const FormatException('Resposta inesperada ao listar prompts.');
    }
    return decoded
        .whereType<Map<Object?, Object?>>()
        .map((entry) => _mapPrompt(Map<String, dynamic>.from(entry)))
        .toList(growable: false);
  }

  Future<SurveyPromptDraft> createPrompt(SurveyPromptDraft draft) async {
    final response = await _client.post<Object?>(
      ApiConfig.requestPath('survey_prompts/'),
      data: _toJson(draft),
    );
    return _mapResponse(response.data);
  }

  Future<SurveyPromptDraft> updatePrompt(SurveyPromptDraft draft) async {
    final response = await _client.put<Object?>(
      ApiConfig.requestPath('survey_prompts/${draft.promptKey}'),
      data: _toJson(draft),
    );
    return _mapResponse(response.data);
  }

  Future<void> deletePrompt(String promptKey) async {
    await _client.delete<Object?>(
      ApiConfig.requestPath('survey_prompts/$promptKey'),
    );
  }

  SurveyPromptDraft _mapResponse(Object? payload) {
    final decoded = _coerceJson(payload);
    if (decoded is Map<String, dynamic>) {
      return _mapPrompt(decoded);
    }
    if (decoded is Map) {
      return _mapPrompt(Map<String, dynamic>.from(decoded));
    }
    throw const FormatException('Resposta inesperada do prompt.');
  }

  SurveyPromptDraft _mapPrompt(Map<String, dynamic> json) {
    return SurveyPromptDraft(
      promptKey: json['promptKey']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      promptText: json['promptText']?.toString() ?? '',
      createdAt: _coerceDateTime(json['createdAt']),
      modifiedAt: _coerceDateTime(json['modifiedAt']),
    );
  }

  Map<String, dynamic> _toJson(SurveyPromptDraft draft) {
    return {
      'promptKey': DsKeyFieldSupport.normalizeKeyField(draft.promptKey),
      'name': DsKeyFieldSupport.normalizeTextField(draft.name),
      'promptText': DsKeyFieldSupport.normalizeTextField(draft.promptText),
    };
  }

  DateTime? _coerceDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  dynamic _coerceJson(dynamic payload) {
    if (payload is String) {
      return jsonDecode(payload);
    }
    return payload;
  }

  void dispose() {
    _client.close(force: true);
  }
}
