/// Flutter entrypoint for the clinical narrative application.
library;

import 'package:clinical_narrative_app/core/config/runtime_config.dart';
import 'package:clinical_narrative_app/core/navigation/app_navigator.dart';
import 'package:clinical_narrative_app/core/providers/app_settings.dart';
import 'package:clinical_narrative_app/core/providers/chat_provider.dart';
import 'package:clinical_narrative_app/features/chat/pages/chat_page.dart';
import 'package:clinical_narrative_app/features/clinician/pages/clinician_login_page.dart';
import 'package:clinical_narrative_app/features/clinician/pages/clinician_registration_page.dart';
import 'package:clinical_narrative_app/features/demographics/pages/demographics_page.dart';
import 'package:clinical_narrative_app/features/narrative/pages/narrative_page.dart';
import 'package:clinical_narrative_app/features/report/pages/report_page.dart';
import 'package:clinical_narrative_app/features/thankyou/pages/thankyou_page.dart';
import 'package:design_system_flutter/report/report_models.dart';
import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RuntimeConfig.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettings()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LAPAN Narrativa Clínica',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      locale: const Locale('pt', 'BR'),
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppNavigator.loginRoute:
            return MaterialPageRoute<void>(
              builder: (_) => const ClinicianLoginPage(),
            );
          case AppNavigator.registrationRoute:
            return MaterialPageRoute<void>(
              builder: (_) => const ClinicianRegistrationPage(),
            );
          case AppNavigator.demographicsRoute:
            return MaterialPageRoute<void>(
              builder: (_) => const DemographicsPage(),
            );
          case AppNavigator.chatRoute:
            return MaterialPageRoute<void>(builder: (_) => const ChatPage());
          case AppNavigator.narrativeRoute:
            return MaterialPageRoute<void>(
              builder: (_) => const NarrativePage(),
            );
          case AppNavigator.thankYouRoute:
            return MaterialPageRoute<void>(
              builder: (_) => const ThankYouPage(),
            );
          case AppNavigator.reportRoute:
            final report = settings.arguments;
            if (report is ReportDocument) {
              return MaterialPageRoute<void>(
                builder: (_) => ReportPage(report: report),
              );
            }
            return MaterialPageRoute<void>(
              builder: (_) => const _MissingReportRoutePage(),
            );
        }
        return null;
      },
      home: Consumer<AppSettings>(
        builder: (context, settings, _) {
          if (settings.isLoggedIn) {
            return const DemographicsPage();
          }
          return const ClinicianLoginPage();
        },
      ),
    );
  }
}

class _MissingReportRoutePage extends StatelessWidget {
  const _MissingReportRoutePage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Nenhum relatório foi fornecido para esta rota.'),
      ),
    );
  }
}
