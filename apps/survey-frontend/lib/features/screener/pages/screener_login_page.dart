import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/providers/api_provider.dart';
import 'package:survey_app/core/utils/form_validators.dart';
import 'package:survey_app/core/utils/validator_sets.dart';
import 'package:survey_app/shared/widgets/custom_text_form_field.dart';
import 'package:survey_app/shared/widgets/loading_button.dart';
import 'package:survey_app/shared/widgets/progress_indicator_modal.dart';
import 'package:survey_backend_api/survey_backend_api.dart';

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
      final api = apiProvider.api;

      try {
        final screenerLogin = ScreenerLogin((b) => b
          ..email = _emailController.text
          ..password = _passwordController.text);

        final Token token = await api.getDefaultApi().loginScreener(screenerLogin: screenerLogin);

        // TODO: Store the token securely (e.g., using shared_preferences or flutter_secure_storage)
        // For now, just print it.
        debugPrint('Access Token: ${token.access_token}');
        debugPrint('Token Type: ${token.token_type}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful!')),
          );
          context.go('/'); // Navigate to home page
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: $e')),
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
    return ProgressIndicatorModal(
      inAsyncCall: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login de Screener'),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextFormField(
                    controller: _emailController,
                    labelText: 'E-mail',
                    keyboardType: TextInputType.emailAddress,
                    validator: FormValidators.compose([
                      ValidatorSets.required,
                      ValidatorSets.email,
                    ]),
                  ),
                  CustomTextFormField(
                    controller: _passwordController,
                    labelText: 'Senha',
                    obscureText: true,
                    validator: ValidatorSets.required,
                  ),
                  const SizedBox(height: 16.0),
                  LoadingButton(
                    onPressed: _loginScreener,
                    isLoading: _isLoading,
                    text: 'Entrar',
                  ),
                  TextButton(
                    onPressed: () {
                      context.go('/register'); // Navigate to registration page
                    },
                    child: const Text('Não tem uma conta? Registre-se'),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to password recovery page
                      debugPrint('Forgot password clicked');
                    },
                    child: const Text('Esqueceu a senha?'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
