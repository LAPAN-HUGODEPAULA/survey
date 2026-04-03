import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:provider/provider.dart';

class InitialNoticePage extends StatelessWidget {
  const InitialNoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: 'Aviso Inicial de Uso',
      subtitle:
          'Revise o aviso e confirme o aceite para continuar com a jornada do paciente.',
      body: DsLegalNoticeGate(
        header: const Icon(Icons.health_and_safety_outlined, size: 56),
        proceedLabel: 'Continuar',
        onProceed: () async {
          await context.read<AppSettings>().acceptInitialNotice();
        },
      ),
    );
  }
}
