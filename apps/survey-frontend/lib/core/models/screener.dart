class Screener {
  const Screener({required this.name, required this.email});

  final String name;
  final String email;

  factory Screener.initial() => const Screener(name: '', email: '');

  Screener copyWith({String? name, String? email}) {
    return Screener(name: name ?? this.name, email: email ?? this.email);
  }

  factory Screener.fromJson(Map<String, dynamic> json) {
    return Screener(
      name: json['screenerName']?.toString() ?? json['screener']?.toString() ?? '',
      email: json['screenerEmail']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'screenerName': name,
      'screenerEmail': email,
    };
  }
}
