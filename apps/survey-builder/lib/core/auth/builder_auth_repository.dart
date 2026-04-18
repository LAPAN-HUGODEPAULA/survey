import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:survey_builder/core/auth/builder_auth_models.dart';
import 'package:survey_builder/core/services/api_config.dart';

typedef BuilderRequestPathBuilder =
    String Function(String path, [Map<String, dynamic>? queryParameters]);

class BuilderAuthRepository {
  BuilderAuthRepository({Dio? client, BuilderRequestPathBuilder? requestPath})
    : _client = client ?? ApiConfig.createDio(),
      _requestPath = requestPath ?? ApiConfig.requestPath;

  final Dio _client;
  final BuilderRequestPathBuilder _requestPath;

  Future<BuilderSession> bootstrapSession() async {
    try {
      final response = await _client.get<Object?>(
        _requestPath('builder/session'),
        options: Options(
          extra: const {
            'requiresBuilderCsrf': false,
            'skipBuilderAuthRecovery': true,
          },
        ),
      );
      return _mapSession(response.data);
    } on DioException catch (error) {
      throw _mapError(
        error,
        fallbackMessage:
            'Não foi possível validar a sessão do construtor agora.',
      );
    }
  }

  Future<BuilderSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post<Object?>(
        _requestPath('builder/login'),
        data: {'email': email.trim(), 'password': password},
        options: Options(
          extra: const {
            'requiresBuilderCsrf': false,
            'skipBuilderAuthRecovery': true,
          },
        ),
      );
      return _mapSession(response.data);
    } on DioException catch (error) {
      throw _mapError(
        error,
        fallbackMessage:
            'Não foi possível iniciar a sessão administrativa agora.',
      );
    }
  }

  Future<void> logout() async {
    try {
      await _client.post<Object?>(
        _requestPath('builder/logout'),
        options: Options(
          extra: const {
            'requiresBuilderCsrf': false,
            'skipBuilderAuthRecovery': true,
          },
        ),
      );
    } on DioException catch (error) {
      throw _mapError(
        error,
        fallbackMessage: 'Não foi possível encerrar a sessão do construtor.',
      );
    }
  }

  BuilderSession _mapSession(Object? payload) {
    final decoded = _coerceJson(payload);
    if (decoded is Map<String, dynamic>) {
      return BuilderSession.fromJson(decoded);
    }
    if (decoded is Map) {
      return BuilderSession.fromJson(Map<String, dynamic>.from(decoded));
    }
    throw const FormatException('Resposta inesperada da sessão do construtor.');
  }

  BuilderAuthFailure _mapError(
    DioException error, {
    required String fallbackMessage,
  }) {
    final parsed = BuilderAuthFailure.tryParse(
      _coerceJson(error.response?.data),
      statusCode: error.response?.statusCode,
    );
    if (parsed != null) {
      return parsed;
    }
    return BuilderAuthFailure(
      code: 'BUILDER_REQUEST_FAILED',
      userMessage: fallbackMessage,
      retryable: true,
      statusCode: error.response?.statusCode,
    );
  }

  dynamic _coerceJson(dynamic payload) {
    if (payload is String && payload.isNotEmpty) {
      return jsonDecode(payload);
    }
    return payload;
  }

  void dispose() {
    _client.close(force: true);
  }
}
