library;

import 'package:dio/dio.dart';

import 'package:clinical_narrative_app/core/services/api_config.dart';

/// Lightweight HTTP client wrapper using Dio.
class ApiClient {
  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                headers: ApiConfig.defaultHeaders,
              ),
            );

  final Dio _dio;

  /// Executes a GET request and returns the decoded JSON body.
  Future<dynamic> getJson(String path) async {
    final response = await _dio.get<dynamic>(path);
    return response.data;
  }

  /// Executes a POST request with a JSON payload.
  Future<dynamic> postJson(String path, Map<String, dynamic> body) async {
    final response = await _dio.post<dynamic>(path, data: body);
    return response.data;
  }

  /// Disposes the underlying HTTP client. Call when the object is no longer needed.
  void dispose() {
    _dio.close();
  }
}
