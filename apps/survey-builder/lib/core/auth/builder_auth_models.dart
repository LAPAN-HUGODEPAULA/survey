class BuilderProfile {
  const BuilderProfile({
    required this.id,
    required this.firstName,
    required this.surname,
    required this.email,
    required this.isBuilderAdmin,
  });

  factory BuilderProfile.fromJson(Map<String, dynamic> json) {
    return BuilderProfile(
      id: json['_id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      surname: json['surname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      isBuilderAdmin: json['isBuilderAdmin'] == true,
    );
  }

  final String id;
  final String firstName;
  final String surname;
  final String email;
  final bool isBuilderAdmin;

  String get fullName => [
    firstName.trim(),
    surname.trim(),
  ].where((part) => part.isNotEmpty).join(' ').trim();
}

class BuilderSession {
  const BuilderSession({required this.profile, required this.csrfToken});

  factory BuilderSession.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    if (profile is! Map) {
      throw const FormatException(
        'Resposta inesperada da sessão do construtor.',
      );
    }
    return BuilderSession(
      profile: BuilderProfile.fromJson(Map<String, dynamic>.from(profile)),
      csrfToken: json['csrfToken']?.toString() ?? '',
    );
  }

  final BuilderProfile profile;
  final String csrfToken;
}

class BuilderAuthFailure implements Exception {
  const BuilderAuthFailure({
    required this.code,
    required this.userMessage,
    required this.retryable,
    this.statusCode,
  });

  factory BuilderAuthFailure.fromJson(
    Map<String, dynamic> json, {
    int? statusCode,
  }) {
    return BuilderAuthFailure(
      code: json['code']?.toString() ?? 'BUILDER_REQUEST_FAILED',
      userMessage:
          json['userMessage']?.toString() ??
          'Não foi possível concluir a autenticação do construtor.',
      retryable: json['retryable'] != false,
      statusCode: statusCode,
    );
  }

  static BuilderAuthFailure? tryParse(Object? payload, {int? statusCode}) {
    if (payload is Map<String, dynamic>) {
      return BuilderAuthFailure.fromJson(payload, statusCode: statusCode);
    }
    if (payload is Map) {
      return BuilderAuthFailure.fromJson(
        Map<String, dynamic>.from(payload),
        statusCode: statusCode,
      );
    }
    if (payload is String && payload.trim().isNotEmpty) {
      return BuilderAuthFailure(
        code: 'BUILDER_REQUEST_FAILED',
        userMessage: payload.trim(),
        retryable: true,
        statusCode: statusCode,
      );
    }
    if (statusCode == null) {
      return null;
    }
    return BuilderAuthFailure(
      code: statusCode == 401 ? 'UNAUTHORIZED' : 'FORBIDDEN',
      userMessage: statusCode == 401
          ? 'Sua sessão administrativa expirou. Faça login novamente.'
          : 'Sua conta não tem mais acesso administrativo ao construtor.',
      retryable: statusCode == 401,
      statusCode: statusCode,
    );
  }

  final String code;
  final String userMessage;
  final bool retryable;
  final int? statusCode;

  bool get isSessionRecoveryRequired =>
      statusCode == 401 ||
      code == 'UNAUTHORIZED' ||
      code == 'BUILDER_LOGIN_REQUIRED' ||
      code == 'BUILDER_SESSION_EXPIRED' ||
      code == 'BUILDER_SESSION_INVALID';

  bool get isAdminAccessDenied =>
      statusCode == 403 ||
      code == 'FORBIDDEN' ||
      code == 'BUILDER_ADMIN_REQUIRED' ||
      code == 'BUILDER_ADMIN_REVOKED';

  bool get shouldResetShell => isSessionRecoveryRequired || isAdminAccessDenied;

  @override
  String toString() => userMessage;
}

enum BuilderAuthStatus { loading, unauthenticated, authenticated }
