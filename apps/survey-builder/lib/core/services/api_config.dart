
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:runtime_api_url/runtime_api_url.dart';
import 'package:survey_builder/core/config/runtime_config.dart';

class ApiConfig {
  static String get baseUrl {
    return RuntimeApiUrl.normalizeBaseUrl(RuntimeConfig.instance.apiBaseUrl);
  }

  static Uri resolve(String path, [Map<String, dynamic>? queryParameters]) {
    return RuntimeApiUrl.resolve(baseUrl, path, queryParameters);
  }

  static String requestPath(
    String path, [
    Map<String, dynamic>? queryParameters,
  ]) {
    return RuntimeApiUrl.requestPath(baseUrl, path, queryParameters);
  }

  static Map<String, String> get defaultHeaders => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Dio createDio({Map<String, String>? headers}) {
    return Dio(
      BaseOptions(
        baseUrl: dioBaseUrl,
        headers: {...defaultHeaders, if (headers != null) ...headers},
      ),
    );
  }

  static String get dioBaseUrl {
    return RuntimeApiUrl.dioBaseUrl(baseUrl);
  }

  static void debugLogResolved(String path) {
    if (kDebugMode) {
      // Intentionally left empty.
    }
  }
}
