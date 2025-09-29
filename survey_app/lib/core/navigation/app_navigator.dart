library;

import 'package:flutter/material.dart';
import 'package:survey_app/features/instructions/pages/instructions_page.dart';
import 'package:survey_app/features/survey/pages/survey_page.dart';
import 'package:survey_app/features/survey/pages/thank_you_page.dart';
import 'package:survey_app/core/models/survey/question.dart';

class AppNavigator {
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(context, MaterialPageRoute(builder: (_) => page));
  }

  static Future<T?> replace<T, TO extends Object?>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.pushReplacement<T, TO>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static Future<void> toInstructions(
    BuildContext context, {
    required String surveyPath,
  }) {
    return push(context, InstructionsPage(surveyPath: surveyPath));
  }

  static Future<void> replaceWithSurvey(
    BuildContext context, {
    required String surveyPath,
  }) {
    return replace(context, SurveyPage(surveyPath: surveyPath));
  }

  static Future<void> replaceWithThankYou(
    BuildContext context, {
    String? finalNotes,
    String? surveyName,
    String? surveyId,
    required List<String> surveyAnswers,
    required List<Question> surveyQuestions,
  }) {
    return replace(
      context,
      ThankYouPage(
        finalNotes: finalNotes,
        surveyName: surveyName,
        surveyId: surveyId,
        surveyAnswers: surveyAnswers,
        surveyQuestions: surveyQuestions,
      ),
    );
  }
}
