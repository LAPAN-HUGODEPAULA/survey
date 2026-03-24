/// Presents survey instructions and validates the comprehension answer.
///
/// The page renders instruction HTML from the selected survey and blocks
/// navigation until the expected answer is chosen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:patient_app/core/models/survey/survey.dart';
import 'package:patient_app/core/navigation/app_navigator.dart';
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:patient_app/widgets/common/async_scaffold.dart';
import 'package:provider/provider.dart';

class InstructionsPage extends StatefulWidget {
  const InstructionsPage({super.key});

  @override
  State<InstructionsPage> createState() => _InstructionsPageState();
}

class _InstructionsPageState extends State<InstructionsPage> {
  String? _comprehensionAnswer;
  bool _showError = false;

  /// Unlocks the questionnaire only when the selected answer matches the rule.
  void _startSurvey(Survey survey) {
    final correctAnswer = survey.instructions.correctAnswer;

    setState(() {
      if (_comprehensionAnswer == correctAnswer) {
        _showError = false;
        AppNavigator.replaceWithSurvey(context, survey: survey);
      } else {
        _showError = true;
      }
    });
  }

  /// Builds a selectable answer row for the comprehension check.
  Widget _buildAnswerTile(String option) {
    final theme = Theme.of(context);
    final isSelected = _comprehensionAnswer == option;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline,
      ),
      title: Text(option),
      onTap: () => setState(() {
        _comprehensionAnswer = option;
        if (_showError) _showError = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, _) {
        final survey = settings.selectedSurvey;
        final isLoading = settings.isLoadingSurveys;
        final error = settings.surveyLoadError;

        return AsyncScaffold(
          isLoading: isLoading,
          error: error != null
              ? 'Falha ao carregar questionário: $error'
              : survey == null
                  ? 'Nenhum questionário disponível. Verifique sua conexão com a internet.'
                  : null,
          appBar: AppBar(
            title: const Text('Instruções'),
            automaticallyImplyLeading: false,
          ),
          child: survey == null
              ? const SizedBox.shrink()
              : Builder(
                  builder: (context) {
                    final activeSurvey = survey;
                    final activeInstructions = activeSurvey.instructions;
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Html(
                                      data: activeInstructions.preamble,
                                      style: {
                                        'body': Style(
                                          fontSize: FontSize(16.0),
                                          lineHeight: const LineHeight(1.4),
                                        ),
                                        'p': Style(
                                          margin: Margins.only(bottom: 12.0),
                                        ),
                                        'ul': Style(
                                          margin: Margins.symmetric(vertical: 8.0),
                                          padding: HtmlPaddings.only(left: 20.0),
                                        ),
                                        'li': Style(
                                          margin: Margins.only(bottom: 4.0),
                                        ),
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      activeInstructions.questionText,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ...activeInstructions.answers
                                        .map(_buildAnswerTile),
                                    if (_showError)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16.0),
                                        child: Container(
                                          padding: const EdgeInsets.all(12.0),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .errorContainer,
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onErrorContainer,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Por favor, selecione a resposta correta para continuar.',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onErrorContainer,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _startSurvey(activeSurvey),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Iniciar Questionário',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
