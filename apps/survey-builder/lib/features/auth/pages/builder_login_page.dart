import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/auth/builder_auth_controller.dart';

class BuilderLoginPage extends StatefulWidget {
  const BuilderLoginPage({super.key, required this.controller, this.message});

  final BuilderAuthController controller;
  final String? message;

  @override
  State<BuilderLoginPage> createState() => _BuilderLoginPageState();
}

class _BuilderLoginPageState extends State<BuilderLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await widget.controller.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message?.trim();
    final feedback = (message == null || message.isEmpty)
        ? null
        : DsMessageBanner(
            feedback: DsFeedbackMessage(
              severity: DsStatusType.warning,
              title: 'Acesso administrativo necessário',
              message: message,
            ),
            margin: EdgeInsets.zero,
          );

    return DsScaffold(
      title: 'Construtor Administrativo',
      subtitle: 'Acesse com a sua conta profissional autorizada.',
      useSafeArea: true,
      showAmbientGreeting: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (feedback != null) ...[feedback, const SizedBox(height: 16)],
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Entrar no construtor',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Somente screeners promovidos como administradores podem abrir este ambiente.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.username],
                          decoration: const InputDecoration(
                            labelText: 'E-mail profissional',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.isEmpty) {
                              return 'Informe o e-mail.';
                            }
                            if (!trimmed.contains('@')) {
                              return 'Informe um e-mail válido.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          decoration: const InputDecoration(
                            labelText: 'Senha',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if ((value ?? '').isEmpty) {
                              return 'Informe a senha.';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: widget.controller.isSubmitting
                              ? null
                              : _submit,
                          icon: widget.controller.isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.lock_open),
                          label: Text(
                            widget.controller.isSubmitting
                                ? 'Validando acesso...'
                                : 'Entrar',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
