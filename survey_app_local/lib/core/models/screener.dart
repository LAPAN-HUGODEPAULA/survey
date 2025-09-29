class Screener {
  final String name;
  final String email;

  Screener({required this.name, required this.email});

  factory Screener.initial() {
    return Screener(name: '', email: '');
  }

  Screener copyWith({String? name, String? email}) {
    return Screener(name: name ?? this.name, email: email ?? this.email);
  }

  factory Screener.fromJson(Map<String, dynamic> json) {
    return Screener(name: json['screener'], email: json['screenerEmail']);
  }

  Map<String, dynamic> toJson() {
    return {'screener': name, 'screenerEmail': email};
  }
}
