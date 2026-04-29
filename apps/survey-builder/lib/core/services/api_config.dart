import 'package:dio/dio.dart';
import 'package:runtime_api_url/runtime_api_url.dart';
import 'package:survey_builder/core/auth/builder_auth_models.dart';
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

  static String? Function()? _csrfTokenProvider;
  static void Function(BuilderAuthFailure error)? _authFailureHandler;

  static void configureBuilderAuth({
    String? Function()? csrfTokenProvider,
    void Function(BuilderAuthFailure error)? onAuthFailure,
  }) {
    _csrfTokenProvider = csrfTokenProvider;
    _authFailureHandler = onAuthFailure;
  }

  static void clearBuilderAuth() {
    _csrfTokenProvider = null;
    _authFailureHandler = null;
  }

  static Dio createDio({Map<String, String>? headers}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: dioBaseUrl,
        headers: {...defaultHeaders, if (headers != null) ...headers},
        extra: const {'withCredentials': true},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final explicitRequirement = options.extra['requiresBuilderCsrf'];
          final shouldAttachCsrf = explicitRequirement is bool
              ? explicitRequirement
              : _isStateChanging(options.method) &&
                    !_isBuilderAuthPath(options.path);
          if (shouldAttachCsrf) {
            final token = _csrfTokenProvider?.call();
            if (token != null && token.isNotEmpty) {
              options.headers['X-Builder-CSRF'] = token;
            }
          }
          handler.next(options);
        },
        onError: (error, handler) {
          final skipRecovery =
              error.requestOptions.extra['skipBuilderAuthRecovery'] == true;
          if (!skipRecovery) {
            final failure = BuilderAuthFailure.tryParse(
              error.response?.data,
              statusCode: error.response?.statusCode,
            );
            if (failure != null && failure.shouldResetShell) {
              _authFailureHandler?.call(failure);
            }
          }
          handler.next(error);
        },
      ),
    );
    return dio;
  }

  static String get dioBaseUrl {
    return RuntimeApiUrl.dioBaseUrl(baseUrl);
  }

  static bool _isStateChanging(String? method) {
    final normalized = method?.toUpperCase();
    return normalized == 'POST' ||
        normalized == 'PUT' ||
        normalized == 'PATCH' ||
        normalized == 'DELETE';
  }

  static bool _isBuilderAuthPath(String path) {
    final normalized = path.toLowerCase();
    return normalized.contains('/builder/login') ||
        normalized.contains('/builder/logout') ||
        normalized.contains('/builder/session');
  }
}
