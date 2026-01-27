library;

import 'package:dio/dio.dart';

import 'package:clinical_narrative_app/core/models/agent_response.dart';
import 'package:clinical_narrative_app/core/services/api_config.dart';

class ClinicalWriterService {
  ClinicalWriterService({Dio? httpClient})
      : _httpClient = httpClient ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                headers: ApiConfig.defaultHeaders,
              ),
            );

  final Dio _httpClient;

  Future<AgentResponse> processContent(String content) async {
    final payload = {
      'input_type': 'consult',
      'content': content,
      'locale': 'pt-BR',
      'prompt_key': 'default',
      'output_format': 'report_json',
      'metadata': {
        'source_app': 'clinical-narrative',
      },
    };
    final response = await _httpClient.post<Map<String, dynamic>>(
      'clinical_writer/process',
      data: payload,
    );
    final data = response.data;
    if (data == null) {
      throw const FormatException('Empty response from clinical writer.');
    }
    return AgentResponse.fromJson(data);
  }

  void dispose() {
    _httpClient.close();
  }
}
