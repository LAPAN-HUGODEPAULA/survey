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
/// - Gerenciar dados demográficos do paciente
/// - Carregar questionários disponíveis dinamicamente
/// - Controlar qual questionário está selecionado
class AppSettings extends ChangeNotifier {
  /// Nome do profissional responsável pela aplicação do questionário.
  String _screenerName = '';

  /// Contato do profissional responsável (email, telefone, etc.).
  String _screenerContact = '';

  /// Caminho do questionário atualmente selecionado.
  String? _selectedSurveyPath;

  /// Lista de caminhos dos questionários disponíveis.
  List<String> _availableSurveyPaths = [];

  // Dados demográficos do paciente
  String _patientName = '';
  String _patientEmail = '';
  String _patientBirthDate = '';
  String _patientGender = '';
  String _patientEthnicity = '';
  String _patientMedication = '';
  List<String> _patientDiagnoses = [];

  /// Retorna o nome do profissional responsável.
  String get screenerName => _screenerName;

  /// Retorna o contato do profissional responsável.
  String get screenerContact => _screenerContact;

  /// Retorna o caminho do questionário selecionado.
  String? get selectedSurveyPath => _selectedSurveyPath;

  /// Retorna a lista de questionários disponíveis.
  List<String> get availableSurveyPaths => _availableSurveyPaths;

  // Getters para dados demográficos
  String get patientName => _patientName;
  String get patientEmail => _patientEmail;
  String get patientBirthDate => _patientBirthDate;
  String get patientGender => _patientGender;
  String get patientEthnicity => _patientEthnicity;
  String get patientMedication => _patientMedication;
  List<String> get patientDiagnoses => _patientDiagnoses;

  /// Retorna um nome formatado e legível do questionário selecionado.
  ///
  /// Extrai o nome do arquivo do caminho, remove a extensão,
  /// substitui hífens e underscores por espaços e capitaliza o resultado.
  /// Retorna uma string padrão se nenhum questionário for selecionado.
  String get selectedSurveyName {
    if (_selectedSurveyPath == null) {
      return "Nenhum questionário selecionado";
    }
    // Ex: 'assets/surveys/chyps_v_br20.json' -> 'chyps v br20'
    String name = _selectedSurveyPath!
        .split('/')
        .last
        .replaceAll('.json', '')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');

    // Capitaliza a primeira letra de cada palavra
    return name
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          // Garante que a palavra não seja vazia antes de acessar o primeiro caractere
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
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
    _screenerName = name;
    notifyListeners();
  }

  /// Define o contato do profissional responsável.
  ///
  /// [contact] - Novo contato do responsável (email, telefone, etc.)
  ///
  /// Notifica todos os listeners sobre a mudança.
  void setScreenerContact(String contact) {
    _screenerContact = contact;
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
    required String medication,
    required List<String> diagnoses,
  }) {
    _patientName = name;
    _patientEmail = email;
    _patientBirthDate = birthDate;
    _patientGender = gender;
    _patientEthnicity = ethnicity;
    _patientMedication = medication;
    _patientDiagnoses = diagnoses;
    notifyListeners();
  }

  /// Limpa todos os dados demográficos do paciente.
  ///
  /// Usado quando o usuário inicia uma nova avaliação para garantir
  /// que os campos da página demográfica sejam resetados.
  void clearPatientData() {
    _patientName = '';
    _patientEmail = '';
    _patientBirthDate = '';
    _patientGender = '';
    _patientEthnicity = '';
    _patientMedication = '';
    _patientDiagnoses = [];
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
