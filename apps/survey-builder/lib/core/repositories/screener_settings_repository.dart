import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:survey_builder/core/models/screener_settings_draft.dart';
import 'package:survey_builder/core/services/api_config.dart';

class ScreenerSettingsRepository {
  ScreenerSettingsRepository({Dio? client})
    : _client = client ?? ApiConfig.createDio();

  final Dio _client;

  Future<ScreenerSettingsDraft> fetchSettings() async {
    final response = await _client.get<Object?>(
      ApiConfig.requestPath('settings/screener'),
      options: Options(responseType: ResponseType.plain),
    );
    return _map(_coerceJson(response.data));
  }

  Future<ScreenerSettingsDraft> updateDefaultQuestionnaire(
    String questionnaireId,
  ) async {
    final response = await _client.put<Object?>(
      ApiConfig.requestPath('settings/screener'),
      data: {'defaultQuestionnaireId': questionnaireId},
      options: Options(responseType: ResponseType.plain),
    );
    return _map(_coerceJson(response.data));
  }

  ScreenerSettingsDraft _map(dynamic payload) {
    if (payload is! Map) {
      return ScreenerSettingsDraft();
    }
    final data = Map<String, dynamic>.from(payload);
    return ScreenerSettingsDraft(
      defaultQuestionnaireId: data['defaultQuestionnaireId']?.toString(),
      defaultQuestionnaireName: data['defaultQuestionnaireName']?.toString(),
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
