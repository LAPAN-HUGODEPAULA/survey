library;

import 'package:flutter/foundation.dart';

/// Centralized API configuration for building backend URLs.
class ApiConfig {
  /// Base URL for the Survey backend, overridable at compile time using
  /// `--dart-define=API_BASE_URL=<url>`.
  static const String _baseUrlEnv = String.fromEnvironment(
    'API_BASE_URL',
    /// defaultValue: 'https://us-central1-darv-13c19.cloudfunctions.net/api/api/v1/',
    defaultValue: 'http://localhost:5001/darv-13c19/us-central1/api/api/v1/',
  );
  /// Returns the normalized API base URL, ensuring a trailing slash to allow
  /// reliable path resolution.
  static String get baseUrl {
    return _normalizeBaseUrl(_baseUrlEnv);
  }

  /// Builds a [Uri] for the provided [path] relative to [baseUrl].
  static Uri resolve(String path, [Map<String, dynamic>? queryParameters]) {
    final sanitizedPath = _stripDuplicatedApiPrefix(path);
    final uri = Uri.parse(baseUrl).resolve(sanitizedPath);
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: queryParameters.map(
        (key, value) => MapEntry(key, value?.toString()),
      ),
    );
  }

  /// Default headers for JSON-based requests.
  static Map<String, String> get defaultHeaders => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Helper to log the resolved URL when debugging.
  static void debugLogResolved(String path) {
    if (kDebugMode) {
      // This is intentionally left empty.
    }
  }

  static String _stripDuplicatedApiPrefix(String path) {
    var sanitized = path.startsWith('/') ? path.substring(1) : path;
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    if (normalizedBase.endsWith('/api/v1') && sanitized.startsWith('api/v1/')) {
      sanitized = sanitized.substring('api/v1/'.length);
    } else if (normalizedBase.endsWith('/api/v1') && sanitized == 'api/v1') {
      sanitized = '';
    }
    return sanitized;
  }

  static String _normalizeBaseUrl(String rawBaseUrl) {
    var normalized = rawBaseUrl.endsWith('/') ? rawBaseUrl : '$rawBaseUrl/';
    normalized = normalized.replaceAll(RegExp(r'(/api/v1/){2,}'), '/api/v1/');
    return normalized;
  }
}
