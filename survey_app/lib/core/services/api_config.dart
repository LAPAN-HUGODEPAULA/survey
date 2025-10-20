library;

import 'package:flutter/foundation.dart';

/// Centralized API configuration for building backend URLs.
class ApiConfig {
  /// Base URL for the Survey backend, overridable at compile time using
  /// `--dart-define=API_BASE_URL=<url>`.
  static const String _baseUrlEnv = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1/',
  );

  /// Returns the normalized API base URL, ensuring a trailing slash to allow
  /// reliable path resolution.
  static String get baseUrl {
    if (_baseUrlEnv.endsWith('/')) {
      return _baseUrlEnv;
    }
    return '$_baseUrlEnv/';
  }

  /// Builds a [Uri] for the provided [path] relative to [baseUrl].
  static Uri resolve(String path, [Map<String, dynamic>? queryParameters]) {
    final sanitizedPath = path.startsWith('/') ? path.substring(1) : path;
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
      // ignore: avoid_print
      print('[ApiConfig] Resolved $path -> ${resolve(path)}');
    }
  }
}
