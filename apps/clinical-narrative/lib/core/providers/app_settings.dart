library;

import 'package:flutter/material.dart';

import 'package:clinical_narrative_app/core/models/patient.dart';

class AppSettings extends ChangeNotifier {
  Patient _patient = Patient.initial();
  String _narrative = '';

  Patient get patient => _patient;
  String get narrative => _narrative;

  void setPatientData({
    required String name,
    required String medicalRecordId,
  }) {
    _patient = _patient.copyWith(
      name: name,
      medicalRecordId: medicalRecordId,
    );
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
}

