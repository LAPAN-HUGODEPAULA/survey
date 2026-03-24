/// Represents a single survey question and its selectable answers.
///
/// The backend sends the question text together with the ordered answer
/// options that should be shown to the respondent.
///
/// Example:
/// ```dart
/// final question = Question(
///   id: 1,
///   questionText: 'How do you feel today?',
///   answers: ['Good', 'Neutral', 'Bad'],
/// );
/// ```
class Question {
  /// Creates a question from API-provided identifiers, text, and answers.
  Question({
    required this.id,
    required this.questionText,
    required this.answers,
  });

  /// Creates a [Question] from a JSON payload returned by the backend.
  ///
  /// Expected shape:
  /// ```json
  /// {
  ///   "id": 1,
  ///   "questionText": "Question text",
  ///   "answers": ["Option 1", "Option 2", "Option 3"]
  /// }
  /// ```
  factory Question.fromJson(Map<String, dynamic> json) => Question(
    id: (json['id'] as num?)?.toInt() ?? 0,
    questionText: json['questionText']?.toString() ?? '',
    answers: ((json['answers'] as List<dynamic>? ?? const <dynamic>[])
        .map((dynamic answer) => answer.toString())
        .toList(growable: false)),
  );

  /// Backend identifier used to keep answers in question order.
  final int id;

  /// Prompt displayed to the respondent.
  final String questionText;

  /// Ordered answer options shown as survey buttons.
  final List<String> answers;
}
