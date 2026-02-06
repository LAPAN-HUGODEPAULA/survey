library;

import 'package:flutter/foundation.dart';

/// Centralized API configuration for building backend URLs.
class ApiConfig {
  /// Base URL for the Survey backend, overridable at compile time using
  /// `--dart-define=API_BASE_URL=<url>`.
  static const String _baseUrlEnv = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  /// Returns the normalized API base URL, ensuring a trailing slash to allow
  /// reliable path resolution.
  static String get baseUrl {
    return _normalizeBaseUrl(_baseUrlEnv);
  }

  /// Builds a [Uri] for the provided [path] relative to [baseUrl].
  static Uri resolve(String path, [Map<String, dynamic>? queryParameters]) {
    final sanitizedPath = _stripLeadingSlash(path);
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

  /// Base URL without trailing slash for HTTP clients that already
  /// prefix request paths with a leading slash.
  static String get dioBaseUrl {
    return baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
  }

  /// Helper to log the resolved URL when debugging.
  static void debugLogResolved(String path) {
    if (kDebugMode) {
      // This is intentionally left empty.
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
