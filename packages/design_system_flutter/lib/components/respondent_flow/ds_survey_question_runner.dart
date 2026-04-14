import 'package:design_system_flutter/components/respondent_flow/respondent_flow_models.dart';
import 'package:flutter/material.dart';
import 'package:design_system_flutter/widgets/ds_scaffold.dart';
import 'package:design_system_flutter/widgets/ds_surface.dart';
import 'package:design_system_flutter/widgets/survey_option_button.dart';
import 'package:design_system_flutter/widgets/survey_progress_indicator.dart';

class DsSurveyQuestionRunner extends StatefulWidget {
  const DsSurveyQuestionRunner({
    super.key,
    required this.surveyTitle,
    required this.questions,
    required this.onCompleted,
  });

  final String surveyTitle;
  final List<DsSurveyQuestionData> questions;
  final ValueChanged<List<String>> onCompleted;

  @override
  State<DsSurveyQuestionRunner> createState() => _DsSurveyQuestionRunnerState();
}

class _DsSurveyQuestionRunnerState extends State<DsSurveyQuestionRunner> {
  int _currentQuestionIndex = 0;
  late final List<String> _answers = List<String>.filled(
    widget.questions.length,
    '',
  );

  void _answerQuestion(String answer) {
    _answers[_currentQuestionIndex] = answer;

    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() => _currentQuestionIndex++);
      return;
    }

    widget.onCompleted(List<String>.unmodifiable(_answers));
  }

  void _goBack() {
    if (_currentQuestionIndex == 0) {
      return;
    }
    setState(() => _currentQuestionIndex -= 1);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const DsEmpty(message: 'Nenhuma pergunta disponível.');
    }

    final currentQuestion = widget.questions[_currentQuestionIndex];
    final currentAnswer = _answers[_currentQuestionIndex];
    return DsSection(
      eyebrow:
          'Pergunta ${_currentQuestionIndex + 1} de ${widget.questions.length}',
      title: currentQuestion.questionText,
      subtitle: currentAnswer.trim().isEmpty
          ? null
          : 'Resposta atual: $currentAnswer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DsSurveyProgressIndicator(
            currentIndex: _currentQuestionIndex,
            total: widget.questions.length,
            padding: const EdgeInsets.only(bottom: 20),
          ),
          ...currentQuestion.answers.asMap().entries.map((entry) {
            return SurveyOptionButton(
              text: entry.value,
              onPressed: () => _answerQuestion(entry.value),
              optionIndex: entry.key,
              optionCount: currentQuestion.answers.length,
              selected: currentAnswer == entry.value,
            );
          }),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _currentQuestionIndex == 0 ? null : _goBack,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Voltar para a pergunta anterior'),
            ),
          ),
        ],
      ),
    );
  }
}
