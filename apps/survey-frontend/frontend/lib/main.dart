/// Aplicação Flutter para coleta de respostas de questionários.
///
/// Esta é a aplicação principal que gerencia questionários de pesquisa,
/// incluindo coleta de dados demográficos, instruções e apresentação de perguntas.
/// A aplicação é configurada com localização em português brasileiro.
library;

import 'package:flutter/material.dart';
import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/features/splash/splash_screen.dart';

/// Ponto de entrada principal da aplicação.
///
/// Inicializa a aplicação com o provider [AppSettings] para gerenciamento
/// de estado global das configurações do questionário.
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppSettings(),
      child: const MyApp(),
    ),
  );
}

/// Widget raiz da aplicação de questionários.
///
/// Configura o MaterialApp com:
/// - Localização para português brasileiro
/// - Tema personalizado com cores teal
/// - Página inicial sendo [DemographicsPage]
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicação de Questionário',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      locale: const Locale('pt', 'BR'),
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
