import 'dart:async';
import 'dart:convert';

import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survey_builder/core/models/persona_skill_draft.dart';
import 'package:survey_builder/core/models/survey_draft.dart';
import 'package:survey_builder/core/models/survey_prompt_draft.dart';
import 'package:survey_builder/core/repositories/persona_skill_repository.dart';
import 'package:survey_builder/core/repositories/survey_prompt_repository.dart';
import 'package:survey_builder/core/repositories/survey_repository.dart';
import 'package:survey_builder/features/survey/controllers/authoring_form_controller.dart';
import 'package:survey_builder/features/survey/validators/survey_authoring_validators.dart';

class SurveyFormController extends AuthoringFormController {
  SurveyFormController({
    SurveyDraft? initialDraft,
    SurveyRepository? repository,
    SurveyPromptRepository? promptRepository,
    PersonaSkillRepository? personaSkillRepository,
  }) : _repo = repository ?? SurveyRepository(),
       _promptRepo = promptRepository ?? SurveyPromptRepository(),
       _personaSkillRepo = personaSkillRepository ?? PersonaSkillRepository(),
       _initialDraftId = initialDraft?.id,
       draft = initialDraft?.copy() ?? _emptyDraft() {
    questions = draft.questions.map((question) => question.copy()).toList();
    instructionAnswers = List<String>.from(draft.instructions.answers);
    if (instructionAnswers.isEmpty) {
      instructionAnswers.add('');
    }

    displayNameController = TextEditingController(text: draft.surveyDisplayName)
      ..addListener(_handleFieldMutation);
    nameController = TextEditingController(text: draft.surveyName)
      ..addListener(_handleFieldMutation);
    creatorIdController = TextEditingController(text: draft.creatorId)
      ..addListener(_handleFieldMutation);
    instructionsQuestionController = TextEditingController(
      text: draft.instructions.questionText,
    )..addListener(_handleFieldMutation);

    descriptionHtml = normalizeHtml(draft.surveyDescription);
    instructionsPreambleHtml = normalizeHtml(draft.instructions.preamble);
    finalNotesHtml = normalizeHtml(draft.finalNotes);
    selectedPromptKey = draft.prompt?.promptKey;
    selectedPersonaSkillKey = draft.personaSkillKey;
    selectedOutputProfile = draft.outputProfile;
  }

  final SurveyRepository _repo;
  final SurveyPromptRepository _promptRepo;
  final PersonaSkillRepository _personaSkillRepo;
  final String? _initialDraftId;
  Timer? _draftSaveDebounce;

  SurveyDraft draft;
  late final TextEditingController displayNameController;
  late final TextEditingController nameController;
  late final TextEditingController creatorIdController;
  late final TextEditingController instructionsQuestionController;

  String descriptionHtml = '';
  String instructionsPreambleHtml = '';
  String finalNotesHtml = '';
  List<String> instructionAnswers = <String>[];
  List<QuestionDraft> questions = <QuestionDraft>[];
  List<SurveyPromptDraft> availablePrompts = <SurveyPromptDraft>[];
  List<PersonaSkillDraft> availablePersonaSkills = <PersonaSkillDraft>[];
  String? selectedPromptKey;
  String? selectedPersonaSkillKey;
  String? selectedOutputProfile;
  bool loadingPrompts = true;
  bool loadingPersonaSkills = true;
  bool restoredLocalDraft = false;
  String? promptLoadError;
  String? personaSkillLoadError;
  DateTime? lastLocalDraftSavedAt;
  List<DsValidationSummaryItem> validationItems =
      const <DsValidationSummaryItem>[];

  bool get isEditing => draft.id != null && draft.id!.isNotEmpty;

  String get localDraftStorageKey =>
      'survey_builder:survey_form:${_initialDraftId ?? 'new'}';

  Future<void> loadCatalogs() async {
    await Future.wait([loadPrompts(), loadPersonaSkills()]);
  }

  Future<void> loadPrompts() async {
    loadingPrompts = true;
    promptLoadError = null;
    notifyListeners();
    try {
      availablePrompts = await _promptRepo.listPrompts();
    } catch (error) {
      promptLoadError = error.toString();
    } finally {
      loadingPrompts = false;
      notifyListeners();
    }
  }

  Future<void> loadPersonaSkills() async {
    loadingPersonaSkills = true;
    personaSkillLoadError = null;
    notifyListeners();
    try {
      availablePersonaSkills = await _personaSkillRepo.listPersonaSkills();
      final selectedPersona = findPersonaByKey(selectedPersonaSkillKey);
      if (selectedPersona != null) {
        selectedPersonaSkillKey = selectedPersona.personaSkillKey;
        selectedOutputProfile = selectedPersona.outputProfile;
      } else {
        final selectedByOutputProfile = findPersonaByOutputProfile(
          selectedOutputProfile,
        );
        if (selectedByOutputProfile != null) {
          selectedPersonaSkillKey = selectedByOutputProfile.personaSkillKey;
          selectedOutputProfile = selectedByOutputProfile.outputProfile;
        }
      }
    } catch (error) {
      personaSkillLoadError = error.toString();
    } finally {
      loadingPersonaSkills = false;
      notifyListeners();
    }
  }

  Future<void> restoreLocalDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getString(localDraftStorageKey);
    if (payload == null || payload.trim().isEmpty) {
      return;
    }
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) {
      return;
    }
    applyDraftSnapshot(draftFromJson(decoded));
    restoredLocalDraft = true;
    lastLocalDraftSavedAt = coerceDateTime(decoded['savedAt']);
    markDirty();
    setFeedback(
      const DsFeedbackMessage(
        severity: DsStatusType.info,
        title: 'Rascunho restaurado',
        message:
            'Encontramos um rascunho local deste questionário e restauramos suas alterações.',
      ),
    );
  }

  Future<void> clearLocalDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(localDraftStorageKey);
    lastLocalDraftSavedAt = null;
    restoredLocalDraft = false;
    notifyListeners();
  }

  void updateDescriptionHtml(String value) {
    descriptionHtml = value;
    handleMutation();
  }

  void updateInstructionsPreambleHtml(String value) {
    instructionsPreambleHtml = value;
    handleMutation();
  }

  void updateFinalNotesHtml(String value) {
    finalNotesHtml = value;
    handleMutation();
  }

  void setPromptKey(String? value) {
    selectedPromptKey = value;
    handleMutation(syncValidationSummary: false);
  }

  void syncPersonaSelection(String? personaSkillKey) {
    final normalizedKey = personaSkillKey?.trim();
    if (normalizedKey == null || normalizedKey.isEmpty) {
      selectedPersonaSkillKey = null;
      selectedOutputProfile = null;
    } else {
      final persona = findPersonaByKey(normalizedKey);
      selectedPersonaSkillKey = normalizedKey;
      selectedOutputProfile = persona?.outputProfile;
    }
    handleMutation();
  }

  void syncOutputProfileSelection(String? outputProfile) {
    final normalizedOutputProfile = outputProfile?.trim();
    if (normalizedOutputProfile == null || normalizedOutputProfile.isEmpty) {
      selectedPersonaSkillKey = null;
      selectedOutputProfile = null;
    } else {
      final persona = findPersonaByOutputProfile(normalizedOutputProfile);
      selectedPersonaSkillKey = persona?.personaSkillKey;
      selectedOutputProfile = normalizedOutputProfile;
    }
    handleMutation();
  }

  void setInstructionAnswer(int index, String value) {
    instructionAnswers[index] = value;
    handleMutation();
  }

  void addInstructionAnswer() {
    instructionAnswers.add('');
    handleMutation();
  }

  void removeInstructionAnswer(int index) {
    if (instructionAnswers.length <= 1) {
      return;
    }
    instructionAnswers.removeAt(index);
    handleMutation();
  }

  void addQuestion() {
    questions.add(
      QuestionDraft(
        id: nextQuestionId(),
        questionText: '',
        label: '',
        answers: [''],
      ),
    );
    handleMutation();
  }

  void removeQuestion(int index) {
    questions.removeAt(index);
    handleMutation();
  }

  void moveQuestion(int fromIndex, int toIndex) {
    if (toIndex < 0 || toIndex >= questions.length) {
      return;
    }
    final moved = questions.removeAt(fromIndex);
    questions.insert(toIndex, moved);
    handleMutation();
  }

  void setQuestionText(int questionIndex, String value) {
    questions[questionIndex].questionText = value;
    handleMutation();
  }

  void setQuestionLabel(int questionIndex, String value) {
    questions[questionIndex].label = value;
    handleMutation(syncValidationSummary: false);
  }

  void setQuestionAnswer(int questionIndex, int answerIndex, String value) {
    questions[questionIndex].answers[answerIndex] = value;
    handleMutation();
  }

  void addQuestionAnswer(int questionIndex) {
    questions[questionIndex].answers.add('');
    handleMutation();
  }

  void removeQuestionAnswer(int questionIndex, int answerIndex) {
    final answers = questions[questionIndex].answers;
    if (answers.length <= 1) {
      return;
    }
    answers.removeAt(answerIndex);
    handleMutation();
  }

  void handleMutation({bool syncValidationSummary = true}) {
    markDirty();
    if (syncValidationSummary) {
      syncValidationSummaryItems();
    }
  }

  void syncValidationSummaryItems() {
    if (!hasSubmitted) {
      return;
    }
    validationItems = buildValidationItems();
    notifyListeners();
  }

  void scheduleLocalDraftSave() {
    _draftSaveDebounce?.cancel();
    _draftSaveDebounce = Timer(const Duration(milliseconds: 500), () {
      unawaited(persistLocalDraft());
    });
  }

  Future<void> persistLocalDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(serializeDraftSnapshot());
    await prefs.setString(localDraftStorageKey, payload);
    lastLocalDraftSavedAt = DateTime.now();
    notifyListeners();
  }

  Map<String, dynamic> serializeDraftSnapshot() {
    return <String, dynamic>{
      'savedAt': DateTime.now().toIso8601String(),
      'draft': <String, dynamic>{
        'id': draft.id,
        'surveyDisplayName': displayNameController.text,
        'surveyName': nameController.text,
        'surveyDescription': descriptionHtml,
        'creatorId': creatorIdController.text,
        'createdAt': draft.createdAt.toIso8601String(),
        'modifiedAt': DateTime.now().toIso8601String(),
        'instructions': <String, dynamic>{
          'preamble': instructionsPreambleHtml,
          'questionText': instructionsQuestionController.text,
          'answers': instructionAnswers,
        },
        'questions': questions
            .map(
              (question) => <String, dynamic>{
                'id': question.id,
                'questionText': question.questionText,
                'label': question.label,
                'answers': question.answers,
              },
            )
            .toList(growable: false),
        'finalNotes': finalNotesHtml,
        'prompt': selectedPromptKey == null
            ? null
            : <String, dynamic>{
                'promptKey': selectedPromptKey,
                'name': availablePrompts
                    .where((prompt) => prompt.promptKey == selectedPromptKey)
                    .map((prompt) => prompt.name)
                    .firstWhere(
                      (name) => name.isNotEmpty,
                      orElse: () => '',
                    ),
              },
        'personaSkillKey': selectedPersonaSkillKey,
        'outputProfile': selectedOutputProfile,
      },
    };
  }

  SurveyDraft draftFromJson(Map<String, dynamic> source) {
    final draftPayload = coerceMap(source['draft']);
    return SurveyDraft(
      id: draftPayload['id']?.toString(),
      surveyDisplayName: draftPayload['surveyDisplayName']?.toString() ?? '',
      surveyName: draftPayload['surveyName']?.toString() ?? '',
      surveyDescription: draftPayload['surveyDescription']?.toString() ?? '',
      creatorId: draftPayload['creatorId']?.toString() ?? '',
      createdAt: coerceDateTime(draftPayload['createdAt']) ?? DateTime.now(),
      modifiedAt: coerceDateTime(draftPayload['modifiedAt']) ?? DateTime.now(),
      instructions: InstructionsDraft(
        preamble:
            coerceMap(draftPayload['instructions'])['preamble']?.toString() ??
            '',
        questionText:
            coerceMap(
              draftPayload['instructions'],
            )['questionText']?.toString() ??
            '',
        answers: coerceStringList(
          coerceMap(draftPayload['instructions'])['answers'],
        ),
      ),
      questions: coerceList(draftPayload['questions'])
          .map((entry) {
            final question = coerceMap(entry);
            return QuestionDraft(
              id: question['id'] is int
                  ? question['id'] as int
                  : int.tryParse(question['id']?.toString() ?? '') ?? 1,
              questionText: question['questionText']?.toString() ?? '',
              label: question['label']?.toString() ?? '',
              answers: coerceStringList(question['answers']),
            );
          })
          .toList(growable: true),
      finalNotes: draftPayload['finalNotes']?.toString() ?? '',
      prompt: coerceMap(draftPayload['prompt']).isEmpty
          ? null
          : SurveyPromptReferenceDraft(
              promptKey:
                  coerceMap(draftPayload['prompt'])['promptKey']?.toString() ??
                  '',
              name: coerceMap(draftPayload['prompt'])['name']?.toString() ?? '',
            ),
      personaSkillKey: draftPayload['personaSkillKey']?.toString(),
      outputProfile: draftPayload['outputProfile']?.toString(),
    );
  }

  void applyDraftSnapshot(SurveyDraft restored) {
    draft = restored;
    questions = restored.questions.map((question) => question.copy()).toList();
    instructionAnswers = List<String>.from(restored.instructions.answers);
    if (instructionAnswers.isEmpty) {
      instructionAnswers = [''];
    }
    displayNameController.text = restored.surveyDisplayName;
    nameController.text = restored.surveyName;
    creatorIdController.text = restored.creatorId;
    instructionsQuestionController.text = restored.instructions.questionText;
    descriptionHtml = normalizeHtml(restored.surveyDescription);
    instructionsPreambleHtml = normalizeHtml(restored.instructions.preamble);
    finalNotesHtml = normalizeHtml(restored.finalNotes);
    selectedPromptKey = restored.prompt?.promptKey;
    selectedPersonaSkillKey = restored.personaSkillKey;
    selectedOutputProfile = restored.outputProfile;
  }

  List<DsValidationSummaryItem> buildValidationItems({
    String? description,
    String? preamble,
    String? finalNotes,
  }) {
    final items = <DsValidationSummaryItem>[];
    void addItem(String label, String? message) {
      if (message == null || message.trim().isEmpty) {
        return;
      }
      items.add(DsValidationSummaryItem(label: label, message: message));
    }

    addItem(
      'Nome de exibição do questionário',
      SurveyAuthoringValidators.required(displayNameController.text),
    );
    addItem(
      'Nome do questionário',
      SurveyAuthoringValidators.required(nameController.text),
    );
    addItem(
      'Descrição do questionário',
      isHtmlEmpty(description ?? descriptionHtml)
          ? 'Descrição do questionário é obrigatória.'
          : null,
    );
    addItem(
      'ID do criador',
      SurveyAuthoringValidators.required(creatorIdController.text),
    );
    addItem(
      'Notas finais',
      isHtmlEmpty(finalNotes ?? finalNotesHtml)
          ? 'Notas finais são obrigatórias.'
          : null,
    );
    addItem(
      'Preâmbulo',
      isHtmlEmpty(preamble ?? instructionsPreambleHtml)
          ? 'Preâmbulo é obrigatório.'
          : null,
    );
    addItem(
      'Texto da pergunta das instruções',
      SurveyAuthoringValidators.required(instructionsQuestionController.text),
    );
    if (instructionAnswers
        .where((answer) => answer.trim().isNotEmpty)
        .isEmpty) {
      addItem(
        'Respostas das instruções',
        'Adicione pelo menos uma resposta de instrução.',
      );
    }
    _validateQuestions(items, addItem);
    if (personaSkillLoadError == null && hasStalePersonaSelection) {
      addItem(
        'Persona padrão',
        'A persona padrão salva não existe mais. Escolha outra persona ou limpe a configuração.',
      );
    }
    if (personaSkillLoadError == null && hasStaleOutputProfileSelection) {
      addItem(
        'Perfil de saída padrão',
        'O perfil de saída padrão salvo não existe mais. Escolha outro perfil ou limpe a configuração.',
      );
    }
    return items;
  }

  void _validateQuestions(
    List<DsValidationSummaryItem> items,
    void Function(String, String?) addItem,
  ) {
    if (questions.isEmpty) {
      addItem(
        'Perguntas',
        'Um questionário deve conter pelo menos uma pergunta.',
      );
    }
    for (var index = 0; index < questions.length; index += 1) {
      final question = questions[index];
      addItem(
        'Pergunta ${index + 1}',
        SurveyAuthoringValidators.required(question.questionText),
      );
      if (question.answers
          .where((answer) => answer.trim().isNotEmpty)
          .isEmpty) {
        addItem(
          'Respostas da pergunta ${index + 1}',
          'Cada pergunta deve conter pelo menos uma resposta.',
        );
      }
      for (
        var answerIndex = 0;
        answerIndex < question.answers.length;
        answerIndex += 1
      ) {
        addItem(
          'Pergunta ${index + 1} · Resposta ${answerIndex + 1}',
          SurveyAuthoringValidators.required(question.answers[answerIndex]),
        );
      }
    }
  }

  Future<bool> save({
    required FormState? formState,
    required String description,
    required String preamble,
    required String finalNotes,
  }) async {
    markSubmitted();
    final items = buildValidationItems(
      description: description,
      preamble: preamble,
      finalNotes: finalNotes,
    );
    if (formState == null || !formState.validate() || items.isNotEmpty) {
      validationItems = items;
      setFeedback(
        const DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Revise o formulário',
          message:
              'Corrija os itens destacados e o resumo acima antes de salvar.',
        ),
      );
      return false;
    }

    setSaving(true);
    try {
      draft
        ..surveyDisplayName = displayNameController.text.trim()
        ..surveyName = nameController.text.trim()
        ..surveyDescription = description.trim()
        ..creatorId = creatorIdController.text.trim()
        ..finalNotes = finalNotes.trim()
        ..modifiedAt = DateTime.now();
      draft.instructions
        ..preamble = preamble.trim()
        ..questionText = instructionsQuestionController.text.trim()
        ..answers = instructionAnswers
            .map((answer) => answer.trim())
            .where((answer) => answer.isNotEmpty)
            .toList();
      draft.questions = questions
          .map(
            (question) => QuestionDraft(
              id: question.id,
              questionText: question.questionText.trim(),
              label: question.label.trim(),
              answers: question.answers
                  .map((answer) => answer.trim())
                  .where((answer) => answer.isNotEmpty)
                  .toList(),
            ),
          )
          .toList();
      final selectedPrompt = availablePrompts.where(
        (item) => item.promptKey == selectedPromptKey,
      );
      draft.prompt = selectedPrompt.isEmpty
          ? null
          : SurveyPromptReferenceDraft(
              promptKey: selectedPrompt.first.promptKey,
              name: selectedPrompt.first.name,
            );
      if (personaSkillLoadError == null) {
        final selectedPersona =
            findPersonaByKey(selectedPersonaSkillKey) ??
            findPersonaByOutputProfile(selectedOutputProfile);
        draft
          ..personaSkillKey = selectedPersona?.personaSkillKey
          ..outputProfile = selectedPersona?.outputProfile;
      } else {
        draft
          ..personaSkillKey = selectedPersonaSkillKey
          ..outputProfile = selectedOutputProfile;
      }

      if (draft.id == null || draft.id!.isEmpty) {
        await _repo.createSurvey(draft);
      } else {
        await _repo.updateSurvey(draft);
      }
      await clearLocalDraft();
      clearDirty();
      return true;
    } catch (error) {
      setFeedback(
        DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Revise o formulário',
          message: 'Falha ao salvar: $error',
        ),
      );
      return false;
    } finally {
      setSaving(false);
    }
  }

  PersonaSkillDraft? findPersonaByKey(String? key) {
    final normalizedKey = key?.trim();
    if (normalizedKey == null || normalizedKey.isEmpty) {
      return null;
    }
    for (final persona in availablePersonaSkills) {
      if (persona.personaSkillKey == normalizedKey) {
        return persona;
      }
    }
    return null;
  }

  PersonaSkillDraft? findPersonaByOutputProfile(String? outputProfile) {
    final normalizedOutputProfile = outputProfile?.trim();
    if (normalizedOutputProfile == null || normalizedOutputProfile.isEmpty) {
      return null;
    }
    for (final persona in availablePersonaSkills) {
      if (persona.outputProfile == normalizedOutputProfile) {
        return persona;
      }
    }
    return null;
  }

  List<String> availableOutputProfiles() {
    final profiles = <String>[];
    final seenProfiles = <String>{};
    for (final persona in availablePersonaSkills) {
      if (seenProfiles.add(persona.outputProfile)) {
        profiles.add(persona.outputProfile);
      }
    }
    return profiles;
  }

  bool get hasStalePersonaSelection {
    if (selectedPersonaSkillKey == null || selectedPersonaSkillKey!.isEmpty) {
      return false;
    }
    return findPersonaByKey(selectedPersonaSkillKey) == null;
  }

  bool get hasStaleOutputProfileSelection {
    if (selectedOutputProfile == null || selectedOutputProfile!.isEmpty) {
      return false;
    }
    return findPersonaByOutputProfile(selectedOutputProfile) == null;
  }

  int nextQuestionId() {
    if (questions.isEmpty) {
      return 1;
    }
    final maxId = questions
        .map((question) => question.id)
        .reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  String formatLocalDraftTime(DateTime value) {
    final hours = value.hour.toString().padLeft(2, '0');
    final minutes = value.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  bool isHtmlEmpty(String html) {
    final stripped = html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return stripped.isEmpty;
  }

  static String normalizeHtml(String html) {
    final trimmed = html.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    if (trimmed.contains('<')) {
      return trimmed;
    }
    return '<p>${trimmed.replaceAll('\n', '<br>')}</p>';
  }

  static SurveyDraft _emptyDraft() {
    final now = DateTime.now();
    return SurveyDraft(
      surveyDisplayName: '',
      surveyName: '',
      surveyDescription: '',
      creatorId: '',
      createdAt: now,
      modifiedAt: now,
      instructions: InstructionsDraft(
        preamble: '',
        questionText: '',
        answers: [''],
      ),
      questions: [],
      finalNotes: '',
      prompt: null,
    );
  }

  Map<String, dynamic> coerceMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  List<dynamic> coerceList(dynamic value) {
    if (value is List) {
      return value;
    }
    return const <dynamic>[];
  }

  List<String> coerceStringList(dynamic value) {
    if (value is List) {
      final values = value.map((entry) => entry?.toString() ?? '').toList();
      return values.isEmpty ? [''] : values;
    }
    return [''];
  }

  DateTime? coerceDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  void _handleFieldMutation() {
    handleMutation();
  }

  @override
  void markDirty() {
    super.markDirty();
    scheduleLocalDraftSave();
  }

  @override
  void dispose() {
    _draftSaveDebounce?.cancel();
    displayNameController.dispose();
    nameController.dispose();
    creatorIdController.dispose();
    instructionsQuestionController.dispose();
    _repo.dispose();
    _promptRepo.dispose();
    _personaSkillRepo.dispose();
    super.dispose();
  }
}
