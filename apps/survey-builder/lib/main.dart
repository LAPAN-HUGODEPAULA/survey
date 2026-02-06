library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:survey_builder/features/survey/pages/survey_list_page.dart';

void main() {
  runApp(const SurveyBuilderApp());
}

class SurveyBuilderApp extends StatelessWidget {
  const SurveyBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = AppTheme.light();
    return MaterialApp(
      title: 'Survey Builder',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(fontFamily: 'NotoSans'),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      home: const SurveyListPage(),
    );
  }
}
