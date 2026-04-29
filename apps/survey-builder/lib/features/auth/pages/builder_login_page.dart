import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/auth/builder_auth_controller.dart';
import 'package:survey_builder/core/auth/builder_auth_models.dart';

class BuilderLoginPage extends StatefulWidget {
  const BuilderLoginPage({super.key, required this.controller, this.message});

  final BuilderAuthController controller;
  final String? message;

  @override
  State<BuilderLoginPage> createState() => _BuilderLoginPageState();
}

class _BuilderLoginPageState extends State<BuilderLoginPage> {
  @override
  Widget build(BuildContext context) {
    final message = widget.message?.trim();
    final failure = widget.controller.failure;
    final feedback = (message == null || message.isEmpty)
        ? null
        : DsMessageBanner(
            feedback: DsFeedbackMessage(
              severity: _severityForFailure(failure),
              title: _titleForFailure(failure),
              message: message,
            ),
            margin: EdgeInsets.zero,
          );

    return DsScaffold(
      title: 'Construtor Administrativo',
      subtitle: 'Acesse com a sua conta profissional autorizada.',
      useSafeArea: true,
      showAmbientGreeting: true,
      body: DsProfessionalSignInCard(
        header: feedback,
        title: 'Entrar no construtor',
        subtitle:
            'Somente screeners promovidos como administradores podem abrir este ambiente.',
        onSubmit: (data) async {
          await widget.controller.login(
            email: data.email,
            password: data.password,
          );
          return null;
        },
      ),
    );
  }

  DsStatusType _severityForFailure(BuilderAuthFailure? failure) {
    if (failure == null) {
      return DsStatusType.warning;
    }
    if (failure.code == 'INVALID_CREDENTIALS') {
      return DsStatusType.error;
    }
    if (failure.isAdminAccessDenied) {
      return DsStatusType.warning;
    }
    if (failure.isSessionRecoveryRequired) {
      return DsStatusType.info;
    }
    return DsStatusType.error;
  }

  String _titleForFailure(BuilderAuthFailure? failure) {
    if (failure == null) {
      return 'Acesso administrativo necessário';
    }
    if (failure.code == 'INVALID_CREDENTIALS') {
      return 'Credenciais inválidas';
    }
    if (failure.isAdminAccessDenied) {
      return 'Permissão administrativa necessária';
    }
    if (failure.isSessionRecoveryRequired) {
      return 'Sessão administrativa indisponível';
    }
    return 'Falha ao autenticar';
  }
}
