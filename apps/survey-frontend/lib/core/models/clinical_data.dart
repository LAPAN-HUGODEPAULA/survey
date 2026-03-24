/// Stores optional clinical notes collected alongside patient demographics.
///
/// The model keeps the text payload separate from the main patient fields so
/// optional notes can be added without complicating the demographic form.
class ClinicalData {
  ClinicalData({
    required this.medicalHistory,
    required this.familyHistory,
    required this.socialData,
    required this.medicationHistory,
  });

  /// Returns an empty instance used to reset or initialize app state.
  factory ClinicalData.initial() => ClinicalData(
    medicalHistory: '',
    familyHistory: '',
    socialData: '',
    medicationHistory: '',
  );

  factory ClinicalData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ClinicalData.initial();
    return ClinicalData(
      medicalHistory: _readString(
        json,
        camelKey: 'medicalHistory',
        snakeKey: 'medical_history',
      ),
      familyHistory: _readString(
        json,
        camelKey: 'familyHistory',
        snakeKey: 'family_history',
      ),
      socialData: _readString(
        json,
        camelKey: 'socialData',
        snakeKey: 'social_history',
      ),
      medicationHistory: _readString(
        json,
        camelKey: 'medicationHistory',
        snakeKey: 'medication_history',
      ),
    );
  }

  /// Free-text medical history entered by the screener.
  final String medicalHistory;

  /// Free-text family history entered by the screener.
  final String familyHistory;

  /// Free-text social context entered by the screener.
  final String socialData;

  /// Free-text medication history entered by the screener.
  final String medicationHistory;

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

  static String _readString(
    Map<String, dynamic> json, {
    required String camelKey,
    required String snakeKey,
  }) {
    final value = json[camelKey] ?? json[snakeKey];
    return value?.toString() ?? '';
  }
}
