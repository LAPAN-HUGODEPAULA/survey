
class Clinician {
  const Clinician({
    required this.name,
    required this.registrationNumber,
    required this.email,
  });

  factory Clinician.initial() {
    return const Clinician(name: '', registrationNumber: '', email: '');
  }

  final String name;
  final String registrationNumber;
  final String email;

  Clinician copyWith({
    String? name,
    String? registrationNumber,
    String? email,
  }) {
    return Clinician(
      name: name ?? this.name,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      email: email ?? this.email,
    );
  }

  bool get isComplete => name.isNotEmpty && registrationNumber.isNotEmpty;
}
