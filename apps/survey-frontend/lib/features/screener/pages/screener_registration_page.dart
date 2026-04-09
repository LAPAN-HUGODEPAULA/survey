import 'package:design_system_flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/config/runtime_config.dart';
import 'package:survey_app/core/providers/api_provider.dart';
import 'package:survey_app/core/services/api_config.dart';

class ScreenerRegistrationPage extends StatelessWidget {
  const ScreenerRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: 'Cadastro do avaliador',
      subtitle:
          'Crie uma conta profissional para acessar os fluxos protegidos da plataforma.',
      scrollable: true,
      body: DsProfessionalSignUpCard(
        header: Image.asset('assets/images/lapan_logo_reduced.png', height: 56),
        onLookupCep: _lookupCep,
        onSubmit: (data) => _registerScreener(context, data),
        onShowSignIn: () => context.go('/login'),
      ),
    );
  }

  Future<DsAuthOperationResult?> _registerScreener(
    BuildContext context,
    DsScreenerRegistrationData data,
  ) async {
    final dio = context.read<ApiProvider>().api.dio;

    try {
      await dio.post<Object?>(
        ApiConfig.requestPath('/screeners/register'),
        data: {
          'cpf': data.cpf,
          'firstName': data.firstName,
          'surname': data.surname,
          'email': data.email,
          'password': data.password,
          'phone': data.phone,
          'address': {
            'postalCode': data.address.postalCode,
            'street': data.address.street,
            'number': data.address.number,
            'complement': data.address.complement,
            'neighborhood': data.address.neighborhood,
            'city': data.address.city,
            'state': data.address.state,
          },
          'professionalCouncil': {
            'type': data.professionalCouncil.type,
            'registrationNumber': data.professionalCouncil.registrationNumber,
          },
          'jobTitle': data.jobTitle,
          'degree': data.degree,
          'darvCourseYear': data.darvCourseYear,
        },
      );

      if (context.mounted) {
        context.go('/login');
      }
      return const DsAuthOperationResult.success(
        'Avaliador registrado com sucesso!',
      );
    } on DioException catch (error) {
      return DsAuthOperationResult.error(_buildRegistrationErrorMessage(error));
    } catch (error) {
      return DsAuthOperationResult.error('Falha no registro: $error');
    }
  }

  Future<DsCepLookupResult?> _lookupCep(String digits) async {
    try {
      final runtimeBaseUrl = _resolveViaCepBaseUrl();
      final baseUrl = runtimeBaseUrl.endsWith('/')
          ? runtimeBaseUrl
          : '$runtimeBaseUrl/';
      final uri = Uri.parse(baseUrl).resolve('ws/$digits/json/');
      final response = await Dio().getUri<Object?>(
        uri,
        options: Options(responseType: ResponseType.json),
      );
      final data = response.data;
      if (data is! Map || data['erro'] == true) {
        return null;
      }
      final state = (data['uf'] ?? '').toString().toUpperCase();
      return DsCepLookupResult(
        street: (data['logradouro'] ?? '').toString(),
        neighborhood: (data['bairro'] ?? '').toString(),
        city: (data['localidade'] ?? '').toString(),
        state: state,
      );
    } catch (_) {
      return null;
    }
  }
}

String _resolveViaCepBaseUrl() {
  try {
    return RuntimeConfig.instance.viaCepBaseUrl;
  } catch (_) {
    return 'https://viacep.com.br/';
  }
}

String _buildRegistrationErrorMessage(DioException error) {
  final response = error.response;
  final detail = _extractRegistrationErrorDetail(response?.data);
  if (detail != null && detail.isNotEmpty) {
    return 'Falha no registro: $detail';
  }
  if (response?.statusCode != null) {
    return 'Falha no registro (HTTP ${response?.statusCode}).';
  }
  return 'Falha no registro: ${error.message ?? 'Erro de conexão.'}';
}

String? _extractRegistrationErrorDetail(dynamic data) {
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
