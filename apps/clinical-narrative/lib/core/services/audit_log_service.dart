
import 'package:clinical_narrative_app/core/services/api_config.dart';
import 'package:dio/dio.dart';

class AuditLogService {
  AuditLogService({Dio? httpClient})
    : _httpClient = httpClient ?? ApiConfig.createDio();

  final Dio _httpClient;

  Future<void> logEvent(
    String action, {
    Map<String, dynamic>? actor,
    Map<String, dynamic>? target,
    Map<String, dynamic>? metadata,
  }) async {
    await _httpClient.post<dynamic>(
      ApiConfig.requestPath('/privacy/audit'),
      data: {
        'action': action,
        'actor': ?actor,
        'target': ?target,
        'metadata': ?metadata,
      },
    );
  }

  void dispose() {
    _httpClient.close();
  }
}
