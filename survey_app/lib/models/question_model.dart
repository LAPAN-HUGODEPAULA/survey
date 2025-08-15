/// Modelo que representa uma pergunta individual do questionário.
///
/// Cada pergunta possui um ID único, texto da pergunta e uma lista
/// de possíveis respostas que o usuário pode selecionar.
///
/// Exemplo de uso:
/// ```dart
/// final question = Question(
///   id: 1,
///   questionText: "Como você se sente hoje?",
///   answers: ["Bem", "Regular", "Mal"]
/// );
/// ```
class Question {
  /// Identificador único da pergunta
  final int id;

  /// Texto da pergunta apresentada ao usuário
  final String questionText;

  /// Lista de opções de resposta disponíveis
  final List<String> answers;

  /// Cria uma nova instância de Question.
  ///
  /// [id] - Identificador único da pergunta
  /// [questionText] - Texto da pergunta
  /// [answers] - Lista de opções de resposta
  Question({
    required this.id,
    required this.questionText,
    required this.answers,
  });

  /// Cria uma Question a partir de um Map JSON.
  ///
  /// [json] - Map contendo os dados da pergunta
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "id": 1,
  ///   "questionText": "Texto da pergunta",
  ///   "answers": ["Opção 1", "Opção 2", "Opção 3"]
  /// }
  /// ```
  factory Question.fromJson(Map<String, dynamic> json) => Question(
    id: json["id"],
    questionText: json["questionText"],
    answers: List<String>.from(json["answers"].map((x) => x)),
  );
}
