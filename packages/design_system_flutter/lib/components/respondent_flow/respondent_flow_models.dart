class DsDemographicsCatalogs {
  const DsDemographicsCatalogs({
    required this.diagnoses,
    required this.educationLevels,
    required this.professions,
  });

  final List<String> diagnoses;
  final List<String> educationLevels;
  final List<String> professions;
}

class DsSurveyInstructionData {
  const DsSurveyInstructionData({
    required this.preambleHtml,
    required this.questionText,
    required this.answers,
    required this.correctAnswer,
  });

  final String preambleHtml;
  final String questionText;
  final List<String> answers;
  final String correctAnswer;
}

class DsSurveyQuestionData {
  const DsSurveyQuestionData({
    required this.id,
    required this.questionText,
    required this.answers,
  });

  final int id;
  final String questionText;
  final List<String> answers;
}

class DsSurveyDetailsData {
  const DsSurveyDetailsData({
    required this.id,
    required this.displayName,
    required this.surveyName,
    required this.creatorId,
    required this.createdAt,
    required this.modifiedAt,
    required this.descriptionHtml,
    required this.totalQuestions,
    required this.hasFinalNotes,
  });

  final String id;
  final String displayName;
  final String surveyName;
  final String creatorId;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String descriptionHtml;
  final int totalQuestions;
  final bool hasFinalNotes;
}
