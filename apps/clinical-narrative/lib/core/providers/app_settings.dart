import 'package:clinical_narrative_app/core/models/patient.dart';
import 'package:clinical_narrative_app/core/models/screener_profile.dart';
import 'package:clinical_narrative_app/core/services/api_config.dart';
import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  String? _authToken;
  ScreenerProfile? _screenerProfile;
  Patient _patient = Patient.initial();
  String _narrative = '';

  String? get authToken => _authToken;
  ScreenerProfile? get screenerProfile => _screenerProfile;
  bool get isLoggedIn =>
      (_authToken?.isNotEmpty ?? false) && _screenerProfile != null;
  bool get requiresInitialNoticeAgreement =>
      isLoggedIn && _screenerProfile?.initialNoticeAcceptedAt == null;
  String get screenerDisplayName =>
      _screenerProfile?.displayName.isNotEmpty == true
      ? _screenerProfile!.displayName
      : 'Profissional';
  Patient get patient => _patient;
  String get narrative => _narrative;

  void setScreenerSession({
    required String token,
    required ScreenerProfile profile,
  }) {
    _authToken = token;
    _screenerProfile = profile;
    ApiConfig.setAuthToken(token);
    notifyListeners();
  }

  void setPatientData({required String name, required String medicalRecordId}) {
    _patient = _patient.copyWith(name: name, medicalRecordId: medicalRecordId);
    notifyListeners();
  }

  void setNarrative(String narrative) {
    _narrative = narrative;
    notifyListeners();
  }

  void clearPatientData() {
    _patient = Patient.initial();
    _narrative = '';
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

  void clearScreenerSession() {
    _authToken = null;
    _screenerProfile = null;
    _patient = Patient.initial();
    _narrative = '';
    ApiConfig.clearAuthToken();
    notifyListeners();
  }
}
