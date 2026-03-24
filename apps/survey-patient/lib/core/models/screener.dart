class Screener {
  const Screener({required this.id});

  factory Screener.initial() => const Screener(id: '');

  factory Screener.fromJson(Map<String, dynamic> json) {
    return Screener(
      id: json['screenerId']?.toString() ?? '',
    );
  }

  final String id;

  Screener copyWith({String? id}) {
    return Screener(id: id ?? this.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'screenerId': id,
    };
  }
}
