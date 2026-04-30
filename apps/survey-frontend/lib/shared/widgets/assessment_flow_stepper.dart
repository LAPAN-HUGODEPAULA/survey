import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';

enum AssessmentFlowStep {
  dadosPaciente,
  contextoClinico,
  instrucoes,
  questionario,
  relatorio,
}

class AssessmentFlowStepper extends StatelessWidget {
  const AssessmentFlowStepper({
    super.key,
    required this.currentStep,
    this.padding = const EdgeInsets.only(bottom: 24),
  });

  final AssessmentFlowStep currentStep;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DsFlowStepper(
      padding: padding,
      currentStepIndex: currentStep.index,
      steps: AssessmentFlowStep.values
          .map(_label)
          .toList(growable: false),
    );
  }

  String _label(AssessmentFlowStep step) {
    switch (step) {
      case AssessmentFlowStep.dadosPaciente:
        return 'Dados do paciente';
      case AssessmentFlowStep.contextoClinico:
        return 'Contexto clínico';
      case AssessmentFlowStep.instrucoes:
        return 'Instruções';
      case AssessmentFlowStep.questionario:
        return 'Questionário';
      case AssessmentFlowStep.relatorio:
        return 'Relatório';
    }
  }
}
