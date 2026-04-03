import 'package:design_system_flutter/theme/app_theme.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:survey_builder/core/models/persona_skill_draft.dart';
import 'package:survey_builder/core/repositories/persona_skill_repository.dart';
import 'package:survey_builder/features/survey/pages/persona_skill_form_page.dart';
import 'package:survey_builder/features/survey/pages/persona_skill_list_page.dart';

class _FakePersonaSkillRepository extends PersonaSkillRepository {
  _FakePersonaSkillRepository({
    List<PersonaSkillDraft>? initialSkills,
    this.throwConflictOnSave = false,
  }) : _skills = (initialSkills ?? const [])
           .map((skill) => skill.copy())
           .toList(),
       super(client: Dio(), requestPathBuilder: _noopRequestPathBuilder);

  static String _noopRequestPathBuilder(
    String path, [
    Map<String, dynamic>? queryParameters,
  ]) => path;

  final List<PersonaSkillDraft> _skills;
  final bool throwConflictOnSave;
  PersonaSkillDraft? lastCreatedDraft;
  PersonaSkillDraft? lastUpdatedDraft;
  String? lastDeletedKey;

  @override
  Future<List<PersonaSkillDraft>> listPersonaSkills() async {
    return _skills.map((skill) => skill.copy()).toList(growable: false);
  }

  @override
  Future<PersonaSkillDraft> createPersonaSkill(PersonaSkillDraft draft) async {
    if (throwConflictOnSave) {
      throw const PersonaSkillConflictException('Conflito ao salvar persona.');
    }
    lastCreatedDraft = draft.copy();
    _skills.add(draft.copy());
    return draft;
  }

  @override
  Future<PersonaSkillDraft> updatePersonaSkill(PersonaSkillDraft draft) async {
    if (throwConflictOnSave) {
      throw const PersonaSkillConflictException('Conflito ao salvar persona.');
    }
    lastUpdatedDraft = draft.copy();
    final index = _skills.indexWhere(
      (skill) => skill.personaSkillKey == draft.personaSkillKey,
    );
    if (index >= 0) {
      _skills[index] = draft.copy();
    }
    return draft;
  }

  @override
  Future<void> deletePersonaSkill(String personaSkillKey) async {
    lastDeletedKey = personaSkillKey;
    _skills.removeWhere((skill) => skill.personaSkillKey == personaSkillKey);
  }

  @override
  void dispose() {}
}

Widget _wrap(Widget child) {
  return MaterialApp(theme: AppTheme.dark(), home: child);
}

Future<void> _submitForm(WidgetTester tester) async {
  final saveButton = find.widgetWithText(DsFilledButton, 'Salvar');
  await tester.ensureVisible(saveButton);
  await tester.tap(saveButton, warnIfMissed: false);
  await tester.pumpAndSettle();
}

void main() {
  final existingSkill = PersonaSkillDraft(
    personaSkillKey: 'school_report',
    name: 'Relatório escolar',
    outputProfile: 'school_report',
    instructions: 'Use linguagem formal.',
  );

  testWidgets('persona skill form validates key format', (tester) async {
    final repository = _FakePersonaSkillRepository();

    await tester.pumpWidget(
      _wrap(PersonaSkillFormPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Key inválida!');
    await tester.enterText(find.byType(TextFormField).at(1), 'Nova persona');
    await tester.enterText(find.byType(TextFormField).at(2), 'school_report');
    await tester.enterText(find.byType(TextFormField).at(3), 'Instruções.');
    await _submitForm(tester);

    expect(find.text('Use letras, números, ":" , "_" ou "-".'), findsOneWidget);
    expect(repository.lastCreatedDraft, isNull);
  });

  testWidgets('persona skill form surfaces duplicate output profile', (
    tester,
  ) async {
    final repository = _FakePersonaSkillRepository(
      initialSkills: [existingSkill],
    );

    await tester.pumpWidget(
      _wrap(
        PersonaSkillFormPage(
          repository: repository,
          existingSkills: [existingSkill],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'new_persona');
    await tester.enterText(find.byType(TextFormField).at(1), 'Nova persona');
    await tester.enterText(find.byType(TextFormField).at(2), 'school_report');
    await tester.enterText(find.byType(TextFormField).at(3), 'Instruções.');
    await _submitForm(tester);

    expect(
      find.text('Este perfil de saída já está vinculado a outra persona.'),
      findsOneWidget,
    );
    expect(repository.lastCreatedDraft, isNull);
  });

  testWidgets('persona skill form normalizes key fields before save', (
    tester,
  ) async {
    final repository = _FakePersonaSkillRepository();

    await tester.pumpWidget(
      _wrap(PersonaSkillFormPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'School_Report');
    await tester.enterText(find.byType(TextFormField).at(1), 'Persona escolar');
    await tester.enterText(find.byType(TextFormField).at(2), 'School_Profile');
    await tester.enterText(find.byType(TextFormField).at(3), 'Instruções.');
    await _submitForm(tester);

    expect(repository.lastCreatedDraft, isNotNull);
    expect(repository.lastCreatedDraft!.personaSkillKey, 'school_report');
    expect(repository.lastCreatedDraft!.outputProfile, 'school_profile');
  });

  testWidgets('persona skill form resolves backend conflicts after refresh', (
    tester,
  ) async {
    final repository = _FakePersonaSkillRepository(
      initialSkills: [existingSkill],
      throwConflictOnSave: true,
    );

    await tester.pumpWidget(
      _wrap(
        PersonaSkillFormPage(repository: repository, existingSkills: const []),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'new_persona');
    await tester.enterText(find.byType(TextFormField).at(1), 'Nova persona');
    await tester.enterText(find.byType(TextFormField).at(2), 'school_report');
    await tester.enterText(find.byType(TextFormField).at(3), 'Instruções.');
    await _submitForm(tester);

    expect(
      find.text('Este perfil de saída já está vinculado a outra persona.'),
      findsOneWidget,
    );
  });

  testWidgets('persona skill list shows empty state without skills', (
    tester,
  ) async {
    final repository = _FakePersonaSkillRepository();

    await tester.pumpWidget(
      _wrap(PersonaSkillListPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma persona encontrada.'), findsOneWidget);
    expect(find.byType(DsAdminCatalogItem), findsNothing);
  });
}
