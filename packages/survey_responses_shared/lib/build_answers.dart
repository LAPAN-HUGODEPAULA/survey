import 'answer.dart';

List<Answer> buildAnswers({
  required List<String> answers,
  required List<int> questionIds,
}) {
  final result = <Answer>[];
  for (var i = 0; i < answers.length; i++) {
    if (i < questionIds.length) {
      result.add(Answer(id: questionIds[i], answer: answers[i]));
    }
  }
  return result;
}

DateTime parseDate(dynamic raw) {
  if (raw == null) return DateTime.now();
  final value = raw.toString();
  if (value.isEmpty) return DateTime.now();
  try {
    final normalized = value.contains('T') ? value : value.replaceAll(' ', 'T');
    return DateTime.parse(normalized);
  } catch (_) {
    return DateTime.now();
  }
}
