// lib/providers/app_settings.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppSettings extends ChangeNotifier {
  String _screenerName = 'Profissional Padrão';
  String? _selectedSurveyPath;
  List<String> _availableSurveyPaths = [];

  // Getters para acessar os dados de fora
  String get screenerName => _screenerName;
  String? get selectedSurveyPath => _selectedSurveyPath;
  List<String> get availableSurveyPaths => _availableSurveyPaths;

  // Método para alterar o nome do Screener
  void setScreenerName(String name) {
    _screenerName = name;
    notifyListeners(); // Notifica os widgets que estão ouvindo sobre a mudança
  }

  // Método para selecionar um questionário
  void selectSurvey(String? path) {
    _selectedSurveyPath = path;
    notifyListeners();
  }

  // Método para carregar dinamicamente os questionários da pasta assets/surveys
  Future<void> loadAvailableSurveys() async {
    // Carrega o manifest, que lista todos os assets da aplicação
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    print("manifestContent: $manifestContent");

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    // Filtra a lista para pegar apenas os arquivos .json dentro de assets/surveys/
    final surveyPaths = manifestMap.keys
        .where(
          (String key) =>
              key.startsWith('assets/surveys/') && key.endsWith('.json'),
        )
        .toList();

    print("surveyPaths: $surveyPaths");
    _availableSurveyPaths = surveyPaths;

    // Se nenhum questionário estiver selecionado, seleciona o primeiro da lista
    if (_selectedSurveyPath == null && _availableSurveyPaths.isNotEmpty) {
      _selectedSurveyPath = _availableSurveyPaths.first;
    }

    notifyListeners();
  }
}
