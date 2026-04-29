import 'package:flutter/material.dart';
import 'package:patient_app/core/models/survey/question.dart';
import 'package:patient_app/core/models/survey/survey.dart';
import 'package:patient_app/features/demographics/pages/demographics_page.dart';
import 'package:patient_app/features/instructions/pages/instructions_page.dart';
import 'package:patient_app/features/legal/pages/patient_entry_page.dart';
import 'package:patient_app/features/report/pages/report_page.dart';
import 'package:patient_app/features/survey/pages/survey_page.dart';
import 'package:patient_app/features/survey/pages/thank_you_page.dart';
import 'package:patient_app/features/welcome/pages/welcome_page.dart';

class AppNavigator {
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: page.runtimeType.toString()),
      ),
    );
  }

  static Future<T?> replace<T, TO extends Object?>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.pushReplacement<T, TO>(
      context,
      MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: page.runtimeType.toString()),
      ),
    );
  }

  static Future<void> toInstructions(BuildContext context) {
    return push(context, const InstructionsPage());
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

  static Future<void> toDemographics(
    BuildContext context, {
    required Survey survey,
    required List<String> surveyAnswers,
    required List<Question> surveyQuestions,
  }) {
    return push(
      context,
      DemographicsPage(
        survey: survey,
        surveyAnswers: surveyAnswers,
        surveyQuestions: surveyQuestions,
      ),
    );
  }

  static Future<void> toReport(
    BuildContext context, {
    required Survey survey,
    required List<String> surveyAnswers,
    required List<Question> surveyQuestions,
    required Future<void> Function() onRestartSurvey,
  }) {
    return push(
      context,
      ReportPage(
        survey: survey,
        surveyAnswers: surveyAnswers,
        surveyQuestions: surveyQuestions,
        onRestartSurvey: onRestartSurvey,
      ),
    );
  }

  static Future<void> replaceWithSurvey(
    BuildContext context, {
    required Survey survey,
  }) {
    return replace(context, SurveyPage(survey: survey));
  }

  static Future<void> replaceWithThankYou(
    BuildContext context, {
    required Survey survey,
    required List<String> surveyAnswers,
    required List<Question> surveyQuestions,
  }) {
    return replace(
      context,
      ThankYouPage(
        survey: survey,
        surveyAnswers: surveyAnswers,
        surveyQuestions: surveyQuestions,
      ),
    );
  }

  static Future<void> replaceWithReport(
    BuildContext context, {
    required Survey survey,
    required List<String> surveyAnswers,
    required List<Question> surveyQuestions,
    required Future<void> Function() onRestartSurvey,
  }) {
    return replace(
      context,
      ReportPage(
        survey: survey,
        surveyAnswers: surveyAnswers,
        surveyQuestions: surveyQuestions,
        onRestartSurvey: onRestartSurvey,
      ),
    );
  }

  static Future<void> replaceWithWelcome(BuildContext context) {
    return replace(context, const WelcomePage());
  }

  static Future<void> replaceWithEntryGate(BuildContext context) {
    return replace(context, const PatientEntryPage());
  }
}
