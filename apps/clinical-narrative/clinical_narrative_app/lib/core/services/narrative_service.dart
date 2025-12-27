library;

import 'package:clinical_narrative_app/core/models/patient.dart';
import 'package:clinical_narrative_app/core/services/api_client.dart';

class NarrativeService {
  NarrativeService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<void> saveNarrative({
    required Patient patient,
    required String narrative,
  }) async {
    final body = {
      'patient': patient.toJson(),
      'narrative': narrative,
    };
    await _apiClient.postJson('narratives', body);
  }

  void dispose() {
    _apiClient.dispose();
  }
}
