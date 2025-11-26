library;

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:patient_app/core/services/api_config.dart';

/// Lightweight HTTP client wrapper that centralizes error handling.
class ApiClient {
  ApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  /// Executes a GET request and returns the decoded JSON body.
  Future<dynamic> getJson(String path) async {
    final response = await _httpClient.get(
      ApiConfig.resolve(path),
      headers: ApiConfig.defaultHeaders,
    );
    _throwIfError(response);
    return _decodeBody(response);
  }

  /// Executes a POST request with a JSON payload.
  Future<dynamic> postJson(String path, Map<String, dynamic> body) async {
    final response = await _httpClient.post(
      ApiConfig.resolve(path),
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode(body),
    );
    _throwIfError(response);
    return _decodeBody(response);
  }

  /// Disposes the underlying HTTP client. Call when the object is no longer needed.
  void dispose() {
    _httpClient.close();
  }

  void _throwIfError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: _safeErrorMessage(response),
      uri: response.request?.url,
    );
  }

  dynamic _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }
    return jsonDecode(response.body);
  }

  String _safeErrorMessage(http.Response response) {
    if (response.body.isEmpty) {
      return 'Request failed with status ${response.statusCode}';
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded['detail']?.toString() ??
            decoded['message']?.toString() ??
            'Request failed with status ${response.statusCode}';
      }
      return decoded.toString();
    } catch (_) {
      return response.body;
    }
  }
}

/// Exception thrown when the API returns a non-successful status code.
class ApiException implements Exception {
  ApiException({
    required this.statusCode,
    required this.message,
    this.uri,
  });

  final int statusCode;
  final String message;
  final Uri? uri;

  @override
  String toString() {
    final buffer = StringBuffer('ApiException($statusCode)');
    if (uri != null) {
      buffer.write(' for $uri');
    }
    buffer.write(': $message');
    return buffer.toString();
  }
}
