library;

/// Modelo para dados clínicos opcionais do paciente.
///
/// Campos em pt-BR conforme solicitado:
/// - Histórico médico
/// - Histórico familiar
/// - Dados sociais
/// - Histórico de medicação
class ClinicalData {
  /// Histórico médico (texto livre, opcional)
  final String medicalHistory;

  /// Histórico familiar (texto livre, opcional)
  final String familyHistory;

  /// Dados sociais (texto livre, opcional)
  final String socialData;

  /// Histórico de medicação (texto livre, opcional)
  final String medicationHistory;

  ClinicalData({
    required this.medicalHistory,
    required this.familyHistory,
    required this.socialData,
    required this.medicationHistory,
  });

  /// Instância inicial com todos os campos vazios
  factory ClinicalData.initial() => ClinicalData(
    medicalHistory: '',
    familyHistory: '',
    socialData: '',
    medicationHistory: '',
  );

  ClinicalData copyWith({
    String? medicalHistory,
    String? familyHistory,
    String? socialData,
    String? medicationHistory,
  }) {
    return ClinicalData(
      medicalHistory: medicalHistory ?? this.medicalHistory,
      familyHistory: familyHistory ?? this.familyHistory,
      socialData: socialData ?? this.socialData,
      medicationHistory: medicationHistory ?? this.medicationHistory,
    );
  }

  factory ClinicalData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ClinicalData.initial();
    return ClinicalData(
      medicalHistory: json['medicalHistory'] ?? json['medical_history'] ?? '',
      familyHistory: json['familyHistory'] ?? json['family_history'] ?? '',
      socialData: json['socialData'] ?? json['social_history'] ?? '',
      medicationHistory:
          json['medicationHistory'] ?? json['medication_history'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clinicalData': {
        'medicalHistory': medicalHistory,
        'familyHistory': familyHistory,
        'socialData': socialData,
        'medicationHistory': medicationHistory,
      },
    };
  }
}
