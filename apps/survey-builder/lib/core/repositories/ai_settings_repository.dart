import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:survey_builder/core/models/ai_settings_draft.dart';
import 'package:survey_builder/core/services/api_config.dart';

class AISettingsRepository {
  AISettingsRepository({Dio? client}) : _client = client ?? ApiConfig.createDio();

  final Dio _client;

  Future<GlobalAIConfigDraft?> fetchSettings() async {
    final response = await _client.get<Object?>(
      ApiConfig.requestPath('settings/ai'),
      options: Options(responseType: ResponseType.plain),
    );
    final decoded = _coerceJson(response.data);
    if (decoded is! Map) {
      return null;
    }
    final data = Map<String, dynamic>.from(decoded);
    final aiConfig = data['aiConfig'];
    if (aiConfig is! Map) {
      return null;
    }
    final map = Map<String, dynamic>.from(aiConfig);
    return GlobalAIConfigDraft(
      primaryProvider: map['primaryProvider']?.toString() ?? 'glm',
      primaryModel: map['primaryModel']?.toString() ?? '',
      fallbackProvider: map['fallbackProvider']?.toString(),
      fallbackModel: map['fallbackModel']?.toString(),
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0.0,
      reasoningEffort: map['reasoningEffort']?.toString() ?? 'low',
      enableCaching: map['enableCaching'] as bool? ?? true,
    );
  }

  Future<GlobalAIConfigDraft> updateSettings(GlobalAIConfigDraft draft) async {
    final response = await _client.put<Object?>(
      ApiConfig.requestPath('settings/ai'),
      data: {
        'aiConfig': {
          'primaryProvider': draft.primaryProvider,
          'primaryModel': draft.primaryModel,
          'fallbackProvider': draft.fallbackProvider,
          'fallbackModel': draft.fallbackModel,
          'temperature': draft.temperature,
          'reasoningEffort': draft.reasoningEffort,
          'enableCaching': draft.enableCaching,
        },
      },
      options: Options(responseType: ResponseType.plain),
    );
    final decoded = _coerceJson(response.data);
    if (decoded is! Map) {
      throw const FormatException('Resposta inesperada ao atualizar configurações de IA.');
    }
    final map = Map<String, dynamic>.from(decoded['aiConfig'] as Map);
    return GlobalAIConfigDraft(
      primaryProvider: map['primaryProvider']?.toString() ?? 'glm',
      primaryModel: map['primaryModel']?.toString() ?? '',
      fallbackProvider: map['fallbackProvider']?.toString(),
      fallbackModel: map['fallbackModel']?.toString(),
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0.0,
      reasoningEffort: map['reasoningEffort']?.toString() ?? 'low',
      enableCaching: map['enableCaching'] as bool? ?? true,
    );
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
