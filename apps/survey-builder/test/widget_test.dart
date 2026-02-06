import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:survey_builder/core/models/survey_draft.dart';
import 'package:survey_builder/core/repositories/survey_repository.dart';
import 'package:survey_builder/features/survey/pages/survey_form_page.dart';
import 'package:survey_backend_api/survey_backend_api.dart' as api;
import 'package:dio/dio.dart';

SurveyDraft _draft() {
  final now = DateTime(2024, 1, 1);
  return SurveyDraft(
    surveyDisplayName: 'Display',
    surveyName: 'Name',
    surveyDescription: 'Description',
    creatorId: 'creator',
    createdAt: now,
    modifiedAt: now,
    instructions: InstructionsDraft(preamble: 'Preamble', questionText: 'Question', answers: ['Yes']),
    questions: [
      QuestionDraft(id: 1, questionText: 'Question 1', answers: ['Answer 1']),
    ],
    finalNotes: 'Notes',
  );
}

SurveyRepository _repo() {
  return SurveyRepository(
    apiClient: api.DefaultApi(
      Dio(BaseOptions(baseUrl: 'http://localhost')),
      api.standardSerializers,
    ),
    rawClient: Dio(BaseOptions(baseUrl: 'http://localhost')),
  );
}

void main() {
  testWidgets('Survey form shows required labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: SurveyFormPage(initialDraft: _draft(), repository: _repo()),
      ),
    );

    expect(find.text('Survey Display Name *'), findsOneWidget);
    expect(find.text('Survey Name *'), findsOneWidget);
    expect(find.text('Survey Description *'), findsOneWidget);
    expect(find.text('Creator ID *'), findsOneWidget);
    expect(find.text('Final Notes *'), findsOneWidget);
    expect(find.text('Add Question'), findsOneWidget);
  });

  testWidgets('Cancel prompts when form is dirty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: SurveyFormPage(initialDraft: _draft(), repository: _repo()),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'Changed');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsOneWidget);
  });
}
