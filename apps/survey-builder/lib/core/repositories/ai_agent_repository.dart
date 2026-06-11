import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:survey_builder/core/models/ai_agent_draft.dart';
import 'package:survey_builder/core/services/api_config.dart';

class AIAgentRepository {
  AIAgentRepository({Dio? client}) : _client = client ?? ApiConfig.createDio();

  final Dio _client;

  Future<List<AIAgentDraft>> listAgents() async {
    try {
      final response = await _client.get<Object?>(
        ApiConfig.requestPath('ai_agents/'),
      );
      final decoded = _coerceJson(response.data);
      if (decoded is! List) {
        throw const FormatException(
          'Resposta inesperada ao listar agentes de IA.',
        );
      }
      return decoded
          .whereType<Map<Object?, Object?>>()
          .map((entry) => _mapDraft(Map<String, dynamic>.from(entry)))
          .toList(growable: false);
    } on DioException catch (error) {
      throw _mapError(error, fallbackMessage: 'Falha ao listar agentes de IA.');
    }
  }

  Future<AIAgentDraft> createAgent(AIAgentDraft draft) async {
    try {
      final response = await _client.post<Object?>(
        ApiConfig.requestPath('ai_agents/'),
        data: _toJson(draft),
      );
      return _mapResponse(response.data);
    } on DioException catch (error) {
      throw _mapError(error, fallbackMessage: 'Falha ao criar agente de IA.');
    }
  }

  Future<AIAgentDraft> updateAgent(AIAgentDraft draft) async {
    try {
      final response = await _client.put<Object?>(
        ApiConfig.requestPath('ai_agents/${draft.agentKey}'),
        data: _toJson(draft),
      );
      return _mapResponse(response.data);
    } on DioException catch (error) {
      throw _mapError(
        error,
        fallbackMessage: 'Falha ao atualizar agente de IA.',
      );
    }
  }

  Future<void> deleteAgent(String agentKey) async {
    try {
      await _client.delete<Object?>(
        ApiConfig.requestPath('ai_agents/$agentKey'),
      );
    } on DioException catch (error) {
      throw _mapError(error, fallbackMessage: 'Falha ao excluir agente de IA.');
    }
  }

  AIAgentDraft _mapResponse(Object? payload) {
    final decoded = _coerceJson(payload);
    if (decoded is Map<String, dynamic>) {
      return _mapDraft(decoded);
    }
    if (decoded is Map) {
      return _mapDraft(Map<String, dynamic>.from(decoded));
    }
    throw const FormatException('Resposta inesperada do agente de IA.');
  }

  AIAgentDraft _mapDraft(Map<String, dynamic> json) {
    return AIAgentDraft(
      agentKey: json['agentKey']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      providerType: json['providerType']?.toString() ?? '',
      baseUrl: json['baseUrl']?.toString(),
      apiKeyEnvVar: json['apiKeyEnvVar']?.toString(),
      defaultModel: json['defaultModel']?.toString() ?? '',
      enabled: json['enabled'] as bool? ?? true,
      supportsOpenAIChatCompletions:
          json['supportsOpenAIChatCompletions'] as bool? ?? false,
      supportsResponseFormat: json['supportsResponseFormat'] as bool? ?? false,
      supportsRag: json['supportsRag'] as bool? ?? false,
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> _toJson(AIAgentDraft draft) {
    return {
      'agentKey': draft.agentKey.trim().toLowerCase(),
      'name': draft.name.trim(),
      'providerType': draft.providerType,
      'baseUrl': draft.baseUrl?.trim().isEmpty ?? true
          ? null
          : draft.baseUrl!.trim(),
      'apiKeyEnvVar': draft.apiKeyEnvVar?.trim().isEmpty ?? true
          ? 'AI_API_KEY'
          : draft.apiKeyEnvVar!.trim(),
      'defaultModel': draft.defaultModel.trim(),
      'enabled': draft.enabled,
      'supportsOpenAIChatCompletions': draft.supportsOpenAIChatCompletions,
      'supportsResponseFormat': draft.supportsResponseFormat,
      'supportsRag': draft.supportsRag,
      'notes': draft.notes?.trim().isEmpty ?? true ? null : draft.notes!.trim(),
    };
  }

  dynamic _coerceJson(dynamic payload) {
    if (payload is String) {
      return jsonDecode(payload);
    }
    return payload;
  }

  AIAgentRepositoryException _mapError(
    DioException error, {
    required String fallbackMessage,
  }) {
    final detail = _extractDetail(error.response?.data);
    if (error.response?.statusCode == 409) {
      return AIAgentConflictException(
        detail.isEmpty ? 'Conflito ao salvar agente de IA.' : detail,
      );
    }
    return AIAgentRepositoryException(
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

class AIAgentRepositoryException implements Exception {
  const AIAgentRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AIAgentConflictException extends AIAgentRepositoryException {
  const AIAgentConflictException(super.message);
}
