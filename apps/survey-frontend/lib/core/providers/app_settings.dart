/// Global application settings for the screener-facing app.
///
/// This store keeps authentication, prepared access-link state, selected
/// survey metadata, and patient context synchronized across screens.
library;

import 'package:flutter/material.dart';

import 'package:survey_app/core/models/clinical_data.dart';
import 'package:survey_app/core/models/patient.dart';
import 'package:survey_app/core/models/screener_access_link.dart';
import 'package:survey_app/core/models/screener_profile.dart';
import 'package:survey_app/core/models/survey/survey.dart';
import 'package:survey_app/core/repositories/survey_repository.dart';

/// Coordinates cross-screen state for screener sessions and survey selection.
///
/// Widgets listen to this class to react to login changes, prepared access
/// links, available surveys, and patient data updates.
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
  String? _preparedAccessLinkToken;
  String? _preparedScreenerId;
  String? _preparedScreenerName;
  bool _isLoadingSurveys = false;
  String? _loadError;

  String? get authToken => _authToken;
  ScreenerProfile? get screenerProfile => _screenerProfile;
  bool get isLoggedIn =>
      (_authToken?.isNotEmpty ?? false) && _screenerProfile != null;
  bool get requiresInitialNoticeAgreement =>
      isLoggedIn && _screenerProfile?.initialNoticeAcceptedAt == null;
  bool get isLockedAssessmentMode =>
      _preparedAccessLinkToken != null &&
      _preparedScreenerId != null &&
      _selectedSurveyId != null;
  String? get accessLinkToken => _preparedAccessLinkToken;
  String get screenerId =>
      _preparedScreenerId ?? _screenerProfile?.id ?? systemScreenerId;
  String get screenerDisplayName {
    final preparedName = _preparedScreenerName;
    if (preparedName != null && preparedName.isNotEmpty) {
      return preparedName;
    }
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
    // Avoid duplicate refreshes while a survey load is already in flight.
    if (_isLoadingSurveys) return;

    _isLoadingSurveys = true;
    _loadError = null;
    notifyListeners();

    try {
      final surveys = await _surveyRepository.fetchAll();
      _surveys = surveys;
      if (_selectedSurveyId == null) {
        _selectedSurveyId = surveys.isEmpty ? null : surveys.first.id;
      } else if (!isLockedAssessmentMode &&
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
    if (isLockedAssessmentMode) {
      return;
    }
    if (id == null || id.isEmpty) {
      _selectedSurveyId = null;
    } else if (_selectedSurveyId != id) {
      _selectedSurveyId = id;
    }
    notifyListeners();
  }

  void setScreenerSession({
    required String token,
    required ScreenerProfile profile,
  }) {
    _authToken = token;
    _screenerProfile = profile;
    notifyListeners();
  }

  void clearScreenerSession() {
    _authToken = null;
    _screenerProfile = null;
    notifyListeners();
  }

  void markInitialNoticeAccepted(DateTime acceptedAt) {
    final profile = _screenerProfile;
    if (profile == null) {
      return;
    }
    _screenerProfile = profile.copyWith(initialNoticeAcceptedAt: acceptedAt);
    notifyListeners();
  }

  void applyPreparedAccessLink(ScreenerAccessLink link) {
    _preparedAccessLinkToken = link.token;
    _preparedScreenerId = link.screenerId;
    _preparedScreenerName = link.screenerName;
    _selectedSurveyId = link.surveyId;
    notifyListeners();
  }

  void clearPreparedAccessLink() {
    _preparedAccessLinkToken = null;
    _preparedScreenerId = null;
    _preparedScreenerName = null;
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
    required List<String> medication,
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
}
