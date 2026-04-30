/// Presents survey instructions and validates the comprehension answer.
///
/// The page renders instruction HTML from the selected survey and blocks
/// navigation until the expected answer is chosen.
library;

import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/models/survey/survey.dart';
import 'package:survey_app/core/navigation/app_navigator.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/shared/widgets/assessment_flow_stepper.dart';

class InstructionsPage extends StatefulWidget {
  const InstructionsPage({super.key});

  @override
  State<InstructionsPage> createState() => _InstructionsPageState();
}

class _InstructionsPageState extends State<InstructionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<AppSettings>().loadAvailableSurveys();
    });
  }

  void _startSurvey(Survey survey) {
    AppNavigator.toSurvey(context, survey: survey);
  }

  Widget _buildLoadErrorState(AppSettings settings, String errorMessage) {
    return DsError(
      message: errorMessage,
      onRetry: settings.loadAvailableSurveys,
    );
  }

  Widget _buildEmptyCatalogState(AppSettings settings) {
    return DsEmptyState(
      visual: Icon(
        Icons.library_books_outlined,
        size: 56,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: 'Nenhum questionário encontrado.',
      description:
          'Nenhum questionário encontrado. Crie o primeiro questionário para começar.',
      actionLabel: 'Tentar Novamente',
      onAction: settings.loadAvailableSurveys,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, _) {
        final survey = settings.selectedSurvey;
        final isLoading = settings.isLoadingSurveys;
        final error = settings.surveyLoadError;
        final friendlyError = error == null
            ? null
            : DsErrorMapper.toUserMessage(error);

        return DsScaffold(
          isLoading: isLoading,
          error: null,
          title: 'Instruções',
          subtitle:
              'Leia as orientações e confirme o entendimento antes de iniciar.',
          onBack: () => Navigator.of(context).pop(),
          backLabel: 'Voltar para o contexto clínico',
          scrollable: true,
          body: error != null && friendlyError != null
              ? _buildLoadErrorState(settings, friendlyError)
              : survey == null
              ? _buildEmptyCatalogState(settings)
              : Builder(
                  builder: (context) {
                    final activeInstructions = survey.instructions;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AssessmentFlowStepper(
                          currentStep: AssessmentFlowStep.instrucoes,
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
