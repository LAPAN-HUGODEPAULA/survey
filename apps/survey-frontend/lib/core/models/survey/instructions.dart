/// Holds the introductory instructions and comprehension check for a survey.
///
/// The last answer in [answers] is treated as the expected comprehension
/// response during the instructions step.
class Instructions {
  /// Creates an instruction block from backend-provided content.
  Instructions({
    required this.preamble,
    required this.questionText,
    required this.answers,
  });

  /// Creates an [Instructions] object from a backend JSON payload.
  ///
  /// Expected shape:
  /// ```json
  /// {
  ///   "preamble": "<p>Introductory HTML</p>",
  ///   "questionText": "Comprehension question?",
  ///   "answers": ["Option 1", "Option 2", "Correct answer"]
  /// }
  /// ```
  factory Instructions.fromJson(Map<String, dynamic> json) => Instructions(
    preamble: json['preamble']?.toString() ?? '',
    questionText: json['questionText']?.toString() ?? '',
    answers: ((json['answers'] as List<dynamic>? ?? const <dynamic>[])
        .map((dynamic answer) => answer.toString())
        .toList(growable: false)),
  );

  /// Introductory HTML rendered before the questionnaire starts.
  final String preamble;

  /// Question used to confirm the respondent understood the instructions.
  final String questionText;

  /// Answer options for the comprehension check.
  final List<String> answers;

  /// Returns the expected answer used to unlock the survey flow.
  String get correctAnswer => answers.last;
}
