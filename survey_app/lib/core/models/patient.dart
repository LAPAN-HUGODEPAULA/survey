class Patient {
  final String name;
  final String email;
  final String birthDate;
  final String gender;
  final String ethnicity;
  final String educationLevel;
  final String profession;
  final String medication;
  final List<String> diagnoses;

  Patient({
    required this.name,
    required this.email,
    required this.birthDate,
    required this.gender,
    required this.ethnicity,
    required this.educationLevel,
    required this.profession,
    required this.medication,
    required this.diagnoses,
  });

  factory Patient.initial() {
    return Patient(
      name: '',
      email: '',
      birthDate: '',
      gender: '',
      ethnicity: '',
      educationLevel: '',
      profession: '',
      medication: '',
      diagnoses: [],
    );
  }

  Patient copyWith({
    String? name,
    String? email,
    String? birthDate,
    String? gender,
    String? ethnicity,
    String? educationLevel,
    String? profession,
    String? medication,
    List<String>? diagnoses,
  }) {
    return Patient(
      name: name ?? this.name,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      ethnicity: ethnicity ?? this.ethnicity,
      educationLevel: educationLevel ?? this.educationLevel,
      profession: profession ?? this.profession,
      medication: medication ?? this.medication,
      diagnoses: diagnoses ?? this.diagnoses,
    );
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      name: json['patientName'],
      email: json['patientEmail'],
      birthDate: json['patientBirthDate'],
      gender: json['patientGender'],
      ethnicity: json['patientEthnicity'],
      educationLevel: json['patientEducationLevel'] ?? '',
      profession: json['patientProfession'] ?? '',
      medication: json['patientMedication'],
      diagnoses: List<String>.from(json['patientDiagnoses']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientName': name,
      'patientEmail': email,
      'patientBirthDate': birthDate,
      'patientGender': gender,
      'patientEthnicity': ethnicity,
      'patientEducationLevel': educationLevel,
      'patientProfession': profession,
      'patientMedication': medication,
      'patientDiagnoses': diagnoses,
    };
  }
}
