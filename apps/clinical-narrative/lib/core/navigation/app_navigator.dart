import 'package:design_system_flutter/report/report_models.dart';
import 'package:flutter/material.dart';

class AppNavigator {
  static const String loginRoute = '/login';
  static const String registrationRoute = '/register';
  static const String demographicsRoute = '/demographics';
  static const String narrativeRoute = '/narrative';
  static const String chatRoute = '/chat';
  static const String thankYouRoute = '/thank-you';
  static const String reportRoute = '/report';

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

  static Future<void> toNarrative(BuildContext context) {
    return Navigator.pushNamed(context, narrativeRoute);
  }

  static Future<void> toDemographics(BuildContext context) {
    return Navigator.pushReplacementNamed(context, demographicsRoute);
  }

  static Future<void> toLogin(BuildContext context) {
    return Navigator.pushReplacementNamed(context, loginRoute);
  }

  static Future<void> toRegistration(BuildContext context) {
    return Navigator.pushReplacementNamed(context, registrationRoute);
  }

  static Future<void> toChat(BuildContext context) {
    return Navigator.pushReplacementNamed(context, chatRoute);
  }

  static Future<void> toThankYou(BuildContext context) {
    return Navigator.pushReplacementNamed(context, thankYouRoute);
  }

  static Future<void> toReport(BuildContext context, ReportDocument report) {
    return Navigator.pushNamed(context, reportRoute, arguments: report);
  }
}
