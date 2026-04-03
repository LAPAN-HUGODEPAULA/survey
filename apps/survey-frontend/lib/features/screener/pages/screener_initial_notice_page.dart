import 'package:design_system_flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/models/screener_profile.dart';
import 'package:survey_app/core/providers/api_provider.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/core/services/api_config.dart';

class ScreenerInitialNoticePage extends StatefulWidget {
  const ScreenerInitialNoticePage({super.key});

  @override
  State<ScreenerInitialNoticePage> createState() =>
      _ScreenerInitialNoticePageState();
}

class _ScreenerInitialNoticePageState extends State<ScreenerInitialNoticePage> {
  bool _isSubmitting = false;

  Future<void> _acceptNotice() async {
    if (_isSubmitting) {
      return;
    }

    final apiProvider = context.read<ApiProvider>();
    final settings = context.read<AppSettings>();
    final dio = apiProvider.api.dio;

    setState(() => _isSubmitting = true);
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
      settings.markInitialNoticeAccepted(
        profile.initialNoticeAcceptedAt ?? DateTime.now().toUtc(),
      );
      if (!mounted) {
        return;
      }
      context.go('/demographics');
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
        header: Image.asset('assets/images/lapan_logo_reduced.png', height: 56),
        proceedLabel: 'Continuar para a plataforma',
        isSubmitting: _isSubmitting,
        onProceed: _acceptNotice,
      ),
    );
  }
}
