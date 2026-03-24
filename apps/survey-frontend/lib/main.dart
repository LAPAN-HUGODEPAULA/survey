/// Entry point for the screener-facing survey Flutter application.
///
/// This app loads runtime configuration, wires global providers, and configures
/// the route tree used by the professional screener workflow.
library;

import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/config/runtime_config.dart';
import 'package:survey_app/core/providers/api_provider.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/features/access_links/pages/access_link_launch_page.dart';
import 'package:survey_app/features/demographics/pages/demographics_page.dart';
import 'package:survey_app/features/screener/pages/screener_login_page.dart';
import 'package:survey_app/features/screener/pages/screener_profile_page.dart';
import 'package:survey_app/features/screener/pages/screener_registration_page.dart';
import 'package:survey_app/features/settings/pages/settings_page.dart';
import 'package:survey_app/features/splash/splash_screen.dart';
import 'package:survey_app/shared/widgets/main_layout.dart';

/// Shared application router for screener flows and access-link entry points.
final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(
          path: '/demographics',
          builder: (context, state) => const DemographicsPage(),
        ),
        GoRoute(
          path: '/access/:token',
          builder: (context, state) =>
              AccessLinkLaunchPage(token: state.pathParameters['token'] ?? ''),
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
      ],
    ),
  ],
);

/// Boots Flutter bindings, loads runtime config, and starts the app tree.
///
/// [AppSettings] holds the active screener session and selected survey state.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RuntimeConfig.load();
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

/// Root widget for the screener-facing survey app.
///
/// The router keeps navigation declarative while the shared theme and locale
/// match the rest of the LAPAN Flutter clients.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LAPAN Questionários (Profissional)',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      locale: const Locale('pt', 'BR'),
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
