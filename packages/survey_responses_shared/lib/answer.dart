class Answer {
  const Answer({required this.id, required this.answer});

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      answer: json['answer']?.toString() ?? '',
    );
  }

  final int id;
  final String answer;

  Map<String, dynamic> toJson() => {'id': id, 'answer': answer};
}
