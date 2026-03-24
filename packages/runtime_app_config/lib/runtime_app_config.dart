/// Shared helpers for runtime `config.json` loading and compile-time fallbacks.
library;

import 'package:dio/dio.dart';

typedef RuntimeConfigFetcher = Future<Object?> Function(Uri uri);

/// Loads string-based runtime configuration for Flutter apps that serve a
/// `config.json` file next to the compiled web bundle.
final class RuntimeAppConfig {
  /// Resolves the API base URL from compile-time environment values.
  ///
  /// When `API_BASE_URL` is not set, Docker VPS builds default to `/api/v1`.
  static String resolveApiBaseUrl({
    String? apiBaseUrlEnv,
    String? flavor,
    String dockerFlavorName = 'dockerVps',
    String dockerDefaultApiBaseUrl = '/api/v1',
    String missingApiBaseUrlMessage = 'API_BASE_URL is not set.',
  }) {
    final resolvedApiBaseUrl =
        apiBaseUrlEnv ??
        const String.fromEnvironment('API_BASE_URL', defaultValue: '');
    final resolvedFlavor =
        flavor ?? const String.fromEnvironment('FLAVOR', defaultValue: 'dockerVps');

    if (resolvedApiBaseUrl.isNotEmpty) {
      return resolvedApiBaseUrl;
    }
    if (resolvedFlavor == dockerFlavorName) {
      return dockerDefaultApiBaseUrl;
    }
    throw StateError(missingApiBaseUrlMessage);
  }

  /// Loads string configuration values from `config.json`, falling back to the
  /// provided defaults when the file is unavailable or incomplete.
  static Future<Map<String, String>> loadStringConfig({
    required Map<String, String> fallback,
    String configPath = 'config.json',
    Dio? client,
    RuntimeConfigFetcher? fetcher,
    Uri? baseUri,
  }) async {
    try {
      final raw = await (fetcher ?? _dioFetcher(client))( 
        (baseUri ?? Uri.base).resolve(configPath),
      );
      return mergeStringConfig(fallback: fallback, raw: raw);
    } catch (_) {
      return Map<String, String>.unmodifiable(Map<String, String>.of(fallback));
    }
  }

  /// Merges only known string keys from a decoded JSON document.
  static Map<String, String> mergeStringConfig({
    required Map<String, String> fallback,
    Object? raw,
  }) {
    if (raw is! Map) {
      return Map<String, String>.unmodifiable(Map<String, String>.of(fallback));
    }

    final typed = Map<String, dynamic>.from(raw);
    final merged = Map<String, String>.of(fallback);
    for (final entry in fallback.entries) {
      final value = typed[entry.key];
      if (value != null) {
        merged[entry.key] = value.toString();
      }
    }
    return Map<String, String>.unmodifiable(merged);
  }

  static RuntimeConfigFetcher _dioFetcher(Dio? client) {
    final resolvedClient = client ?? Dio();
    return (uri) async {
      final response = await resolvedClient.getUri<Object?>(
        uri,
        options: Options(responseType: ResponseType.json),
      );
      return response.data;
    };
  }
}
