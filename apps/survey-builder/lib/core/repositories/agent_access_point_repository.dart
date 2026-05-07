import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:survey_builder/core/models/agent_access_point_draft.dart';
import 'package:survey_builder/core/services/api_config.dart';

class AgentAccessPointRepository {
  AgentAccessPointRepository({Dio? client})
    : _client = client ?? ApiConfig.createDio();

  final Dio _client;

  Future<List<AgentAccessPointDraft>> listAccessPoints() async {
    try {
      final response = await _client.get<Object?>(
        ApiConfig.requestPath('agent_access_points/'),
      );
      final decoded = _coerceJson(response.data);
      if (decoded is! List) {
        throw const FormatException(
          'Resposta inesperada ao listar pontos de acesso.',
        );
      }
      return decoded
          .whereType<Map<Object?, Object?>>()
          .map((entry) => _mapDraft(Map<String, dynamic>.from(entry)))
          .toList(growable: false);
    } on DioException catch (error) {
      throw _mapError(
        error,
        fallbackMessage: 'Falha ao listar pontos de acesso.',
      );
    }
  }

  Future<AgentAccessPointDraft> createAccessPoint(
    AgentAccessPointDraft draft,
  ) async {
    try {
      final response = await _client.post<Object?>(
        ApiConfig.requestPath('agent_access_points/'),
        data: _toJson(draft),
      );
      return _mapResponse(response.data);
    } on DioException catch (error) {
      throw _mapError(
        error,
        fallbackMessage: 'Falha ao criar ponto de acesso.',
      );
    }
  }

  Future<AgentAccessPointDraft> updateAccessPoint(
    AgentAccessPointDraft draft,
  ) async {
    try {
      final response = await _client.put<Object?>(
        ApiConfig.requestPath('agent_access_points/${draft.accessPointKey}'),
        data: _toJson(draft),
      );
      return _mapResponse(response.data);
    } on DioException catch (error) {
      throw _mapError(
        error,
        fallbackMessage: 'Falha ao atualizar ponto de acesso.',
      );
    }
  }

  Future<void> deleteAccessPoint(String accessPointKey) async {
    try {
      await _client.delete<Object?>(
        ApiConfig.requestPath('agent_access_points/$accessPointKey'),
      );
    } on DioException catch (error) {
      throw _mapError(
        error,
        fallbackMessage: 'Falha ao excluir ponto de acesso.',
      );
    }
  }

  Future<AgentAccessPointDraft?> getAccessPointByKey(
    String accessPointKey,
  ) async {
    try {
      final response = await _client.get<Object?>(
        ApiConfig.requestPath('agent_access_points/$accessPointKey'),
      );
      return _mapResponse(response.data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      throw _mapError(
        error,
        fallbackMessage: 'Falha ao buscar ponto de acesso.',
      );
    }
  }

  AgentAccessPointDraft _mapResponse(Object? payload) {
    final decoded = _coerceJson(payload);
    if (decoded is Map<String, dynamic>) {
      return _mapDraft(decoded);
    }
    if (decoded is Map) {
      return _mapDraft(Map<String, dynamic>.from(decoded));
    }
    throw const FormatException('Resposta inesperada do ponto de acesso.');
  }

  AgentAccessPointDraft _mapDraft(Map<String, dynamic> json) {
    final aiConfigJson = json['aiConfig'];
    AIConfigDraft? aiConfig;
    if (aiConfigJson is Map) {
      final map = Map<String, dynamic>.from(aiConfigJson);
      aiConfig = AIConfigDraft(
        primaryProvider: map['primaryProvider']?.toString() ?? '',
        primaryModel: map['primaryModel']?.toString() ?? '',
        fallbackProvider: map['fallbackProvider']?.toString(),
        fallbackModel: map['fallbackModel']?.toString(),
        temperature: (map['temperature'] as num?)?.toDouble() ?? 0.0,
        reasoningEffort: map['reasoningEffort']?.toString(),
        enableCaching: map['enableCaching'] as bool? ?? true,
      );
    }

    return AgentAccessPointDraft(
      accessPointKey: json['accessPointKey']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sourceApp: json['sourceApp']?.toString() ?? '',
      flowKey: json['flowKey']?.toString() ?? '',
      promptKey: json['promptKey']?.toString() ?? '',
      personaSkillKey: json['personaSkillKey']?.toString() ?? '',
      outputProfile: json['outputProfile']?.toString() ?? '',
      aiConfig: aiConfig,
      aiProvider: json['aiProvider']?.toString(),
      glmModel: json['glmModel']?.toString(),
      geminiModel: json['geminiModel']?.toString(),
      systemPromptOverride: json['systemPromptOverride']?.toString(),
      formatPromptOverride: json['formatPromptOverride']?.toString(),
      surveyId: json['surveyId']?.toString(),
      description: json['description']?.toString(),
      createdAt: _coerceDateTime(json['createdAt']),
      modifiedAt: _coerceDateTime(json['modifiedAt']),
    );
  }

  Map<String, dynamic> _toJson(AgentAccessPointDraft draft) {
    final Map<String, dynamic> data = {
      'accessPointKey': draft.accessPointKey.trim().toLowerCase(),
      'name': draft.name.trim(),
      'sourceApp': draft.sourceApp.trim().toLowerCase(),
      'flowKey': draft.flowKey.trim().toLowerCase(),
      'promptKey': draft.promptKey.trim().toLowerCase(),
      'personaSkillKey': draft.personaSkillKey.trim().toLowerCase(),
      'outputProfile': draft.outputProfile.trim().toLowerCase(),
      'aiProvider': draft.aiProvider?.trim().isEmpty ?? true
          ? null
          : draft.aiProvider!.trim(),
      'glmModel': draft.glmModel?.trim().isEmpty ?? true
          ? null
          : draft.glmModel!.trim(),
      'geminiModel': draft.geminiModel?.trim().isEmpty ?? true
          ? null
          : draft.geminiModel!.trim(),
      'systemPromptOverride': draft.systemPromptOverride?.trim().isEmpty ?? true
          ? null
          : draft.systemPromptOverride!.trim(),
      'formatPromptOverride': draft.formatPromptOverride?.trim().isEmpty ?? true
          ? null
          : draft.formatPromptOverride!.trim(),
      'surveyId': draft.surveyId?.trim().isEmpty ?? true
          ? null
          : draft.surveyId!.trim(),
      'description': draft.description?.trim().isEmpty ?? true
          ? null
          : draft.description!.trim(),
    };

    if (draft.aiConfig != null) {
      data['aiConfig'] = {
        'primaryProvider': draft.aiConfig!.primaryProvider,
        'primaryModel': draft.aiConfig!.primaryModel,
        'fallbackProvider': draft.aiConfig!.fallbackProvider,
        'fallbackModel': draft.aiConfig!.fallbackModel,
        'temperature': draft.aiConfig!.temperature,
        'reasoningEffort': draft.aiConfig!.reasoningEffort,
        'enableCaching': draft.aiConfig!.enableCaching,
      };
    }

    return data;
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

  AgentAccessPointRepositoryException _mapError(
    DioException error, {
    required String fallbackMessage,
  }) {
    final detail = _extractDetail(error.response?.data);
    if (error.response?.statusCode == 409) {
      return AgentAccessPointConflictException(
        detail.isEmpty ? 'Conflito ao salvar ponto de acesso.' : detail,
      );
    }
    return AgentAccessPointRepositoryException(
      detail.isEmpty ? fallbackMessage : detail,
    );
  }

  String _extractDetail(Object? payload) {
    final decoded = _coerceJson(payload);
    if (decoded is Map<String, dynamic>) {
      final detail = decoded['detail'];
      if (detail is String) {
        return detail;
      }
    } else if (decoded is Map) {
      final detail = decoded['detail'];
      if (detail is String) {
        return detail;
      }
    } else if (decoded is String) {
      return decoded;
    }
    return '';
  }

  void dispose() {
    _client.close(force: true);
  }
}

class AgentAccessPointRepositoryException implements Exception {
  const AgentAccessPointRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AgentAccessPointConflictException
    extends AgentAccessPointRepositoryException {
  const AgentAccessPointConflictException(super.message);
}
