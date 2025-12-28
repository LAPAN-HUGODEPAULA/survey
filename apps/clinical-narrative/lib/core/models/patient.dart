class Patient {
  const Patient({
    required this.name,
    required this.medicalRecordId,
  });

  final String name;
  final String medicalRecordId;

  factory Patient.initial() {
    return const Patient(
      name: '',
      medicalRecordId: '',
    );
  }

  Patient copyWith({
    String? name,
    String? medicalRecordId,
  }) {
    return Patient(
      name: name ?? this.name,
      medicalRecordId: medicalRecordId ?? this.medicalRecordId,
    );
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      name: json['name']?.toString() ?? '',
      medicalRecordId: json['medicalRecordId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'medicalRecordId': medicalRecordId,
    };
  }
}

