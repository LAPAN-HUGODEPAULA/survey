import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:survey_backend_api/survey_backend_api.dart' as api;
import 'package:survey_builder/core/models/persona_skill_draft.dart';
import 'package:survey_builder/core/models/survey_draft.dart';
import 'package:survey_builder/core/models/survey_prompt_draft.dart';
import 'package:survey_builder/core/repositories/persona_skill_repository.dart';
import 'package:survey_builder/core/repositories/survey_prompt_repository.dart';
import 'package:survey_builder/core/repositories/survey_repository.dart';
import 'package:survey_builder/features/survey/pages/survey_form_page.dart';

SurveyDraft _draft({
  SurveyPromptReferenceDraft? prompt,
  String? personaSkillKey,
  String? outputProfile,
}) {
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
      QuestionDraft(
        id: 1,
        questionText: 'Question 1',
        label: 'Question 1 label',
        answers: ['Answer 1'],
      ),
    ],
    finalNotes: '<p>Notes</p>',
    prompt: prompt,
    personaSkillKey: personaSkillKey,
    outputProfile: outputProfile,
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

class _FakePersonaSkillRepository extends PersonaSkillRepository {
  _FakePersonaSkillRepository(this.skills) : super(client: Dio());

  final List<PersonaSkillDraft> skills;

  @override
  Future<List<PersonaSkillDraft>> listPersonaSkills() async => skills;

  @override
  void dispose() {}
}

Widget _wrap({
  required SurveyDraft draft,
  required _FakeSurveyRepository repository,
  required _FakeSurveyPromptRepository promptRepository,
  required _FakePersonaSkillRepository personaSkillRepository,
}) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: SurveyFormPage(
      initialDraft: draft,
      repository: repository,
      promptRepository: promptRepository,
      personaSkillRepository: personaSkillRepository,
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
  final personaSkills = [
    PersonaSkillDraft(
      personaSkillKey: 'school_report',
      name: 'School Report Persona',
      outputProfile: 'school_report',
      instructions: 'Write for educators.',
    ),
    PersonaSkillDraft(
      personaSkillKey: 'clinical_diagnostic_report',
      name: 'Clinical Report Persona',
      outputProfile: 'clinical_diagnostic_report',
      instructions: 'Write clinically.',
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
        personaSkillRepository: _FakePersonaSkillRepository(personaSkills),
      ),
    );
    await tester.pumpAndSettle();

    final formScrollView = find.byType(CustomScrollView);

    await tester.dragUntilVisible(
      find.text('Nome de exibição do questionário *'),
      formScrollView,
      const Offset(0, -300),
    );
    expect(find.text('Nome de exibição do questionário *'), findsOneWidget);
    expect(find.byType(DsScaffold), findsOneWidget);
    expect(find.text('Nome do questionário *'), findsOneWidget);
    expect(find.text('Descrição do questionário *'), findsWidgets);
    expect(find.text('ID do criador *'), findsOneWidget);
    expect(find.text('Notas finais *'), findsWidgets);

    await tester.dragUntilVisible(
      find.text('Prompt de IA (opcional)'),
      formScrollView,
      const Offset(0, -300),
    );
    expect(find.text('Prompt de IA (opcional)'), findsOneWidget);
    expect(find.text('Persona padrão (opcional)'), findsOneWidget);
    expect(find.text('Perfil de saída padrão (opcional)'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Rótulo exibido no radar'),
      formScrollView,
      const Offset(0, -300),
    );
    expect(find.text('Rótulo exibido no radar'), findsOneWidget);
    expect(find.text('Adicionar pergunta'), findsOneWidget);
    expect(find.text(dsSharedStatusBarText), findsOneWidget);
  });

  testWidgets('Cancel prompts when form is dirty', (tester) async {
    await tester.pumpWidget(
      _wrap(
        draft: _draft(),
        repository: _FakeSurveyRepository(),
        promptRepository: _FakeSurveyPromptRepository(prompts),
        personaSkillRepository: _FakePersonaSkillRepository(personaSkills),
      ),
    );
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Nome de exibição do questionário *'),
      find.byType(CustomScrollView),
      const Offset(0, -300),
    );
    await tester.enterText(find.byType(TextFormField).first, 'Changed');
    await tester.dragUntilVisible(
      find.text('Cancelar'),
      find.byType(CustomScrollView),
      const Offset(0, 300),
    );
    await tester.ensureVisible(find.text('Cancelar'));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Descartar alterações?'), findsOneWidget);
    expect(find.byType(DsScaffold), findsOneWidget);
    expect(find.text(dsSharedStatusBarText), findsOneWidget);
  });

  testWidgets('Existing prompt is preloaded in the survey form', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        draft: _draft(
          prompt: SurveyPromptReferenceDraft(
            promptKey: 'prompt-1',
            name: 'Prompt One',
          ),
          personaSkillKey: 'school_report',
          outputProfile: 'school_report',
        ),
        repository: _FakeSurveyRepository(),
        promptRepository: _FakeSurveyPromptRepository(prompts),
        personaSkillRepository: _FakePersonaSkillRepository(personaSkills),
      ),
    );
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Prompt One'),
      find.byType(CustomScrollView),
      const Offset(0, -300),
    );
    expect(find.text('Prompt One'), findsOneWidget);
    expect(find.text('School Report Persona'), findsOneWidget);
    expect(find.text('school_report'), findsOneWidget);
  });

  testWidgets('Clearing an existing prompt and persona defaults saves null', (
    tester,
  ) async {
    final repository = _FakeSurveyRepository();

    await tester.pumpWidget(
      _wrap(
        draft: _draft(
          prompt: SurveyPromptReferenceDraft(
            promptKey: 'prompt-1',
            name: 'Prompt One',
          ),
          personaSkillKey: 'school_report',
          outputProfile: 'school_report',
        ),
        repository: repository,
        promptRepository: _FakeSurveyPromptRepository(prompts),
        personaSkillRepository: _FakePersonaSkillRepository(personaSkills),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Prompt').last);
    await tester.pumpAndSettle();
    final selector = find.byKey(const ValueKey('survey-prompt-selector'));
    await tester.ensureVisible(selector);
    await tester.pumpAndSettle();
    await tester.tap(selector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nenhum prompt').last, warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Persona').last);
    await tester.pumpAndSettle();
    final personaSelector = find.byKey(
      const ValueKey('survey-persona-selector'),
    );
    await tester.ensureVisible(personaSelector);
    await tester.pumpAndSettle();
    await tester.tap(personaSelector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nenhuma persona').last, warnIfMissed: false);
    await tester.pumpAndSettle();
    final saveButton = find.text('Salvar');
    await tester.dragUntilVisible(
      saveButton,
      find.byType(CustomScrollView),
      const Offset(0, 300),
    );
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(repository.lastSavedDraft, isNotNull);
    expect(repository.lastSavedDraft!.prompt, isNull);
    expect(repository.lastSavedDraft!.personaSkillKey, isNull);
    expect(repository.lastSavedDraft!.outputProfile, isNull);
  });

  testWidgets('Selecting an output profile saves the persona pair', (
    tester,
  ) async {
    final repository = _FakeSurveyRepository();

    await tester.pumpWidget(
      _wrap(
        draft: _draft(),
        repository: repository,
        promptRepository: _FakeSurveyPromptRepository(prompts),
        personaSkillRepository: _FakePersonaSkillRepository(personaSkills),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Persona').last);
    await tester.pumpAndSettle();
    final outputSelector = find.byKey(
      const ValueKey('survey-output-profile-selector'),
    );
    await tester.ensureVisible(outputSelector);
    await tester.pumpAndSettle();
    await tester.tap(outputSelector);
    await tester.pumpAndSettle();
    await tester.tap(
      find.text('clinical_diagnostic_report').last,
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    final saveButton = find.text('Salvar');
    await tester.dragUntilVisible(
      saveButton,
      find.byType(CustomScrollView),
      const Offset(0, 300),
    );
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(repository.lastSavedDraft, isNotNull);
    expect(
      repository.lastSavedDraft!.personaSkillKey,
      'clinical_diagnostic_report',
    );
    expect(
      repository.lastSavedDraft!.outputProfile,
      'clinical_diagnostic_report',
    );
  });
}
