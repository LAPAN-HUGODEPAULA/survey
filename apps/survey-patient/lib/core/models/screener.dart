class Screener {
  const Screener({required this.id});

  final String id;

  factory Screener.initial() => const Screener(id: '');

  Screener copyWith({String? id}) {
    return Screener(id: id ?? this.id);
  }

  factory Screener.fromJson(Map<String, dynamic> json) {
    return Screener(
      id: json['screenerId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'screenerId': id,
    };
  }
}
