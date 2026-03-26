import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:survey_backend_api/survey_backend_api.dart' as api;
import 'package:survey_builder/core/models/survey_draft.dart';
import 'package:survey_builder/core/models/survey_prompt_draft.dart';
import 'package:survey_builder/core/repositories/survey_prompt_repository.dart';
import 'package:survey_builder/core/repositories/survey_repository.dart';
import 'package:survey_builder/features/survey/pages/survey_form_page.dart';

SurveyDraft _draft({SurveyPromptReferenceDraft? prompt}) {
  final now = DateTime(2024, 1, 1);
  return SurveyDraft(
    surveyDisplayName: 'Display',
    surveyName: 'Name',
    surveyDescription: '<p>Description</p>',
    creatorId: 'creator',
    createdAt: now,
    modifiedAt: now,
    instructions: InstructionsDraft(
      preamble: '<p>Preamble</p>',
      questionText: 'Question',
      answers: ['Yes'],
    ),
    questions: [
      QuestionDraft(id: 1, questionText: 'Question 1', answers: ['Answer 1']),
    ],
    finalNotes: '<p>Notes</p>',
    prompt: prompt,
  );
}

class _FakeSurveyRepository extends SurveyRepository {
  _FakeSurveyRepository()
    : super(
        apiClient: api.DefaultApi(
          Dio(BaseOptions(baseUrl: 'http://localhost')),
          api.standardSerializers,
        ),
        rawClient: Dio(BaseOptions(baseUrl: 'http://localhost')),
      );

  SurveyDraft? lastSavedDraft;

  @override
  Future<SurveyDraft> createSurvey(SurveyDraft draft) async {
    lastSavedDraft = draft.copy();
    return draft;
  }

  @override
  Future<SurveyDraft> updateSurvey(SurveyDraft draft) async {
    lastSavedDraft = draft.copy();
    return draft;
  }

  @override
  void dispose() {}
}

class _FakeSurveyPromptRepository extends SurveyPromptRepository {
  _FakeSurveyPromptRepository(this.prompts) : super(client: Dio());

  final List<SurveyPromptDraft> prompts;

  @override
  Future<List<SurveyPromptDraft>> listPrompts() async => prompts;

  @override
  void dispose() {}
}

Widget _wrap({
  required SurveyDraft draft,
  required _FakeSurveyRepository repository,
  required _FakeSurveyPromptRepository promptRepository,
}) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: SurveyFormPage(
      initialDraft: draft,
      repository: repository,
      promptRepository: promptRepository,
    ),
  );
}

void main() {
  final prompts = [
    SurveyPromptDraft(
      promptKey: 'prompt-1',
      name: 'Prompt One',
      promptText: 'Texto 1',
    ),
    SurveyPromptDraft(
      promptKey: 'prompt-2',
      name: 'Prompt Two',
      promptText: 'Texto 2',
    ),
  ];

  testWidgets('Survey form shows required labels and single prompt selector', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        draft: _draft(),
        repository: _FakeSurveyRepository(),
        promptRepository: _FakeSurveyPromptRepository(prompts),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nome de exibição do questionário *'), findsOneWidget);
    expect(find.byType(DsScaffold), findsOneWidget);
    expect(find.text('Nome do questionário *'), findsOneWidget);
    expect(find.text('Descrição do questionário *'), findsWidgets);
    expect(find.text('ID do criador *'), findsOneWidget);
    expect(find.text('Notas finais *'), findsWidgets);
    expect(find.text('Prompt de IA (opcional)'), findsOneWidget);
    expect(find.text('Adicionar pergunta'), findsOneWidget);
    expect(find.text(dsSharedStatusBarText), findsOneWidget);
  });

  testWidgets('Cancel prompts when form is dirty', (tester) async {
    await tester.pumpWidget(
      _wrap(
        draft: _draft(),
        repository: _FakeSurveyRepository(),
        promptRepository: _FakeSurveyPromptRepository(prompts),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Changed');
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Descartar alterações?'), findsOneWidget);
    expect(find.byType(DsScaffold), findsOneWidget);
    expect(find.text(dsSharedStatusBarText), findsOneWidget);
  });

  testWidgets('Existing prompt is preloaded in the survey form', (tester) async {
    await tester.pumpWidget(
      _wrap(
        draft: _draft(
          prompt: SurveyPromptReferenceDraft(
            promptKey: 'prompt-1',
            name: 'Prompt One',
          ),
        ),
        repository: _FakeSurveyRepository(),
        promptRepository: _FakeSurveyPromptRepository(prompts),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Prompt One'), findsOneWidget);
  });

  testWidgets('Clearing an existing prompt saves null', (tester) async {
    final repository = _FakeSurveyRepository();

    await tester.pumpWidget(
      _wrap(
        draft: _draft(
          prompt: SurveyPromptReferenceDraft(
            promptKey: 'prompt-1',
            name: 'Prompt One',
          ),
        ),
        repository: repository,
        promptRepository: _FakeSurveyPromptRepository(prompts),
      ),
    );
    await tester.pumpAndSettle();

    final selector = find.byKey(const ValueKey('survey-prompt-selector'));
    await tester.ensureVisible(selector);
    await tester.tap(selector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nenhum prompt').last, warnIfMissed: false);
    await tester.pumpAndSettle();
    final saveButton = find.text('Salvar');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(repository.lastSavedDraft, isNotNull);
    expect(repository.lastSavedDraft!.prompt, isNull);
  });
}
