
/// Modelo que representa as instruções de um questionário.
///
/// Contém o preâmbulo em HTML, pergunta de compreensão e opções de resposta.
class Instructions {
  /// Preâmbulo em formato HTML explicando o questionário
  final String preamble;

  /// Texto da pergunta de compreensão
  final String questionText;

  /// Lista de opções de resposta para a pergunta de compreensão
  final List<String> answers;

  /// Cria uma nova instância de Instructions.
  ///
  /// [preamble] - Texto explicativo em HTML
  /// [questionText] - Pergunta de verificação de compreensão
  /// [answers] - Opções de resposta, sendo a última sempre a correta
  Instructions({
    required this.preamble,
    required this.questionText,
    required this.answers,
  });

  /// Cria Instructions a partir de um Map JSON.
  ///
  /// [json] - Map contendo os dados das instruções
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "preamble": "<p>Texto em HTML</p>",
  ///   "questionText": "Pergunta de compreensão?",
  ///   "answers": ["Opção 1", "Opção 2", "Resposta Correta"]
  /// }
  /// ```
  factory Instructions.fromJson(Map<String, dynamic> json) => Instructions(
    preamble: json["preamble"],
    questionText: json["questionText"],
    answers: List<String>.from(json["answers"].map((x) => x)),
  );

  /// Retorna a resposta correta (sempre a última da lista).
  String get correctAnswer => answers.last;
}
