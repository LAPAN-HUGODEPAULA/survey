/// Screen that presents the active survey one question at a time.
///
/// It tracks the current question index, collects answers in order, and hands
/// the completed payload to the thank-you flow.
library;

import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:patient_app/core/models/survey/survey.dart';
import 'package:patient_app/core/navigation/app_navigator.dart';
import 'package:patient_app/shared/widgets/patient_journey_stepper.dart';

/// Renders the selected survey in a linear, button-based questionnaire flow.
class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key, required this.survey});

  final Survey survey;

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  late final Survey _survey = widget.survey;

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: _survey.surveyDisplayName.isNotEmpty
          ? _survey.surveyDisplayName
          : _survey.surveyName,
      subtitle: 'Responda cada pergunta em sequência para concluir a triagem.',
      onBack: () => Navigator.of(context).pop(),
      backLabel: 'Voltar para Instruções',
      body: Column(
        children: [
          const PatientJourneyStepper(
            currentStep: PatientJourneyStep.questionario,
          ),
          Expanded(
            child: DsSurveyQuestionRunner(
              surveyTitle: _survey.surveyDisplayName.isNotEmpty
                  ? _survey.surveyDisplayName
                  : _survey.surveyName,
              questions: _survey.questions
                  .map(
                    (question) => DsSurveyQuestionData(
                      id: question.id,
                      questionText: question.questionText,
                      answers: question.answers,
                    ),
                  )
                  .toList(growable: false),
              onCompleted: (answers) {
                AppNavigator.toThankYou(
                  context,
                  survey: _survey,
                  surveyAnswers: answers,
                  surveyQuestions: _survey.questions,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
