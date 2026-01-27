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
import 'package:survey_app/core/providers/api_provider.dart';
import 'package:survey_app/features/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:survey_app/features/screener/pages/screener_registration_page.dart';
import 'package:survey_app/features/screener/pages/screener_login_page.dart';
import 'package:survey_app/features/screener/pages/screener_profile_page.dart';
import 'package:survey_app/features/settings/pages/settings_page.dart'; // Added import for SettingsPage
import 'package:survey_app/shared/widgets/main_layout.dart'; // Added import for MainLayout

// Define the GoRouter instance
final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const ScreenerRegistrationPage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const ScreenerLoginPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ScreenerProfilePage(),
        ),
        GoRoute(
          path: '/settings', // Added settings route
          builder: (context, state) => const SettingsPage(),
        ),
        // TODO: Add other routes as needed
      ],
    ),
  ],
);

/// Ponto de entrada principal da aplicação.
///
/// Inicializa a aplicação com o provider [AppSettings] para gerenciamento
/// de estado global das configurações do questionário.
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppSettings()),
        ChangeNotifierProvider(create: (context) => ApiProvider()),
      ],
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
    return MaterialApp.router( // Changed to MaterialApp.router
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
      routerConfig: _router, // Added routerConfig
    );
  }
}
