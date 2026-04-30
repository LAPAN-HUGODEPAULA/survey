import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';

enum PatientJourneyStep {
  aviso,
  identificacao,
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
    return DsFlowStepper(
      padding: padding,
      currentStepIndex: currentStep.index,
      steps: PatientJourneyStep.values
          .map(_label)
          .toList(growable: false),
    );
  }

  String _label(PatientJourneyStep step) {
    switch (step) {
      case PatientJourneyStep.aviso:
        return 'Aviso';
      case PatientJourneyStep.identificacao:
        return 'Identificação';
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
