// lib/main.dart

import 'package:flutter/material.dart';
import 'package:survey_app/demographics_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LAPAN Análise de Sensibilidade Visual',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[50], // Fundo um pouco cinza
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false, // Remove o banner de debug
      home: const DemographicsPage(), // A página inicial é a demográfica
    );
  }
}
