library;

import 'package:flutter/foundation.dart';
import 'package:survey_builder/flavors.dart';

class ApiConfig {
  static String get baseUrl {
    final baseUrl = deployment.apiBaseUrl;
    return _normalizeBaseUrl(baseUrl);
  }

  static Uri resolve(String path, [Map<String, dynamic>? queryParameters]) {
    final sanitizedPath = _stripLeadingSlash(path);
    final normalizedUri = Uri.parse(baseUrl).resolve(sanitizedPath);
    if (queryParameters == null || queryParameters.isEmpty) {
      return normalizedUri;
    }

    return normalizedUri.replace(
      queryParameters: queryParameters.map(
        (key, value) => MapEntry(key, value?.toString()),
      ),
    );
  }

  static Map<String, String> get defaultHeaders => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static String get dioBaseUrl {
    return baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
  }

  static void debugLogResolved(String path) {
    if (kDebugMode) {
      // Intentionally left empty.
    }
  }

  static String _stripLeadingSlash(String path) {
    return path.startsWith('/') ? path.substring(1) : path;
  }

  static String _normalizeBaseUrl(String rawBaseUrl) {
    if (rawBaseUrl.isEmpty) {
      throw StateError('API_BASE_URL is not set.');
    }
    return rawBaseUrl.endsWith('/') ? rawBaseUrl : '$rawBaseUrl/';
  }
}
