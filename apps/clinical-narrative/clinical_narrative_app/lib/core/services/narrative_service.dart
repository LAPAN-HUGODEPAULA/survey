library;

import 'package:dio/dio.dart';

import 'package:clinical_narrative_app/core/models/patient.dart';
import 'package:clinical_narrative_app/core/services/api_config.dart';

class NarrativeService {
  NarrativeService({Dio? httpClient})
      : _httpClient = httpClient ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                headers: ApiConfig.defaultHeaders,
              ),
            );

  final Dio _httpClient;

  Future<void> saveNarrative({
    required Patient patient,
    required String narrative,
  }) async {
    final body = {
      'patient': patient.toJson(),
      'narrative': narrative,
    };
    await _httpClient.post<dynamic>('narratives', data: body);
  }

  void dispose() {
    _httpClient.close();
  }
}
