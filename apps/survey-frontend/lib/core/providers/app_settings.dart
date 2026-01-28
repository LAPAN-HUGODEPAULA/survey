// lib/providers/app_settings.dart
///
/// Provedor de configurações globais da aplicação.
///
/// Gerencia o estado das configurações do questionário, incluindo
/// o nome do responsável pela aplicação e qual questionário está ativo.
/// Utiliza o padrão Provider para notificação de mudanças de estado.
library;

import 'package:flutter/material.dart';

import 'package:survey_app/core/models/clinical_data.dart';
import 'package:survey_app/core/models/patient.dart';
import 'package:survey_app/core/models/screener_profile.dart';
import 'package:survey_app/core/models/survey/survey.dart';
import 'package:survey_app/core/repositories/survey_repository.dart';

/// Classe que gerencia as configurações globais da aplicação de questionários.
///
/// Extends [ChangeNotifier] para permitir notificação automática de widgets
/// quando as configurações são alteradas.
///
/// Principais responsabilidades:
/// - Gerenciar a sessão do screener autenticado
/// - Gerenciar dados demográficos do paciente
/// - Carregar questionários disponíveis dinamicamente
/// - Controlar qual questionário está selecionado
class AppSettings extends ChangeNotifier {
  AppSettings({SurveyRepository? surveyRepository})
      : _surveyRepository = surveyRepository ?? SurveyRepository();

  final SurveyRepository _surveyRepository;
  static const String systemScreenerId = '000000000000000000000001';

  String? _authToken;
  ScreenerProfile? _screenerProfile;
  Patient _patient = Patient.initial();
  ClinicalData _clinicalData = ClinicalData.initial();

  List<Survey> _surveys = const [];
  String? _selectedSurveyId;
  bool _isLoadingSurveys = false;
  String? _loadError;

  String? get authToken => _authToken;
  ScreenerProfile? get screenerProfile => _screenerProfile;
  bool get isLoggedIn => (_authToken?.isNotEmpty ?? false) && _screenerProfile != null;
  String get screenerId => _screenerProfile?.id ?? systemScreenerId;
  String get screenerDisplayName {
    final profile = _screenerProfile;
    if (profile == null) return 'System Screener';
    return '${profile.firstName} ${profile.surname}'.trim();
  }
  Patient get patient => _patient;
  ClinicalData get clinicalData => _clinicalData;
  bool get isLoadingSurveys => _isLoadingSurveys;
  String? get surveyLoadError => _loadError;

  List<Survey> get availableSurveys => List.unmodifiable(_surveys);

  Survey? get selectedSurvey {
    if (_selectedSurveyId == null) return null;
    try {
      return _surveys.firstWhere((survey) => survey.id == _selectedSurveyId);
    } catch (_) {
      return null;
    }
  }

  String? get selectedSurveyId => _selectedSurveyId;

  String get selectedSurveyName {
    final survey = selectedSurvey;
    if (survey == null) {
      return 'Nenhum questionário selecionado';
    }
    return survey.surveyDisplayName.isNotEmpty
        ? survey.surveyDisplayName
        : survey.surveyName;
  }

  Future<void> loadAvailableSurveys() async {
    if (_isLoadingSurveys) return;

    _isLoadingSurveys = true;
    _loadError = null;
    notifyListeners();

    try {
      final surveys = await _surveyRepository.fetchAll();
      _surveys = surveys;
      if (_selectedSurveyId == null ||
          !_surveys.any((survey) => survey.id == _selectedSurveyId)) {
        _selectedSurveyId = surveys.isEmpty ? null : surveys.first.id;
      }
    } catch (error) {
      _loadError = error.toString();
    } finally {
      _isLoadingSurveys = false;
      notifyListeners();
    }
  }

  void selectSurvey(String? id) {
    if (id == null || id.isEmpty) {
      _selectedSurveyId = null;
    } else if (_selectedSurveyId != id) {
      _selectedSurveyId = id;
    }
    notifyListeners();
  }

  void setScreenerSession({required String token, required ScreenerProfile profile}) {
    _authToken = token;
    _screenerProfile = profile;
    notifyListeners();
  }

  void clearScreenerSession() {
    _authToken = null;
    _screenerProfile = null;
    notifyListeners();
  }

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
      medication: _normaliseMedication(medication),
      diagnoses: diagnoses,
    );
    notifyListeners();
  }

  void setClinicalData({
    String? medicalHistory,
    String? familyHistory,
    String? socialData,
    String? medicationHistory,
  }) {
    _clinicalData = _clinicalData.copyWith(
      medicalHistory: medicalHistory,
      familyHistory: familyHistory,
      socialData: socialData,
      medicationHistory: medicationHistory,
    );

    _patient = _patient.copyWith(
      medicalHistory: _clinicalData.medicalHistory,
      familyHistory: _clinicalData.familyHistory,
      socialHistory: _clinicalData.socialData,
      medicationHistory: _clinicalData.medicationHistory,
    );

    notifyListeners();
  }

  void clearPatientData() {
    _patient = Patient.initial();
    _clinicalData = ClinicalData.initial();
    notifyListeners();
  }

  @override
  void dispose() {
    _surveyRepository.dispose();
    super.dispose();
  }

  List<String> _normaliseMedication(String medication) {
    final normalised = medication.trim();
    if (normalised.isEmpty || normalised.toLowerCase() == 'não aplicável') {
      return const <String>[];
    }
    return normalised
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
  }
}
