import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/core/models/screener.dart';
import 'package:patient_app/core/models/survey_response.dart';

void main() {
  test('SurveyResponse omits patient when null', () {
    final response = SurveyResponse(
      surveyId: 'survey-1',
      creatorName: 'Creator',
      creatorContact: 'creator@example.com',
      testDate: DateTime(2024, 1, 1),
      screener: const Screener(name: 'Tester', email: 'tester@example.com'),
      patient: null,
      answers: const [Answer(id: 1, answer: 'A')],
    );

    final json = response.toJson();

    expect(json.containsKey('patient'), isFalse);
  });
}
