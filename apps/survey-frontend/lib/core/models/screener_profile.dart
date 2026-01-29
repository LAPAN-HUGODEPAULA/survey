class ScreenerAddress {
  const ScreenerAddress({
    required this.postalCode,
    required this.street,
    required this.number,
    this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
  });

  final String postalCode;
  final String street;
  final String number;
  final String? complement;
  final String neighborhood;
  final String city;
  final String state;

  factory ScreenerAddress.fromJson(Map<String, dynamic> json) {
    return ScreenerAddress(
      postalCode: json['postalCode']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      complement: json['complement']?.toString(),
      neighborhood: json['neighborhood']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
    );
  }
}

class ScreenerProfessionalCouncil {
  const ScreenerProfessionalCouncil({
    required this.type,
    required this.registrationNumber,
  });

  final String type;
  final String registrationNumber;

  factory ScreenerProfessionalCouncil.fromJson(Map<String, dynamic> json) {
    return ScreenerProfessionalCouncil(
      type: json['type']?.toString() ?? 'none',
      registrationNumber: json['registrationNumber']?.toString() ?? '',
    );
  }
}

class ScreenerProfile {
  const ScreenerProfile({
    required this.id,
    required this.cpf,
    required this.firstName,
    required this.surname,
    required this.email,
    required this.phone,
    required this.address,
    required this.professionalCouncil,
    required this.jobTitle,
    required this.degree,
    required this.darvCourseYear,
  });

  final String id;
  final String cpf;
  final String firstName;
  final String surname;
  final String email;
  final String phone;
  final ScreenerAddress address;
  final ScreenerProfessionalCouncil professionalCouncil;
  final String jobTitle;
  final String degree;
  final int? darvCourseYear;

  factory ScreenerProfile.fromJson(Map<String, dynamic> json) {
    final addressJson = json['address'] is Map<String, dynamic>
        ? json['address'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final councilJson = json['professionalCouncil'] is Map<String, dynamic>
        ? json['professionalCouncil'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return ScreenerProfile(
      id: json['_id']?.toString() ?? '',
      cpf: json['cpf']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      surname: json['surname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: ScreenerAddress.fromJson(addressJson),
      professionalCouncil: ScreenerProfessionalCouncil.fromJson(councilJson),
      jobTitle: json['jobTitle']?.toString() ?? '',
      degree: json['degree']?.toString() ?? '',
      darvCourseYear: json['darvCourseYear'] is int
          ? json['darvCourseYear'] as int
          : int.tryParse(json['darvCourseYear']?.toString() ?? ''),
    );
  }
}
