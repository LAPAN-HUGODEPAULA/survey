import 'package:clinical_narrative_app/core/config/runtime_config.dart';
import 'package:clinical_narrative_app/core/navigation/app_navigator.dart';
import 'package:clinical_narrative_app/core/services/api_config.dart';
import 'package:clinical_narrative_app/shared/widgets/clinician_navigation_app_bar.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ClinicianRegistrationPage extends StatelessWidget {
  const ClinicianRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      appBar: const ClinicianNavigationAppBar(
        title: Text('Cadastro do Profissional'),
      ),
      body: DsProfessionalSignUpCard(
        header: const Icon(Icons.medical_information_outlined, size: 56),
        subtitle:
            'Crie sua conta profissional com os mesmos dados exigidos no ambiente de avaliação.',
        onLookupCep: _lookupCep,
        onSubmit: _register,
        onShowSignIn: () => AppNavigator.toLogin(context),
      ),
    );
  }

  Future<DsAuthOperationResult?> _register(
    DsScreenerRegistrationData data,
  ) async {
    final dio = ApiConfig.createDio();

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
      return const DsAuthOperationResult.success(
        'Cadastro realizado com sucesso. Faça login para continuar.',
      );
    } on DioException catch (error) {
      return DsAuthOperationResult.error(_buildRegistrationErrorMessage(error));
    } catch (error) {
      return DsAuthOperationResult.error('Falha no cadastro: $error');
    } finally {
      dio.close();
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
      return DsCepLookupResult(
        street: (data['logradouro'] ?? '').toString(),
        neighborhood: (data['bairro'] ?? '').toString(),
        city: (data['localidade'] ?? '').toString(),
        state: (data['uf'] ?? '').toString().toUpperCase(),
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
    return 'Falha no cadastro: $detail';
  }
  if (response?.statusCode != null) {
    return 'Falha no cadastro (HTTP ${response?.statusCode}).';
  }
  return 'Falha no cadastro: ${error.message ?? 'Erro de conexão.'}';
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
