
import 'package:clinical_narrative_app/core/models/clinician.dart';
import 'package:clinical_narrative_app/core/models/patient.dart';
import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  Clinician _clinician = Clinician.initial();
  Patient _patient = Patient.initial();
  String _narrative = '';

  Clinician get clinician => _clinician;
  Patient get patient => _patient;
  String get narrative => _narrative;

  void setClinicianData({
    required String name,
    required String registrationNumber,
    String email = '',
  }) {
    _clinician = _clinician.copyWith(
      name: name,
      registrationNumber: registrationNumber,
      email: email,
    );
    notifyListeners();
  }

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

  void clearClinicianData() {
    _clinician = Clinician.initial();
    notifyListeners();
  }
}
