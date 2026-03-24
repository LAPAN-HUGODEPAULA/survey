import 'package:design_system_flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/models/screener_profile.dart';
import 'package:survey_app/core/providers/api_provider.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/core/services/api_config.dart';

class ScreenerLoginPage extends StatefulWidget {
  const ScreenerLoginPage({super.key});

  @override
  State<ScreenerLoginPage> createState() => _ScreenerLoginPageState();
}

class _ScreenerLoginPageState extends State<ScreenerLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginScreener() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final apiProvider = Provider.of<ApiProvider>(context, listen: false);
      final settings = Provider.of<AppSettings>(context, listen: false);
      final dio = apiProvider.api.dio;

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        final tokenResponse = await dio.post<Object?>(
          ApiConfig.requestPath('/screeners/login'),
          data: {'email': email, 'password': password},
        );
        final tokenData = tokenResponse.data is Map<String, dynamic>
            ? tokenResponse.data as Map<String, dynamic>
            : Map<String, dynamic>.from(tokenResponse.data as Map);
        final accessToken =
            tokenData['access_token']?.toString() ??
            tokenData['accessToken']?.toString();
        if (accessToken == null || accessToken.isEmpty) {
          throw Exception('Token não retornado pelo servidor.');
        }
        apiProvider.setAuthToken(accessToken);

        final profileResponse = await dio.get<Object?>(
          ApiConfig.requestPath('/screeners/me'),
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );
        if (profileResponse.data is! Map<String, dynamic>) {
          throw Exception('Perfil inválido retornado pelo servidor.');
        }
        final profile = ScreenerProfile.fromJson(
          profileResponse.data as Map<String, dynamic>,
        );
        settings.setScreenerSession(token: accessToken, profile: profile);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login realizado com sucesso!')),
          );
          context.go('/');
        }
      } on DioException catch (e) {
        if (mounted) {
          _passwordController.clear();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_buildLoginErrorMessage(e))));
        }
      } catch (_) {
        if (mounted) {
          _passwordController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Não foi possível entrar agora. Verifique sua conexão e tente novamente.',
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  String _buildLoginErrorMessage(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    if (statusCode == 401) {
      return 'E-mail ou senha incorretos. Tente novamente.';
    }

    final detail = _extractErrorDetail(responseData);
    if (detail != null && detail.isNotEmpty) {
      return detail;
    }

    if (statusCode != null && statusCode >= 500) {
      return 'O servidor está indisponível no momento. Tente novamente em instantes.';
    }

    if (statusCode != null) {
      return 'Não foi possível entrar agora. Tente novamente.';
    }

    return 'Não foi possível entrar agora. Verifique sua conexão e tente novamente.';
  }

  Future<void> _showForgotPasswordDialog() async {
    final dialogFormKey = GlobalKey<FormState>();
    final recoveryEmailController = TextEditingController(
      text: _emailController.text.trim(),
    );
    var isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Recuperar senha'),
              content: Form(
                key: dialogFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Informe o e-mail cadastrado para gerar uma nova senha.',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: recoveryEmailController,
                      enabled: !isSubmitting,
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return 'Informe o e-mail.';
                        if (!text.contains('@')) return 'E-mail inválido.';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!(dialogFormKey.currentState?.validate() ??
                              false)) {
                            return;
                          }

                          setDialogState(() {
                            isSubmitting = true;
                          });

                          final navigator = Navigator.of(dialogContext);
                          final messenger = ScaffoldMessenger.of(context);
                          final email = recoveryEmailController.text.trim();
                          final dio = context.read<ApiProvider>().api.dio;

                          try {
                            final response = await dio.post<Object?>(
                              ApiConfig.requestPath(
                                '/screeners/recover-password',
                              ),
                              data: {'email': email},
                            );
                            final data = response.data;
                            final message =
                                data is Map<String, dynamic> &&
                                    data['message'] != null
                                ? data['message'].toString()
                                : 'Se o e-mail estiver registrado, uma nova senha será enviada.';

                            if (!mounted || !dialogContext.mounted) return;
                            _emailController.text = email;
                            navigator.pop();
                            messenger.showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                          } on DioException catch (e) {
                            final responseData = e.response?.data;
                            final message =
                                responseData is Map<String, dynamic> &&
                                    responseData['detail'] != null
                                ? responseData['detail'].toString()
                                : 'Falha ao recuperar a senha.';
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                          } catch (_) {
                            if (!mounted) return;
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Falha ao recuperar a senha.'),
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setDialogState(() {
                                isSubmitting = false;
                              });
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );

    recoveryEmailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      appBar: AppBar(title: const Text('Login do Avaliador')),
      body: Stack(
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return 'Informe o e-mail.';
                          if (!text.contains('@')) return 'E-mail inválido.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12.0),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if ((value ?? '').isEmpty) return 'Informe a senha.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _loginScreener,
                        child: const Text('Entrar'),
                      ),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text('Não tem uma conta? Registre-se'),
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : _showForgotPasswordDialog,
                        child: const Text('Esqueceu a senha?'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.1),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

String? _extractErrorDetail(dynamic data) {
  if (data is Map<String, dynamic>) {
    final detail = data['detail'];
    if (detail is String) return detail;
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map<String, dynamic> && first['msg'] is String) {
        return first['msg'] as String;
      }
    }
  }
  return null;
}
