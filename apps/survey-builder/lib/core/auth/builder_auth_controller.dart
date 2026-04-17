import 'package:flutter/foundation.dart';
import 'package:survey_builder/core/auth/builder_auth_models.dart';
import 'package:survey_builder/core/auth/builder_auth_repository.dart';

class BuilderAuthController extends ChangeNotifier {
  BuilderAuthController({BuilderAuthRepository? repository})
    : _repository = repository ?? BuilderAuthRepository();

  final BuilderAuthRepository _repository;

  BuilderAuthStatus _status = BuilderAuthStatus.loading;
  BuilderSession? _session;
  String? _message;
  bool _submitting = false;

  BuilderAuthStatus get status => _status;
  BuilderSession? get session => _session;
  BuilderProfile? get profile => _session?.profile;
  String? get csrfToken => _session?.csrfToken;
  String? get message => _message;
  bool get isSubmitting => _submitting;
  bool get isAuthenticated => _status == BuilderAuthStatus.authenticated;

  Future<void> bootstrap() async {
    _status = BuilderAuthStatus.loading;
    _message = null;
    notifyListeners();

    try {
      final session = await _repository.bootstrapSession();
      _setAuthenticated(session);
    } on BuilderAuthFailure catch (error) {
      _setUnauthenticated(error.userMessage);
    } catch (_) {
      _setUnauthenticated(
        'Não foi possível abrir o construtor agora. Faça login novamente.',
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    _submitting = true;
    _message = null;
    notifyListeners();

    try {
      final session = await _repository.login(email: email, password: password);
      _setAuthenticated(session);
    } on BuilderAuthFailure catch (error) {
      _submitting = false;
      _setUnauthenticated(error.userMessage, notify: true);
    } catch (_) {
      _submitting = false;
      _setUnauthenticated(
        'Não foi possível iniciar a sessão administrativa agora.',
        notify: true,
      );
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {
      // Always clear local state, even when the server session is already gone.
    }
    _setUnauthenticated('Sessão encerrada.', notify: true);
  }

  void handleAuthFailure(BuilderAuthFailure failure) {
    if (!failure.shouldResetShell) {
      return;
    }
    _setUnauthenticated(failure.userMessage, notify: true);
  }

  void _setAuthenticated(BuilderSession session) {
    _session = session;
    _status = BuilderAuthStatus.authenticated;
    _message = null;
    _submitting = false;
    notifyListeners();
  }

  void _setUnauthenticated(String message, {bool notify = true}) {
    _session = null;
    _status = BuilderAuthStatus.unauthenticated;
    _message = message;
    _submitting = false;
    if (notify) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
