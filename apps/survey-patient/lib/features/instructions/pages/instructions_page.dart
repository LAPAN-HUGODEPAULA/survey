/// Presents survey instructions and validates the comprehension answer.
///
/// The page renders instruction HTML from the selected survey and blocks
/// navigation until the expected answer is chosen.
library;

import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:patient_app/core/models/survey/survey.dart';
import 'package:patient_app/core/navigation/app_navigator.dart';
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:patient_app/shared/widgets/patient_journey_stepper.dart';
import 'package:provider/provider.dart';

class InstructionsPage extends StatefulWidget {
  const InstructionsPage({super.key});

  @override
  State<InstructionsPage> createState() => _InstructionsPageState();
}

class _InstructionsPageState extends State<InstructionsPage> {
  void _startSurvey(Survey survey) {
    AppNavigator.toSurvey(context, survey: survey);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, _) {
        final survey = settings.selectedSurvey;
        final isLoading =
            settings.isLoadingSurveys && settings.availableSurveys.isEmpty;
        final error = settings.surveyLoadError;

        return DsScaffold(
          isLoading: isLoading,
          error: error != null
              ? 'Falha ao carregar questionário: $error'
              : survey == null
              ? 'Nenhum questionário disponível. Verifique sua conexão com a internet.'
              : null,
          title: 'Instruções',
          subtitle:
              'Leia as orientações e confirme o entendimento antes de iniciar.',
          onBack: () => Navigator.of(context).pop(),
          backLabel: 'Voltar para Boas-vindas',
          scrollable: true,
          body: survey == null
              ? const SizedBox.shrink()
              : Builder(
                  builder: (context) {
                    final activeInstructions = survey.instructions;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const PatientJourneyStepper(
                          currentStep: PatientJourneyStep.instrucoes,
                        ),
                        DsSurveyInstructionGate(
                          instructions: DsSurveyInstructionData(
                            preambleHtml: activeInstructions.preamble,
                            questionText: activeInstructions.questionText,
                            answers: activeInstructions.answers,
                            correctAnswer: activeInstructions.correctAnswer,
                          ),
                          onContinue: () => _startSurvey(survey),
                        ),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }
}
