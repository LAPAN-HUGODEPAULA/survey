import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:survey_builder/core/config/runtime_config.dart';
import 'package:survey_builder/features/survey/pages/survey_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RuntimeConfig.load();
  runApp(const SurveyBuilderApp());
}

class SurveyBuilderApp extends StatelessWidget {
  const SurveyBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = AppTheme.dark();
    return MaterialApp(
      title: 'LAPAN Construtor de Questionários',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(fontFamily: 'NotoSans'),
        primaryTextTheme: baseTheme.primaryTextTheme.apply(fontFamily: 'NotoSans'),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      locale: const Locale('pt', 'BR'),
      builder: (context, child) => DsEmotionalToneProvider(
        profile: DsToneProfile.admin,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const SurveyListPage(),
    );
  }
}
