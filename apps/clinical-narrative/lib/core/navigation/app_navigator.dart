library;

import 'package:clinical_narrative_app/features/narrative/pages/narrative_page.dart';
import 'package:clinical_narrative_app/features/report/pages/report_page.dart';
import 'package:clinical_narrative_app/features/thankyou/pages/thankyou_page.dart';
import 'package:design_system_flutter/report/report_models.dart';
import 'package:flutter/material.dart';

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

  static Future<void> toNarrative(BuildContext context) {
    return push(context, const NarrativePage());
  }

  static Future<void> toThankYou(BuildContext context) {
    return replace(context, const ThankYouPage());
  }

  static Future<void> toReport(BuildContext context, ReportDocument report) {
    return push(context, ReportPage(report: report));
  }
}
