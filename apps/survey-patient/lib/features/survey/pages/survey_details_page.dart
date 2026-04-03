import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:patient_app/core/models/survey/survey.dart';

class SurveyDetailsPage extends StatelessWidget {
  const SurveyDetailsPage({super.key, required this.survey});

  final Survey survey;

  @override
  Widget build(BuildContext context) {
    final displayName = survey.surveyDisplayName.isNotEmpty
        ? survey.surveyDisplayName
        : survey.surveyName;

    return DsScaffold(
      title: displayName,
      subtitle: 'Detalhes do questionario selecionado.',
      body: DsSurveyDetailsPanel(
        details: DsSurveyDetailsData(
          id: survey.id,
          displayName: displayName,
          surveyName: survey.surveyName,
          creatorId: survey.creatorId,
          createdAt: survey.createdAt,
          modifiedAt: survey.modifiedAt,
          descriptionHtml: survey.surveyDescription,
          totalQuestions: survey.questions.length,
          hasFinalNotes:
              survey.finalNotes != null && survey.finalNotes!.isNotEmpty,
        ),
      ),
    );
  }
}
