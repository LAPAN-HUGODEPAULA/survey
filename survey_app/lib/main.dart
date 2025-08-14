// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/demographics_page.dart';
import 'package:survey_app/providers/app_settings.dart';

void main() {
  runApp(
    // Envolve a aplicação com o ChangeNotifierProvider
    ChangeNotifierProvider(
      create: (context) => AppSettings(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicação de Questionário',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[50],
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const DemographicsPage(),
    );
  }
}
