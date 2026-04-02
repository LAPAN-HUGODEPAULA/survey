/// Entry point for the patient-facing survey Flutter application.
///
/// This app loads runtime configuration and starts the patient workflow used
/// after a survey has been completed.
library;

import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:patient_app/core/config/runtime_config.dart';
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:patient_app/features/legal/pages/patient_entry_page.dart';
import 'package:provider/provider.dart';

/// Boots Flutter bindings, loads runtime config, and starts the app tree.
///
/// [AppSettings] keeps the patient-side survey and demographic state in sync.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RuntimeConfig.load();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppSettings(),
      child: const MyApp(),
    ),
  );
}

/// Root widget for the patient-facing survey app.
///
/// The widget configures the shared LAPAN theme and starts on [PatientEntryPage].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LAPAN Triagem do Paciente',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      locale: const Locale('pt', 'BR'),
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const PatientEntryPage(),
    );
  }
}
