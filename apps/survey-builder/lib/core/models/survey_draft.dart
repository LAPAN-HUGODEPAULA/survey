class SurveyDraft {
  SurveyDraft({
    this.id,
    required this.surveyDisplayName,
    required this.surveyName,
    required this.surveyDescription,
    required this.creatorId,
    required this.createdAt,
    required this.modifiedAt,
    required this.instructions,
    required this.questions,
    required this.finalNotes,
  });

  final String? id;
  String surveyDisplayName;
  String surveyName;
  String surveyDescription;
  String creatorId;
  DateTime createdAt;
  DateTime modifiedAt;
  InstructionsDraft instructions;
  List<QuestionDraft> questions;
  String finalNotes;

  SurveyDraft copy() {
    return SurveyDraft(
      id: id,
      surveyDisplayName: surveyDisplayName,
      surveyName: surveyName,
      surveyDescription: surveyDescription,
      creatorId: creatorId,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
      instructions: instructions.copy(),
      questions: questions.map((q) => q.copy()).toList(),
      finalNotes: finalNotes,
    );
  }
}

class InstructionsDraft {
  InstructionsDraft({
    required this.preamble,
    required this.questionText,
    required this.answers,
  });

  String preamble;
  String questionText;
  List<String> answers;

  InstructionsDraft copy() {
    return InstructionsDraft(
      preamble: preamble,
      questionText: questionText,
      answers: List<String>.from(answers),
    );
  }
}

class QuestionDraft {
  QuestionDraft({
    required this.id,
    required this.questionText,
    required this.answers,
  });

  int id;
  String questionText;
  List<String> answers;

  QuestionDraft copy() {
    return QuestionDraft(
      id: id,
      questionText: questionText,
      answers: List<String>.from(answers),
    );
  }
}
