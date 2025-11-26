class Patient {
  const Patient({
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

  final String name;
  final String email;
  final String birthDate;
  final String gender;
  final String ethnicity;
  final String educationLevel;
  final String profession;
  final List<String> medication;
  final List<String> diagnoses;

  factory Patient.initial() {
    return const Patient(
      name: '',
      email: '',
      birthDate: '',
      gender: '',
      ethnicity: '',
      educationLevel: '',
      profession: '',
      medication: <String>[],
      diagnoses: <String>[],
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
    List<String>? medication,
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
      name: json['name']?.toString() ?? json['patientName']?.toString() ?? '',
      email: json['email']?.toString() ?? json['patientEmail']?.toString() ?? '',
      birthDate:
          json['birthDate']?.toString() ?? json['patientBirthDate']?.toString() ?? '',
      gender: json['gender']?.toString() ?? json['patientGender']?.toString() ?? '',
      ethnicity:
          json['ethnicity']?.toString() ?? json['patientEthnicity']?.toString() ?? '',
      educationLevel: json['educationLevel']?.toString() ??
          json['patientEducationLevel']?.toString() ??
          '',
      profession:
          json['profession']?.toString() ?? json['patientProfession']?.toString() ?? '',
      medication: _parseStringList(json['medication']) ??
          _parseStringList(json['patientMedication']) ??
          const <String>[],
      diagnoses: _parseStringList(json['diagnoses']) ??
          _parseStringList(json['patientDiagnoses']) ??
          const <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'birthDate': birthDate,
      'gender': gender,
      'ethnicity': ethnicity,
      'educationLevel': educationLevel,
      'profession': profession,
      'medication': medication,
      'diagnoses': diagnoses,
    };
  }

  static List<String>? _parseStringList(dynamic raw) {
    if (raw == null) return null;
    if (raw is List) {
      return raw.map((item) => item.toString()).toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.split(',').map((value) => value.trim()).where((value) => value.isNotEmpty).toList();
    }
    return null;
  }
}
