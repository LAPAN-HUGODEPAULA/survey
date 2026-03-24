
import 'package:clinical_narrative_app/core/config/runtime_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:runtime_api_url/runtime_api_url.dart';

/// Centralized API configuration for building backend URLs.
class ApiConfig {
  /// Returns the normalized API base URL, ensuring a trailing slash to allow
  /// reliable path resolution.
  static String get baseUrl {
    return RuntimeApiUrl.normalizeBaseUrl(RuntimeConfig.instance.apiBaseUrl);
  }

  /// Builds a [Uri] for the provided [path] relative to [baseUrl].
  static Uri resolve(String path, [Map<String, dynamic>? queryParameters]) {
    return RuntimeApiUrl.resolve(baseUrl, path, queryParameters);
  }

  /// Normalized request path for Dio calls.
  static String requestPath(
    String path, [
    Map<String, dynamic>? queryParameters,
  ]) {
    return RuntimeApiUrl.requestPath(baseUrl, path, queryParameters);
  }

  /// Default headers for JSON-based requests.
  static Map<String, String> get defaultHeaders => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Standard Dio client configured for the survey backend.
  static Dio createDio({Map<String, String>? headers}) {
    return Dio(
      BaseOptions(
        baseUrl: dioBaseUrl,
        headers: {...defaultHeaders, if (headers != null) ...headers},
      ),
    );
  }

  /// Base URL without trailing slash for HTTP clients that already
  /// prefix request paths with a leading slash.
  static String get dioBaseUrl {
    return RuntimeApiUrl.dioBaseUrl(baseUrl);
  }

  /// Helper to log the resolved URL when debugging.
  static void debugLogResolved(String path) {
    if (kDebugMode) {
      // This is intentionally left empty.
    }
  }
}
