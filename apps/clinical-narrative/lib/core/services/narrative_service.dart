
import 'package:clinical_narrative_app/core/models/patient.dart';
import 'package:clinical_narrative_app/core/services/api_config.dart';
import 'package:dio/dio.dart';

class NarrativeService {
  NarrativeService({Dio? httpClient})
    : _httpClient = httpClient ?? ApiConfig.createDio();

  final Dio _httpClient;

  Future<void> saveNarrative({
    required Patient patient,
    required String narrative,
  }) async {
    final body = {
      'patient': patient.toJson(),
      'narrative': narrative,
    };
    await _httpClient.post<dynamic>(
      ApiConfig.requestPath('narratives'),
      data: body,
    );
  }

  void dispose() {
    _httpClient.close();
  }
}
