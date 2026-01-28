import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/models/screener_profile.dart';
import 'package:survey_app/core/providers/api_provider.dart';
import 'package:survey_app/core/providers/app_settings.dart';

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
        final tokenResponse = await dio.post(
          '/screeners/login',
          data: {'email': email, 'password': password},
        );
        final tokenData = tokenResponse.data is Map<String, dynamic>
            ? tokenResponse.data as Map<String, dynamic>
            : Map<String, dynamic>.from(tokenResponse.data as Map);
        final accessToken = tokenData['access_token']?.toString() ??
            tokenData['accessToken']?.toString();
        if (accessToken == null || accessToken.isEmpty) {
          throw Exception('Token não retornado pelo servidor.');
        }
        apiProvider.setAuthToken(accessToken);

        final profileResponse = await dio.get(
          '/screeners/me',
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
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha no login: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login de Screener'),
      ),
      body: Stack(
        children: [
          Center(
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
                      onPressed: () {
                        debugPrint('Forgot password clicked');
                      },
                      child: const Text('Esqueceu a senha?'),
                    ),
                  ],
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
