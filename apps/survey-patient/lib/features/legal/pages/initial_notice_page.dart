import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:patient_app/core/navigation/app_navigator.dart';
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:patient_app/shared/widgets/patient_journey_stepper.dart';
import 'package:provider/provider.dart';

class InitialNoticePage extends StatelessWidget {
  const InitialNoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: 'Aviso Inicial de Uso',
      scrollable: true,
      subtitle:
          'Revise o aviso e confirme o aceite para continuar com a jornada do paciente.',
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PatientJourneyStepper(currentStep: PatientJourneyStep.aviso),
          DsLegalNoticeGate(
            header: const Icon(Icons.health_and_safety_outlined, size: 56),
            proceedLabel: 'Continuar',
            onProceed: () async {
              final settings = context.read<AppSettings>();
              await settings.acceptInitialNotice();
              await settings.loadAvailableSurveys();
              if (!context.mounted) {
                return;
              }

              final target = settings.consumePostNoticeNavigationTarget();
              final survey = settings.selectedSurvey;
              if (target == PostNoticeNavigationTarget.survey &&
                  survey != null) {
                await AppNavigator.replaceWithSurvey(context, survey: survey);
                return;
              }

              await AppNavigator.replaceWithWelcome(context);
            },
          ),
        ],
      ),
    );
  }
}
