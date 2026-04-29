/// Global application settings for the patient-facing app.
///
/// This store keeps the patient profile, available surveys, and selected
/// survey synchronized for the report-generation flow.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:patient_app/core/models/patient.dart';
import 'package:patient_app/core/models/screener.dart';
import 'package:patient_app/core/models/survey/survey.dart';
import 'package:patient_app/core/repositories/survey_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PostNoticeNavigationTarget { welcome, survey }

/// Coordinates cross-screen state for the patient workflow.
///
/// Widgets subscribe to this class to react to available survey changes and
/// updates to the patient demographic payload.
class AppSettings extends ChangeNotifier {
  AppSettings({
    SurveyRepository? surveyRepository,
    Duration surveyLoadTimeout = const Duration(seconds: 12),
  }) : _surveyRepository = surveyRepository ?? SurveyRepository(),
       _surveyLoadTimeout = surveyLoadTimeout;

  final SurveyRepository _surveyRepository;
  final Duration _surveyLoadTimeout;
  static const String _preferredSurveyId = 'lapan_q7';
  static const String _initialNoticePreferenceKey =
      'survey_patient_initial_notice_accepted';
  static const String systemScreenerId = '000000000000000000000001';

  final Screener _screener = const Screener(id: systemScreenerId);
  Patient _patient = Patient.initial();
  bool _hasAcceptedInitialNotice = false;
  bool _isLoadingInitialNotice = false;
  bool _hasLoadedInitialNotice = false;

  List<Survey> _surveys = const [];
  String? _selectedSurveyId;
  bool _isLoadingSurveys = false;
  String? _loadError;
  PostNoticeNavigationTarget _postNoticeNavigationTarget =
      PostNoticeNavigationTarget.welcome;

  Screener get screener => _screener;
  Patient get patient => _patient;
  bool get hasAcceptedInitialNotice => _hasAcceptedInitialNotice;
  bool get isLoadingInitialNotice => _isLoadingInitialNotice;
  bool get isLoadingSurveys => _isLoadingSurveys;
  String? get surveyLoadError => _loadError;

  List<Survey> get availableSurveys => List.unmodifiable(_surveys);

  Survey? get selectedSurvey {
    if (_surveys.isEmpty) return null;
    final selectedSurveyId = _selectedSurveyId;
    if (selectedSurveyId == null || selectedSurveyId.isEmpty) {
      return _surveys.first;
    }
    try {
      return _surveys.firstWhere((survey) => survey.id == selectedSurveyId);
    } catch (_) {
      return _surveys.first;
    }
  }

  String? get selectedSurveyId => _selectedSurveyId;
  PostNoticeNavigationTarget get postNoticeNavigationTarget =>
      _postNoticeNavigationTarget;

  String get selectedSurveyName {
    final survey = selectedSurvey;
    if (survey == null) {
      return 'Nenhum questionário selecionado';
    }
    return survey.surveyDisplayName.isNotEmpty
        ? survey.surveyDisplayName
        : survey.surveyName;
  }

  Future<void> loadInitialNoticeAgreement() async {
    if (_hasLoadedInitialNotice || _isLoadingInitialNotice) {
      return;
    }

    try {
      _isLoadingInitialNotice = true;
      _notifyListenersSafely();
      final preferences = await SharedPreferences.getInstance();
      _hasAcceptedInitialNotice =
          preferences.getBool(_initialNoticePreferenceKey) ?? false;
      _hasLoadedInitialNotice = true;
    } finally {
      _isLoadingInitialNotice = false;
      _notifyListenersSafely();
    }
  }

  Future<void> acceptInitialNotice() async {
    _hasAcceptedInitialNotice = true;
    _hasLoadedInitialNotice = true;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_initialNoticePreferenceKey, true);
  }

  Future<void> clearInitialNoticeAgreement() async {
    _hasAcceptedInitialNotice = false;
    _hasLoadedInitialNotice = true;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_initialNoticePreferenceKey);
  }

  Future<void> restartAssessmentFlow() async {
    _patient = Patient.initial();
    _hasAcceptedInitialNotice = false;
    _hasLoadedInitialNotice = true;
    _postNoticeNavigationTarget = PostNoticeNavigationTarget.survey;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_initialNoticePreferenceKey);
  }

  Future<void> loadAvailableSurveys() async {
    if (_isLoadingSurveys) return;

    try {
      _isLoadingSurveys = true;
      _loadError = null;
      debugPrint('AppSettings.loadAvailableSurveys: start');
      _notifyListenersSafely();
      final surveys = await _surveyRepository.fetchAll().timeout(
        _surveyLoadTimeout,
      );
      debugPrint(
        'AppSettings.loadAvailableSurveys: fetched ${surveys.length} surveys',
      );
      _surveys = surveys;
      if (_selectedSurveyId == null ||
          !_surveys.any((survey) => survey.id == _selectedSurveyId)) {
        _selectedSurveyId = _resolveDefaultSurveyId(surveys);
      }
    } on TimeoutException {
      _loadError =
          'Tempo limite ao buscar questionários. Verifique a conexão e tente novamente.';
      debugPrint('AppSettings.loadAvailableSurveys: timeout');
    } catch (error) {
      _loadError = error.toString();
      debugPrint('AppSettings.loadAvailableSurveys: error $_loadError');
    } finally {
      _isLoadingSurveys = false;
      debugPrint(
        'AppSettings.loadAvailableSurveys: done selected=$_selectedSurveyId error=$_loadError loading=$_isLoadingSurveys total=${_surveys.length}',
      );
      _notifyListenersSafely();
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

  String? _resolveDefaultSurveyId(List<Survey> surveys) {
    if (surveys.isEmpty) return null;
    final preferred = surveys
        .where((survey) => survey.id == _preferredSurveyId)
        .map((survey) => survey.id)
        .firstWhere((_) => true, orElse: () => '');
    if (preferred.isNotEmpty) {
      return preferred;
    }
    return surveys.first.id;
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

  void clearPatientData() {
    _patient = Patient.initial();
    notifyListeners();
  }

  PostNoticeNavigationTarget consumePostNoticeNavigationTarget() {
    final target = _postNoticeNavigationTarget;
    _postNoticeNavigationTarget = PostNoticeNavigationTarget.welcome;
    return target;
  }

  @override
  void dispose() {
    _surveyRepository.dispose();
    super.dispose();
  }

  void _notifyListenersSafely() {
    try {
      notifyListeners();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'survey-patient',
          context: ErrorDescription('while notifying AppSettings listeners'),
        ),
      );
    }
  }
}
