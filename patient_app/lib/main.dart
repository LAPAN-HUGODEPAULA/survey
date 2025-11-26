/// Aplicação Flutter para coleta de respostas de questionários.
///
/// Esta é a aplicação principal que gerencia questionários de pesquisa,
/// incluindo coleta de dados demográficos, instruções e apresentação de perguntas.
/// A aplicação é configurada com localização em português brasileiro.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:patient_app/features/demographics/pages/demographics_page.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: Colors.amber,
              brightness: Brightness.light,
            ).copyWith(
              // Custom color mappings for consistency
              primary: Colors.amber,
              onPrimary: Colors.black,
              primaryContainer: Colors.amber.shade100,
              onPrimaryContainer: Colors.amber.shade900,
              secondary: Colors.blue.shade700,
              onSecondary: Colors.white,
              secondaryContainer: Colors.blue.shade50,
              onSecondaryContainer: Colors.blue.shade700,
              // Success colors (using green)
              tertiary: Colors.green,
              onTertiary: Colors.white,
              tertiaryContainer: Colors.green.shade50,
              onTertiaryContainer: Colors.green.shade700,
              surface: Colors.white,
              onSurface: Colors.black87,
              surfaceContainerHighest: Colors.grey[50]!,
              error: Colors.red,
              onError: Colors.white,
              errorContainer: Colors.red.shade50,
              onErrorContainer: Colors.red.shade700,
              outline: Colors.grey.shade300,
            ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        dividerTheme: DividerThemeData(
          color: Colors.grey.shade300,
          thickness: 1,
        ),
        // Custom text theme for consistency
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const DemographicsPage(),
    );
  }
}
