// lib/providers/app_settings.dart
///
/// Provedor de configurações globais da aplicação.
///
/// Gerencia o estado das configurações do questionário, incluindo
/// o nome do responsável pela aplicação e qual questionário está ativo.
/// Utiliza o padrão Provider para notificação de mudanças de estado.
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:survey_app/core/utils/formatters.dart';
import 'package:survey_app/core/models/patient.dart';
import 'package:survey_app/core/models/screener.dart';

/// Classe que gerencia as configurações globais da aplicação de questionários.
///
/// Extends [ChangeNotifier] para permitir notificação automática de widgets
/// quando as configurações são alteradas.
///
/// Principais responsabilidades:
/// - Gerenciar nome do profissional responsável (screener)
/// - Gerenciar dados demográficos do paciente
/// - Carregar questionários disponíveis dinamicamente
/// - Controlar qual questionário está selecionado
class AppSettings extends ChangeNotifier {
  /// Nome do profissional responsável pela aplicação do questionário.
  Screener _screener = Screener.initial();

  /// Caminho do questionário atualmente selecionado.
  String? _selectedSurveyPath;

  /// Lista de caminhos dos questionários disponíveis.
  List<String> _availableSurveyPaths = [];

  // Dados demográficos do paciente
  Patient _patient = Patient.initial();

  /// Retorna o nome do profissional responsável.
  Screener get screener => _screener;

  /// Retorna o caminho do questionário selecionado.
  String? get selectedSurveyPath => _selectedSurveyPath;

  /// Retorna a lista de questionários disponíveis.
  List<String> get availableSurveyPaths => _availableSurveyPaths;

  // Getters para dados demográficos
  Patient get patient => _patient;

  /// Retorna um nome formatado e legível do questionário selecionado.
  ///
  /// Extrai o nome do arquivo do caminho, remove a extensão,
  /// substitui hífens e underscores por espaços e capitaliza o resultado.
  /// Retorna uma string padrão se nenhum questionário for selecionado.
  String get selectedSurveyName {
    if (_selectedSurveyPath == null) {
      return "Nenhum questionário selecionado";
    }
    return Formatters.prettifySurveyName(_selectedSurveyPath!);
  }

  /// Retorna o surveyId extraído do caminho do questionário selecionado.
  String? get selectedSurveyId {
    if (_selectedSurveyPath == null) return null;
    return _selectedSurveyPath!.split('/').last.replaceAll('.json', '');
  }

  /// Define o nome do profissional responsável.
  ///
  /// [name] - Novo nome do responsável
  ///
  /// Notifica todos os listeners sobre a mudança.
  void setScreenerName(String name) {
    _screener = _screener.copyWith(name: name);
    notifyListeners();
  }

  /// Define o contato do profissional responsável.
  ///
  /// [contact] - Novo contato do responsável (email, telefone, etc.)
  ///
  /// Notifica todos os listeners sobre a mudança.
  void setScreenerContact(String contact) {
    _screener = _screener.copyWith(email: contact);
    notifyListeners();
  }

  /// Define os dados demográficos do paciente.
  ///
  /// Usado para armazenar todas as informações coletadas na página demográfica.
  void setPatientData({
    required String name,
    required String email,
    required String birthDate,
    required String gender,
    required String ethnicity,
    required String educationLevel,
    required String profession,
    required String medication,
    required List<String> diagnoses,
  }) {
    _patient = _patient.copyWith(
      name: name,
      email: email,
      birthDate: birthDate,
      gender: gender,
      ethnicity: ethnicity,
      educationLevel: educationLevel,
      profession: profession,
      medication: medication,
      diagnoses: diagnoses,
    );
    notifyListeners();
  }

  /// Limpa todos os dados demográficos do paciente.
  ///
  /// Usado quando o usuário inicia uma nova avaliação para garantir
  /// que os campos da página demográfica sejam resetados.
  void clearPatientData() {
    _patient = Patient.initial();
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

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    // Filtra apenas arquivos .json na pasta assets/surveys/
    final surveyPaths = manifestMap.keys
        .where(
          (String key) =>
              key.startsWith('assets/surveys/') && key.endsWith('.json'),
        )
        .toList();

    _availableSurveyPaths = surveyPaths;

    // Auto-seleciona o primeiro questionário se nenhum estiver selecionado
    if (_selectedSurveyPath == null && _availableSurveyPaths.isNotEmpty) {
      _selectedSurveyPath = _availableSurveyPaths.first;
    }

    notifyListeners();
  }
}
