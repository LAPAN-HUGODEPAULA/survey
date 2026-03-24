class Screener {
  const Screener({required this.name, required this.email});

  factory Screener.initial() => const Screener(name: '', email: '');

  factory Screener.fromJson(Map<String, dynamic> json) {
    return Screener(
      name:
          json['screenerName']?.toString() ??
          json['screener']?.toString() ??
          '',
      email: json['screenerEmail']?.toString() ?? '',
    );
  }

  final String name;
  final String email;

  Screener copyWith({String? name, String? email}) {
    return Screener(name: name ?? this.name, email: email ?? this.email);
  }

  Map<String, dynamic> toJson() {
    return {'screenerName': name, 'screenerEmail': email};
  }
}
