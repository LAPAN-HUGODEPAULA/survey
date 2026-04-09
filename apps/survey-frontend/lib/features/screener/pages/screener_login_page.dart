import 'package:design_system_flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/models/screener_profile.dart';
import 'package:survey_app/core/providers/api_provider.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/core/services/api_config.dart';

class ScreenerLoginPage extends StatelessWidget {
  const ScreenerLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: 'Login do avaliador',
      subtitle: 'Acesse sua conta profissional para iniciar uma nova triagem.',
      scrollable: true,
      body: DsProfessionalSignInCard(
        header: Image.asset('assets/images/lapan_logo_reduced.png', height: 56),
        onSubmit: (credentials) => _loginScreener(context, credentials),
        onForgotPassword: (email) => _recoverPassword(context, email),
        onShowSignUp: () => context.go('/register'),
      ),
    );
  }

  Future<DsAuthOperationResult?> _loginScreener(
    BuildContext context,
    DsScreenerLoginData credentials,
  ) async {
    final apiProvider = context.read<ApiProvider>();
    final settings = context.read<AppSettings>();
    final dio = apiProvider.api.dio;

    try {
      final tokenResponse = await dio.post<Object?>(
        ApiConfig.requestPath('/screeners/login'),
        data: {'email': credentials.email, 'password': credentials.password},
      );
      final tokenData = tokenResponse.data is Map<String, dynamic>
          ? tokenResponse.data as Map<String, dynamic>
          : Map<String, dynamic>.from(tokenResponse.data as Map);
      final accessToken =
          tokenData['access_token']?.toString() ??
          tokenData['accessToken']?.toString();
      if (accessToken == null || accessToken.isEmpty) {
        return const DsAuthOperationResult.error(
          'Token não retornado pelo servidor.',
        );
      }

      apiProvider.setAuthToken(accessToken);
      final profileResponse = await dio.get<Object?>(
        ApiConfig.requestPath('/screeners/me'),
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (profileResponse.data is! Map<String, dynamic>) {
        return const DsAuthOperationResult.error(
          'Perfil inválido retornado pelo servidor.',
        );
      }

      final profile = ScreenerProfile.fromJson(
        profileResponse.data as Map<String, dynamic>,
      );
      settings.setScreenerSession(token: accessToken, profile: profile);

      if (context.mounted) {
        context.go('/');
      }
      return const DsAuthOperationResult.success();
    } on DioException catch (error) {
      return DsAuthOperationResult.error(_buildLoginErrorMessage(error));
    } catch (_) {
      return const DsAuthOperationResult.error(
        'Não foi possível entrar agora. Verifique sua conexão e tente novamente.',
      );
    }
  }

  Future<DsAuthOperationResult?> _recoverPassword(
    BuildContext context,
    String email,
  ) async {
    final dio = context.read<ApiProvider>().api.dio;

    try {
      final response = await dio.post<Object?>(
        ApiConfig.requestPath('/screeners/recover-password'),
        data: {'email': email},
      );
      final data = response.data;
      final message = data is Map<String, dynamic> && data['message'] != null
          ? data['message'].toString()
          : 'Se o e-mail estiver registrado, uma nova senha será enviada.';
      return DsAuthOperationResult.success(message);
    } on DioException catch (error) {
      final responseData = error.response?.data;
      final message =
          responseData is Map<String, dynamic> && responseData['detail'] != null
          ? responseData['detail'].toString()
          : 'Falha ao recuperar a senha.';
      return DsAuthOperationResult.error(message);
    } catch (_) {
      return const DsAuthOperationResult.error('Falha ao recuperar a senha.');
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

String? _extractErrorDetail(dynamic data) {
  if (data is Map<String, dynamic>) {
    final detail = data['detail'];
    if (detail is String) {
      return detail;
    }
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map<String, dynamic> && first['msg'] is String) {
        return first['msg'] as String;
      }
    }
  }
  return null;
}
