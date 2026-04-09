import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';

enum PatientJourneyStep {
  aviso,
  boasVindas,
  instrucoes,
  questionario,
  relatorio,
}

class PatientJourneyStepper extends StatelessWidget {
  const PatientJourneyStepper({
    super.key,
    required this.currentStep,
    this.padding = const EdgeInsets.only(bottom: 24),
  });

  final PatientJourneyStep currentStep;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DsStepper(
      padding: padding,
      steps: PatientJourneyStep.values
          .map((PatientJourneyStep step) {
            return DsStepData(
              label: _label(step),
              state: step.index < currentStep.index
                  ? DsStepState.done
                  : step == currentStep
                  ? DsStepState.active
                  : DsStepState.todo,
            );
          })
          .toList(growable: false),
    );
  }

  String _label(PatientJourneyStep step) {
    switch (step) {
      case PatientJourneyStep.aviso:
        return 'Aviso';
      case PatientJourneyStep.boasVindas:
        return 'Boas-vindas';
      case PatientJourneyStep.instrucoes:
        return 'Instruções';
      case PatientJourneyStep.questionario:
        return 'Questionário';
      case PatientJourneyStep.relatorio:
        return 'Relatório';
    }
  }
}
