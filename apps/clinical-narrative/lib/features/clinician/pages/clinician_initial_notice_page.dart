import 'package:clinical_narrative_app/core/models/screener_profile.dart';
import 'package:clinical_narrative_app/core/navigation/app_navigator.dart';
import 'package:clinical_narrative_app/core/providers/app_settings.dart';
import 'package:clinical_narrative_app/core/services/api_config.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClinicianInitialNoticePage extends StatefulWidget {
  const ClinicianInitialNoticePage({super.key});

  @override
  State<ClinicianInitialNoticePage> createState() =>
      _ClinicianInitialNoticePageState();
}

class _ClinicianInitialNoticePageState
    extends State<ClinicianInitialNoticePage> {
  bool _isSubmitting = false;

  Future<void> _acceptNotice() async {
    if (_isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);
    final dio = ApiConfig.createDio();
    try {
      final response = await dio.post<Object?>(
        ApiConfig.requestPath('/screeners/me/initial-notice-agreement'),
      );
      if (response.data is! Map<String, dynamic>) {
        throw const FormatException('Perfil inválido retornado pelo servidor.');
      }

      final profile = ScreenerProfile.fromJson(
        response.data as Map<String, dynamic>,
      );
      if (!mounted) {
        return;
      }
      context.read<AppSettings>().markInitialNoticeAccepted(
        profile.initialNoticeAcceptedAt ?? DateTime.now().toUtc(),
      );
      AppNavigator.toDemographics(context);
    } on DioException catch (error) {
      if (!mounted) {
        return;
      }
      final detail = error.response?.data;
      final message = detail is Map<String, dynamic> && detail['detail'] != null
          ? detail['detail'].toString()
          : 'Não foi possível registrar o aceite do aviso inicial.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível registrar o aceite do aviso inicial.',
          ),
        ),
      );
    } finally {
      dio.close();
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      scrollable: true,
      body: DsLegalNoticeGate(
        header: const Icon(Icons.medical_services_outlined, size: 56),
        proceedLabel: 'Continuar para a plataforma',
        isSubmitting: _isSubmitting,
        onProceed: _acceptNotice,
      ),
    );
  }
}
