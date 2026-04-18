import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:survey_builder/core/auth/builder_auth_controller.dart';
import 'package:survey_builder/core/auth/builder_auth_models.dart';
import 'package:survey_builder/core/auth/builder_auth_repository.dart';

class _FakeBuilderAuthRepository extends BuilderAuthRepository {
  _FakeBuilderAuthRepository({
    this.bootstrapResult,
    this.bootstrapFailure,
    this.loginResult,
    this.loginFailure,
  }) : super(
         client: Dio(BaseOptions(baseUrl: 'http://localhost')),
         requestPath: _noopRequestPath,
       );

  static String _noopRequestPath(
    String path, [
    Map<String, dynamic>? queryParameters,
  ]) => path;

  final BuilderSession? bootstrapResult;
  final BuilderAuthFailure? bootstrapFailure;
  final BuilderSession? loginResult;
  final BuilderAuthFailure? loginFailure;
  bool logoutCalled = false;

  @override
  Future<BuilderSession> bootstrapSession() async {
    if (bootstrapFailure != null) {
      throw bootstrapFailure!;
    }
    return bootstrapResult!;
  }

  @override
  Future<BuilderSession> login({
    required String email,
    required String password,
  }) async {
    if (loginFailure != null) {
      throw loginFailure!;
    }
    return loginResult!;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override
  void dispose() {}
}

BuilderSession _session() {
  return BuilderSession(
    profile: const BuilderProfile(
      id: 'admin-1',
      firstName: 'Maria',
      surname: 'Admin',
      email: 'maria@example.com',
      isBuilderAdmin: true,
    ),
    csrfToken: 'csrf-token',
  );
}

void main() {
  test('bootstrap authenticates an existing admin session', () async {
    final controller = BuilderAuthController(
      repository: _FakeBuilderAuthRepository(bootstrapResult: _session()),
    );

    await controller.bootstrap();

    expect(controller.status, BuilderAuthStatus.authenticated);
    expect(controller.profile?.email, 'maria@example.com');
    expect(controller.csrfToken, 'csrf-token');
  });

  test('bootstrap falls back to login state when session expired', () async {
    final controller = BuilderAuthController(
      repository: _FakeBuilderAuthRepository(
        bootstrapFailure: const BuilderAuthFailure(
          code: 'BUILDER_SESSION_EXPIRED',
          userMessage: 'Sua sessão administrativa expirou.',
          retryable: true,
          statusCode: 401,
        ),
      ),
    );

    await controller.bootstrap();

    expect(controller.status, BuilderAuthStatus.unauthenticated);
    expect(controller.message, 'Sua sessão administrativa expirou.');
  });

  test(
    'login authenticates the admin shell and stores the csrf token',
    () async {
      final controller = BuilderAuthController(
        repository: _FakeBuilderAuthRepository(loginResult: _session()),
      );

      await controller.login(
        email: 'maria@example.com',
        password: 'StrongPassword123',
      );

      expect(controller.status, BuilderAuthStatus.authenticated);
      expect(controller.csrfToken, 'csrf-token');
    },
  );

  test(
    'login keeps the shell blocked when backend denies admin access',
    () async {
      final controller = BuilderAuthController(
        repository: _FakeBuilderAuthRepository(
          loginFailure: const BuilderAuthFailure(
            code: 'BUILDER_ADMIN_REQUIRED',
            userMessage:
                'Esta conta não tem permissão para acessar o construtor.',
            retryable: false,
            statusCode: 403,
          ),
        ),
      );

      await controller.login(
        email: 'maria@example.com',
        password: 'StrongPassword123',
      );

      expect(controller.status, BuilderAuthStatus.unauthenticated);
      expect(
        controller.message,
        'Esta conta não tem permissão para acessar o construtor.',
      );
    },
  );

  test('handleAuthFailure returns the app to the login entry', () async {
    final controller = BuilderAuthController(
      repository: _FakeBuilderAuthRepository(bootstrapResult: _session()),
    );
    await controller.bootstrap();

    controller.handleAuthFailure(
      const BuilderAuthFailure(
        code: 'BUILDER_SESSION_EXPIRED',
        userMessage: 'Sessão expirada durante o uso.',
        retryable: true,
        statusCode: 401,
      ),
    );

    expect(controller.status, BuilderAuthStatus.unauthenticated);
    expect(controller.message, 'Sessão expirada durante o uso.');
  });
}
