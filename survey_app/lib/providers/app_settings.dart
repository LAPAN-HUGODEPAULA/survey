// lib/providers/app_settings.dart
///
/// Provedor de configurações globais da aplicação.
///
/// Gerencia o estado das configurações do questionário, incluindo
/// o nome do responsável pela aplicação e qual questionário está ativo.
/// Utiliza o padrão Provider para notificação de mudanças de estado.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Classe que gerencia as configurações globais da aplicação de questionários.
///
/// Extends [ChangeNotifier] para permitir notificação automática de widgets
/// quando as configurações são alteradas.
///
/// Principais responsabilidades:
/// - Gerenciar nome do profissional responsável (screener)
/// - Carregar questionários disponíveis dinamicamente
/// - Controlar qual questionário está selecionado
class AppSettings extends ChangeNotifier {
  /// Nome do profissional responsável pela aplicação do questionário.
  String _screenerName = 'Profissional Padrão';

  /// Caminho do questionário atualmente selecionado.
  String? _selectedSurveyPath;

  /// Lista de caminhos dos questionários disponíveis.
  List<String> _availableSurveyPaths = [];

  /// Retorna o nome do profissional responsável.
  String get screenerName => _screenerName;

  /// Retorna o caminho do questionário selecionado.
  String? get selectedSurveyPath => _selectedSurveyPath;

  /// Retorna a lista de questionários disponíveis.
  List<String> get availableSurveyPaths => _availableSurveyPaths;

  /// Define o nome do profissional responsável.
  ///
  /// [name] - Novo nome do responsável
  ///
  /// Notifica todos os listeners sobre a mudança.
  void setScreenerName(String name) {
    _screenerName = name;
    notifyListeners();
  }

  /// Seleciona um questionário específico.
  ///
  /// [path] - Caminho do questionário a ser selecionado
  ///
  /// Notifica todos os listeners sobre a mudança.
  void selectSurvey(String? path) {
    _selectedSurveyPath = path;
    notifyListeners();
  }

  /// Carrega dinamicamente os questionários disponíveis na pasta assets/surveys/.
  ///
  /// Lê o AssetManifest.json para descobrir todos os arquivos .json
  /// na pasta de questionários. Se nenhum questionário estiver selecionado,
  /// automaticamente seleciona o primeiro da lista.
  ///
  /// Throws [Exception] se não conseguir carregar o manifest.
  Future<void> loadAvailableSurveys() async {
    // Carrega o manifest que lista todos os assets da aplicação
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    print("manifestContent: $manifestContent");

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    // Filtra apenas arquivos .json na pasta assets/surveys/
    final surveyPaths = manifestMap.keys
        .where(
          (String key) =>
              key.startsWith('assets/surveys/') && key.endsWith('.json'),
        )
        .toList();

    print("surveyPaths: $surveyPaths");
    _availableSurveyPaths = surveyPaths;

    // Auto-seleciona o primeiro questionário se nenhum estiver selecionado
    if (_selectedSurveyPath == null && _availableSurveyPaths.isNotEmpty) {
      _selectedSurveyPath = _availableSurveyPaths.first;
    }

    notifyListeners();
  }
}
