import 'package:flutter/material.dart';
import 'package:survey_app/core/models/survey/question.dart';
import 'package:survey_app/core/models/survey/survey.dart';
import 'package:survey_app/features/clinical/pages/clinical_page.dart';
import 'package:survey_app/features/instructions/pages/instructions_page.dart';
import 'package:survey_app/features/survey/pages/survey_page.dart';
import 'package:survey_app/features/survey/pages/thank_you_page.dart';

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

  static Future<void> toInstructions(BuildContext context) {
    return push(context, const InstructionsPage());
  }

  static Future<void> toClinical(BuildContext context) {
    return push(context, const ClinicalPage());
  }

  static Future<void> toSurvey(BuildContext context, {required Survey survey}) {
    return push(context, SurveyPage(survey: survey));
  }

  static Future<void> toThankYou(
    BuildContext context, {
    required Survey survey,
    required List<String> surveyAnswers,
    required List<Question> surveyQuestions,
  }) {
    return push(
      context,
      ThankYouPage(
        survey: survey,
        surveyAnswers: surveyAnswers,
        surveyQuestions: surveyQuestions,
      ),
    );
  }

  static Future<void> replaceWithSurvey(
    BuildContext context, {
    required Survey survey,
  }) {
    return toSurvey(context, survey: survey);
  }

  static Future<void> replaceWithThankYou(
    BuildContext context, {
    required Survey survey,
    required List<String> surveyAnswers,
    required List<Question> surveyQuestions,
  }) {
    return toThankYou(
      context,
      survey: survey,
      surveyAnswers: surveyAnswers,
      surveyQuestions: surveyQuestions,
    );
  }
}
