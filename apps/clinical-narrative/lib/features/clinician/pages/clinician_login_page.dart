import 'package:clinical_narrative_app/core/models/screener_profile.dart';
import 'package:clinical_narrative_app/core/navigation/app_navigator.dart';
import 'package:clinical_narrative_app/core/providers/app_settings.dart';
import 'package:clinical_narrative_app/core/providers/chat_provider.dart';
import 'package:clinical_narrative_app/core/services/api_config.dart';
import 'package:clinical_narrative_app/features/clinician/pages/clinician_registration_page.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClinicianLoginPage extends StatelessWidget {
  const ClinicianLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: 'Login do profissional',
      subtitle:
          'Acesse sua conta para iniciar sessoes e registrar narrativas clinicas.',
      scrollable: true,
      body: DsProfessionalSignInCard(
        header: const Icon(Icons.medical_services_outlined, size: 56),
        subtitle:
            'Entre com sua conta profissional cadastrada para iniciar sessões e registrar narrativas clínicas.',
        onSubmit: (credentials) => _login(context, credentials),
        onForgotPassword: _recoverPassword,
        onShowSignUp: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => const ClinicianRegistrationPage(),
            ),
          );
        },
      ),
    );
  }

  Future<DsAuthOperationResult?> _login(
    BuildContext context,
    DsScreenerLoginData credentials,
  ) async {
    final settings = context.read<AppSettings>();
    final chatProvider = context.read<ChatProvider>();
    final dio = ApiConfig.createDio();

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
      if (!context.mounted) {
        return const DsAuthOperationResult.success();
      }
      settings.setScreenerSession(token: accessToken, profile: profile);
      chatProvider.setAuthToken(accessToken);

      if (settings.requiresInitialNoticeAgreement) {
        AppNavigator.toInitialNotice(context);
      } else {
        AppNavigator.toDemographics(context);
      }
      return const DsAuthOperationResult.success();
    } on DioException catch (error) {
      return DsAuthOperationResult.error(_buildLoginErrorMessage(error));
    } catch (_) {
      return const DsAuthOperationResult.error(
        'Não foi possível entrar agora. Verifique sua conexão e tente novamente.',
      );
    } finally {
      dio.close();
    }
  }

  Future<DsAuthOperationResult?> _recoverPassword(String email) async {
    final dio = ApiConfig.createDio();

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
    } finally {
      dio.close();
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
