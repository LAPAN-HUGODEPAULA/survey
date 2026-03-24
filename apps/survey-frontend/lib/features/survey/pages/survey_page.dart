/// Screen that presents the active survey one question at a time.
///
/// It tracks the current question index, collects answers in order, and hands
/// the completed payload to the thank-you flow.
library;

import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_app/core/models/survey/survey.dart';
import 'package:survey_app/core/navigation/app_navigator.dart';

/// Renders the selected survey in a linear, button-based questionnaire flow.
class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key, required this.survey});

  final Survey survey;

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

/// Holds the transient answer list until the survey is completed.
class _SurveyPageState extends State<SurveyPage> {
  int _currentQuestionIndex = 0;

  /// Ordered answers matching the sequence of displayed questions.
  final List<String> _answers = [];

  late final Survey _survey = widget.survey;

  /// Records the selected answer and advances or completes the survey.
  void _answerQuestion(String answer) {
    _answers.add(answer);

    if (_currentQuestionIndex < _survey.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // Preserve answer order when handing the full response to the next step.
      AppNavigator.replaceWithThankYou(
        context,
        survey: _survey,
        surveyAnswers: _answers,
        surveyQuestions: _survey.questions,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _survey.questions[_currentQuestionIndex];

    return DsScaffold(
      appBar: AppBar(
        title: Text(
          '${_survey.surveyDisplayName.isNotEmpty ? _survey.surveyDisplayName : _survey.surveyName}: '
          'Pergunta ${_currentQuestionIndex + 1} de ${_survey.questions.length}',
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DsSurveyProgressIndicator(
                currentIndex: _currentQuestionIndex,
                total: _survey.questions.length,
                showLabel: true,
              ),
              Text(
                currentQuestion.questionText,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ..._buildAnswerButtons(currentQuestion.answers),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the answer buttons for the active question.
  List<Widget> _buildAnswerButtons(List<String> answers) {
    return answers.asMap().entries.map((entry) {
      final index = entry.key;
      final answer = entry.value;
      return SurveyOptionButton(
        text: answer,
        onPressed: () => _answerQuestion(answer),
        optionIndex: index,
        optionCount: answers.length,
      );
    }).toList();
  }
}
