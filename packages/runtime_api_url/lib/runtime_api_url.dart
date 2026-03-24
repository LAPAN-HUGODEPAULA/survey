/// Shared helpers for normalizing backend base URLs and request paths.
library;

/// URL helpers used by Flutter clients that load their backend endpoint at
/// runtime and may receive either a root host or a host that already includes
/// `/api/v1`.
final class RuntimeApiUrl {
  /// Returns a normalized base URL with a trailing slash.
  static String normalizeBaseUrl(String rawBaseUrl) {
    if (rawBaseUrl.isEmpty) {
      throw StateError('API_BASE_URL is not set.');
    }
    return rawBaseUrl.endsWith('/') ? rawBaseUrl : '$rawBaseUrl/';
  }

  /// Returns the base URL without a trailing slash for Dio [BaseOptions].
  static String dioBaseUrl(String rawBaseUrl) {
    final baseUrl = normalizeBaseUrl(rawBaseUrl);
    return baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
  }

  /// Resolves [path] against [rawBaseUrl] while stripping any duplicated base
  /// API prefix such as `/api/v1`.
  static Uri resolve(
    String rawBaseUrl,
    String path, [
    Map<String, dynamic>? queryParameters,
  ]) {
    final baseUrl = normalizeBaseUrl(rawBaseUrl);
    final normalizedUri = Uri.parse(
      baseUrl,
    ).resolve(_stripLeadingSlash(requestPath(rawBaseUrl, path)));
    if (queryParameters == null || queryParameters.isEmpty) {
      return normalizedUri;
    }

    return normalizedUri.replace(
      queryParameters: queryParameters.map(
        (key, value) => MapEntry(key, value?.toString()),
      ),
    );
  }

  /// Returns a request path safe to pass to Dio regardless of whether the
  /// caller included the API prefix in [path].
  static String requestPath(
    String rawBaseUrl,
    String path, [
    Map<String, dynamic>? queryParameters,
  ]) {
    final parsed = Uri.parse(path);
    var normalizedPath = parsed.path.isEmpty ? path : parsed.path;
    if (normalizedPath.isEmpty) {
      normalizedPath = '/';
    }
    if (!normalizedPath.startsWith('/')) {
      normalizedPath = '/$normalizedPath';
    }

    final basePath = _normalizedBasePath(rawBaseUrl);
    if (basePath.isNotEmpty &&
        (normalizedPath == basePath ||
            normalizedPath.startsWith('$basePath/'))) {
      normalizedPath = normalizedPath.substring(basePath.length);
      if (normalizedPath.isEmpty) {
        normalizedPath = '/';
      }
    }

    final mergedQueryParameters = <String, dynamic>{
      if (parsed.queryParameters.isNotEmpty) ...parsed.queryParameters,
      if (queryParameters != null) ...queryParameters,
    };

    return Uri(
      path: normalizedPath,
      queryParameters: mergedQueryParameters.isEmpty
          ? null
          : mergedQueryParameters.map(
              (key, value) => MapEntry(key, value?.toString()),
            ),
    ).toString();
  }

  static String _normalizedBasePath(String rawBaseUrl) {
    final path = Uri.parse(normalizeBaseUrl(rawBaseUrl)).path;
    if (path.isEmpty || path == '/') {
      return '';
    }
    return path.endsWith('/') ? path.substring(0, path.length - 1) : path;
  }

  static String _stripLeadingSlash(String path) {
    return path.startsWith('/') ? path.substring(1) : path;
  }
}
