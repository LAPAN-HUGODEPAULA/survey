import 'package:design_system_flutter/widgets/ds_wayfinding.dart';
import 'package:flutter/material.dart';

class DsFlowStepper extends StatelessWidget {
  const DsFlowStepper({
    super.key,
    required this.steps,
    required this.currentStepIndex,
    this.padding = const EdgeInsets.only(bottom: 24),
  });

  final List<String> steps;
  final int currentStepIndex;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DsStepper(
      padding: padding,
      steps: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;
        final state = index < currentStepIndex
            ? DsStepState.done
            : index == currentStepIndex
            ? DsStepState.active
            : DsStepState.todo;
        return DsStepData(label: label, state: state);
      }).toList(growable: false),
    );
  }
}
