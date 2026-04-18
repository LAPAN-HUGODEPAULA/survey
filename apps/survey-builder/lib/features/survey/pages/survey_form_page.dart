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
import 'package:survey_builder/features/survey/pages/task_dashboard_page.dart';
import 'package:survey_builder/features/survey/widgets/html_rich_text_editor.dart';

class SurveyFormPage extends StatefulWidget {
  const SurveyFormPage({
    super.key,
    this.initialDraft,
    this.repository,
    this.promptRepository,
    this.personaSkillRepository,
  });

  final SurveyDraft? initialDraft;
  final SurveyRepository? repository;
  final SurveyPromptRepository? promptRepository;
  final PersonaSkillRepository? personaSkillRepository;

  @override
  State<SurveyFormPage> createState() => _SurveyFormPageState();
}

class _SurveyFormPageState extends State<SurveyFormPage> {
  static const String _detailsSectionId = 'details';
  static const String _instructionsSectionId = 'instructions';
  static const String _promptSectionId = 'prompt';
  static const String _personaSectionId = 'persona';
  static const String _questionsSectionId = 'questions';

  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _detailsSectionKey = GlobalKey();
  final GlobalKey _instructionsSectionKey = GlobalKey();
  final GlobalKey _promptSectionKey = GlobalKey();
  final GlobalKey _personaSectionKey = GlobalKey();
  final GlobalKey _questionsSectionKey = GlobalKey();
  late final SurveyRepository _repo;
  late final SurveyPromptRepository _promptRepo;
  late final PersonaSkillRepository _personaSkillRepo;

  late SurveyDraft _draft;
  bool _saving = false;
  bool _isDirty = false;
  bool _loadingPrompts = true;
  bool _loadingPersonaSkills = true;
  bool _hasSubmitted = false;
  bool _restoredLocalDraft = false;
  String? _promptLoadError;
  String? _personaSkillLoadError;
  DateTime? _lastLocalDraftSavedAt;
  Timer? _draftSaveDebounce;
  DsFeedbackMessage? _feedback;
  List<DsValidationSummaryItem> _validationItems =
      const <DsValidationSummaryItem>[];

  late TextEditingController _displayNameController;
  late TextEditingController _nameController;
  late TextEditingController _creatorIdController;
  late TextEditingController _instructionsQuestionController;
  final _descriptionEditorKey = GlobalKey<HtmlRichTextEditorState>();
  final _instructionsPreambleEditorKey = GlobalKey<HtmlRichTextEditorState>();
  final _finalNotesEditorKey = GlobalKey<HtmlRichTextEditorState>();

  String _descriptionHtml = '';
  String _instructionsPreambleHtml = '';
  String _finalNotesHtml = '';

  List<String> _instructionAnswers = [];
  List<QuestionDraft> _questions = [];
  List<SurveyPromptDraft> _availablePrompts = [];
  List<PersonaSkillDraft> _availablePersonaSkills = [];
  String? _selectedPromptKey;
  String? _selectedPersonaSkillKey;
  String? _selectedOutputProfile;
  String _currentSectionId = _detailsSectionId;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? SurveyRepository();
    _promptRepo = widget.promptRepository ?? SurveyPromptRepository();
    _personaSkillRepo =
        widget.personaSkillRepository ?? PersonaSkillRepository();
    _draft = widget.initialDraft?.copy() ?? _emptyDraft();
    _questions = _draft.questions.map((q) => q.copy()).toList();
    _instructionAnswers = List<String>.from(_draft.instructions.answers);
    if (_instructionAnswers.isEmpty) {
      _instructionAnswers.add('');
    }

    _displayNameController = TextEditingController(
      text: _draft.surveyDisplayName,
    );
    _nameController = TextEditingController(text: _draft.surveyName);
    _creatorIdController = TextEditingController(text: _draft.creatorId);
    _instructionsQuestionController = TextEditingController(
      text: _draft.instructions.questionText,
    );
    _descriptionHtml = _normalizeHtml(_draft.surveyDescription);
    _instructionsPreambleHtml = _normalizeHtml(_draft.instructions.preamble);
    _finalNotesHtml = _normalizeHtml(_draft.finalNotes);
    _selectedPromptKey = _draft.prompt?.promptKey;
    _selectedPersonaSkillKey = _draft.personaSkillKey;
    _selectedOutputProfile = _draft.outputProfile;

    for (final controller in [
      _displayNameController,
      _nameController,
      _creatorIdController,
      _instructionsQuestionController,
    ]) {
      controller.addListener(_handleFieldMutation);
    }
    _scrollController.addListener(_handleSectionScroll);
    _loadPrompts();
    _loadPersonaSkills();
    unawaited(_restoreLocalDraft());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _handleSectionScroll();
      }
    });
  }

  @override
  void dispose() {
    _draftSaveDebounce?.cancel();
    for (final controller in [
      _displayNameController,
      _nameController,
      _creatorIdController,
      _instructionsQuestionController,
    ]) {
      controller.removeListener(_handleFieldMutation);
    }
    _displayNameController.dispose();
    _nameController.dispose();
    _creatorIdController.dispose();
    _instructionsQuestionController.dispose();
    _scrollController
      ..removeListener(_handleSectionScroll)
      ..dispose();
    _repo.dispose();
    _promptRepo.dispose();
    _personaSkillRepo.dispose();
    super.dispose();
  }

  SurveyDraft _emptyDraft() {
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

  Future<void> _loadPrompts() async {
    setState(() {
      _loadingPrompts = true;
      _promptLoadError = null;
    });
    try {
      final prompts = await _promptRepo.listPrompts();
      if (!mounted) {
        return;
      }
      setState(() {
        _availablePrompts = prompts;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _promptLoadError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loadingPrompts = false);
      }
    }
  }

  Future<void> _loadPersonaSkills() async {
    setState(() {
      _loadingPersonaSkills = true;
      _personaSkillLoadError = null;
    });
    try {
      final skills = await _personaSkillRepo.listPersonaSkills();
      if (!mounted) {
        return;
      }
      setState(() {
        _availablePersonaSkills = skills;
        final selectedPersona = _findPersonaByKey(
          _selectedPersonaSkillKey,
          skills,
        );
        if (selectedPersona != null) {
          _selectedPersonaSkillKey = selectedPersona.personaSkillKey;
          _selectedOutputProfile = selectedPersona.outputProfile;
          return;
        }
        final selectedByOutputProfile = _findPersonaByOutputProfile(
          _selectedOutputProfile,
          skills,
        );
        if (selectedByOutputProfile != null) {
          _selectedPersonaSkillKey = selectedByOutputProfile.personaSkillKey;
          _selectedOutputProfile = selectedByOutputProfile.outputProfile;
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _personaSkillLoadError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loadingPersonaSkills = false);
      }
    }
  }

  String get _localDraftStorageKey =>
      'survey_builder:survey_form:${widget.initialDraft?.id ?? 'new'}';

  void _handleFieldMutation() {
    _markDirty();
    _syncValidationSummary();
  }

  void _markDirty() {
    if (!_isDirty) {
      setState(() => _isDirty = true);
    }
    _scheduleLocalDraftSave();
  }

  void _updateDirtyState({bool syncValidationSummary = true}) {
    _markDirty();
    if (syncValidationSummary) {
      _syncValidationSummary();
    }
  }

  void _syncValidationSummary() {
    if (!_hasSubmitted || !mounted) {
      return;
    }
    setState(() {
      _validationItems = _buildValidationItems();
    });
  }

  void _scheduleLocalDraftSave() {
    _draftSaveDebounce?.cancel();
    _draftSaveDebounce = Timer(const Duration(milliseconds: 500), () {
      unawaited(_persistLocalDraft());
    });
  }

  Future<void> _persistLocalDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(_serializeDraftSnapshot());
    await prefs.setString(_localDraftStorageKey, payload);
    if (!mounted) {
      return;
    }
    setState(() {
      _lastLocalDraftSavedAt = DateTime.now();
    });
  }

  Future<void> _restoreLocalDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getString(_localDraftStorageKey);
    if (payload == null || payload.trim().isEmpty) {
      return;
    }

    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) {
      return;
    }

    final restored = _draftFromJson(decoded);
    if (!mounted) {
      return;
    }

    setState(() {
      _applyDraftSnapshot(restored);
      _restoredLocalDraft = true;
      _isDirty = true;
      _lastLocalDraftSavedAt = _coerceDateTime(decoded['savedAt']);
      _feedback = const DsFeedbackMessage(
        severity: DsStatusType.info,
        title: 'Rascunho restaurado',
        message:
            'Encontramos um rascunho local deste questionário e restauramos suas alterações.',
      );
    });
  }

  Future<void> _clearLocalDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localDraftStorageKey);
    if (!mounted) {
      return;
    }
    setState(() {
      _lastLocalDraftSavedAt = null;
      _restoredLocalDraft = false;
    });
  }

  Map<String, dynamic> _serializeDraftSnapshot() {
    return <String, dynamic>{
      'savedAt': DateTime.now().toIso8601String(),
      'draft': <String, dynamic>{
        'id': _draft.id,
        'surveyDisplayName': _displayNameController.text,
        'surveyName': _nameController.text,
        'surveyDescription': _descriptionHtml,
        'creatorId': _creatorIdController.text,
        'createdAt': _draft.createdAt.toIso8601String(),
        'modifiedAt': DateTime.now().toIso8601String(),
        'instructions': <String, dynamic>{
          'preamble': _instructionsPreambleHtml,
          'questionText': _instructionsQuestionController.text,
          'answers': _instructionAnswers,
        },
        'questions': _questions
            .map(
              (question) => <String, dynamic>{
                'id': question.id,
                'questionText': question.questionText,
                'label': question.label,
                'answers': question.answers,
              },
            )
            .toList(growable: false),
        'finalNotes': _finalNotesHtml,
        'prompt': _selectedPromptKey == null
            ? null
            : <String, dynamic>{
                'promptKey': _selectedPromptKey,
                'name': _availablePrompts
                    .where((prompt) => prompt.promptKey == _selectedPromptKey)
                    .map((prompt) => prompt.name)
                    .cast<String?>()
                    .firstWhere(
                      (name) => name != null && name.isNotEmpty,
                      orElse: () => '',
                    ),
              },
        'personaSkillKey': _selectedPersonaSkillKey,
        'outputProfile': _selectedOutputProfile,
      },
    };
  }

  SurveyDraft _draftFromJson(Map<String, dynamic> source) {
    final draft = source['draft'];
    final payload = draft is Map<String, dynamic>
        ? draft
        : Map<String, dynamic>.from(draft as Map);

    return SurveyDraft(
      id: payload['id']?.toString(),
      surveyDisplayName: payload['surveyDisplayName']?.toString() ?? '',
      surveyName: payload['surveyName']?.toString() ?? '',
      surveyDescription: payload['surveyDescription']?.toString() ?? '',
      creatorId: payload['creatorId']?.toString() ?? '',
      createdAt: _coerceDateTime(payload['createdAt']) ?? DateTime.now(),
      modifiedAt: _coerceDateTime(payload['modifiedAt']) ?? DateTime.now(),
      instructions: InstructionsDraft(
        preamble:
            _coerceMap(payload['instructions'])['preamble']?.toString() ?? '',
        questionText:
            _coerceMap(payload['instructions'])['questionText']?.toString() ??
            '',
        answers: _coerceStringList(
          _coerceMap(payload['instructions'])['answers'],
        ),
      ),
      questions: _coerceList(payload['questions'])
          .map((entry) {
            final question = entry is Map<String, dynamic>
                ? entry
                : Map<String, dynamic>.from(entry as Map);
            return QuestionDraft(
              id: question['id'] is int
                  ? question['id'] as int
                  : int.tryParse(question['id']?.toString() ?? '') ?? 1,
              questionText: question['questionText']?.toString() ?? '',
              label: question['label']?.toString() ?? '',
              answers: _coerceStringList(question['answers']),
            );
          })
          .toList(growable: true),
      finalNotes: payload['finalNotes']?.toString() ?? '',
      prompt: _coerceMap(payload['prompt']).isEmpty
          ? null
          : SurveyPromptReferenceDraft(
              promptKey:
                  _coerceMap(payload['prompt'])['promptKey']?.toString() ?? '',
              name: _coerceMap(payload['prompt'])['name']?.toString() ?? '',
            ),
      personaSkillKey: payload['personaSkillKey']?.toString(),
      outputProfile: payload['outputProfile']?.toString(),
    );
  }

  void _applyDraftSnapshot(SurveyDraft restored) {
    _draft = restored;
    _questions = restored.questions.map((question) => question.copy()).toList();
    _instructionAnswers = List<String>.from(restored.instructions.answers);
    if (_instructionAnswers.isEmpty) {
      _instructionAnswers = [''];
    }

    _displayNameController.text = restored.surveyDisplayName;
    _nameController.text = restored.surveyName;
    _creatorIdController.text = restored.creatorId;
    _instructionsQuestionController.text = restored.instructions.questionText;
    _descriptionHtml = _normalizeHtml(restored.surveyDescription);
    _instructionsPreambleHtml = _normalizeHtml(restored.instructions.preamble);
    _finalNotesHtml = _normalizeHtml(restored.finalNotes);
    _selectedPromptKey = restored.prompt?.promptKey;
    _selectedPersonaSkillKey = restored.personaSkillKey;
    _selectedOutputProfile = restored.outputProfile;
  }

  Map<String, dynamic> _coerceMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  List<dynamic> _coerceList(dynamic value) {
    if (value is List) {
      return value;
    }
    return const <dynamic>[];
  }

  List<String> _coerceStringList(dynamic value) {
    if (value is List) {
      final values = value.map((entry) => entry?.toString() ?? '').toList();
      return values.isEmpty ? [''] : values;
    }
    return [''];
  }

  DateTime? _coerceDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  int _nextQuestionId() {
    if (_questions.isEmpty) return 1;
    final maxId = _questions.map((q) => q.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  PersonaSkillDraft? _findPersonaByKey(
    String? key, [
    List<PersonaSkillDraft>? source,
  ]) {
    final normalizedKey = key?.trim();
    if (normalizedKey == null || normalizedKey.isEmpty) {
      return null;
    }
    final catalog = source ?? _availablePersonaSkills;
    for (final persona in catalog) {
      if (persona.personaSkillKey == normalizedKey) {
        return persona;
      }
    }
    return null;
  }

  PersonaSkillDraft? _findPersonaByOutputProfile(
    String? outputProfile, [
    List<PersonaSkillDraft>? source,
  ]) {
    final normalizedOutputProfile = outputProfile?.trim();
    if (normalizedOutputProfile == null || normalizedOutputProfile.isEmpty) {
      return null;
    }
    final catalog = source ?? _availablePersonaSkills;
    for (final persona in catalog) {
      if (persona.outputProfile == normalizedOutputProfile) {
        return persona;
      }
    }
    return null;
  }

  List<String> _availableOutputProfiles() {
    final profiles = <String>[];
    final seenProfiles = <String>{};
    for (final persona in _availablePersonaSkills) {
      if (seenProfiles.add(persona.outputProfile)) {
        profiles.add(persona.outputProfile);
      }
    }
    return profiles;
  }

  List<DsValidationSummaryItem> _buildValidationItems({
    String? descriptionHtml,
    String? preambleHtml,
    String? finalNotesHtml,
  }) {
    final items = <DsValidationSummaryItem>[];

    void addItem(String label, String? message, [GlobalKey? targetKey]) {
      if (message == null || message.trim().isEmpty) {
        return;
      }
      items.add(
        DsValidationSummaryItem(
          label: label,
          message: message,
          onTap: targetKey == null
              ? null
              : () {
                  final context = targetKey.currentContext;
                  if (context != null) {
                    Scrollable.ensureVisible(
                      context,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: 0.1,
                    );
                  }
                },
        ),
      );
    }

    addItem(
      'Nome de exibição do questionário',
      DsFormValidators.validateRequired(_displayNameController.text),
      null, // Add GlobalKeys for specific fields if needed, or use section keys
    );
    addItem(
      'Nome do questionário',
      DsFormValidators.validateRequired(_nameController.text),
      null,
    );
    addItem(
      'Descrição do questionário',
      _isHtmlEmpty(descriptionHtml ?? _descriptionHtml)
          ? 'Descrição do questionário é obrigatória.'
          : null,
      _descriptionEditorKey,
    );
    addItem(
      'ID do criador',
      DsFormValidators.validateRequired(_creatorIdController.text),
      null,
    );
    addItem(
      'Notas finais',
      _isHtmlEmpty(finalNotesHtml ?? _finalNotesHtml)
          ? 'Notas finais são obrigatórias.'
          : null,
      _finalNotesEditorKey,
    );
    addItem(
      'Preâmbulo',
      _isHtmlEmpty(preambleHtml ?? _instructionsPreambleHtml)
          ? 'Preâmbulo é obrigatório.'
          : null,
      _instructionsPreambleEditorKey,
    );
    addItem(
      'Texto da pergunta das instruções',
      DsFormValidators.validateRequired(_instructionsQuestionController.text),
      null,
    );

    if (_instructionAnswers
        .where((answer) => answer.trim().isNotEmpty)
        .isEmpty) {
      addItem(
        'Respostas das instruções',
        'Adicione pelo menos uma resposta de instrução.',
      );
    }

    if (_questions.isEmpty) {
      addItem(
        'Perguntas',
        'Um questionário deve conter pelo menos uma pergunta.',
      );
    }

    for (var index = 0; index < _questions.length; index += 1) {
      final question = _questions[index];
      addItem(
        'Pergunta ${index + 1}',
        DsFormValidators.validateRequired(question.questionText),
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
          DsFormValidators.validateRequired(question.answers[answerIndex]),
        );
      }
    }

    if (_personaSkillLoadError == null && _hasStalePersonaSelection) {
      addItem(
        'Persona padrão',
        'A persona padrão salva não existe mais. Escolha outra persona ou limpe a configuração.',
      );
    }
    if (_personaSkillLoadError == null && _hasStaleOutputProfileSelection) {
      addItem(
        'Perfil de saída padrão',
        'O perfil de saída padrão salvo não existe mais. Escolha outro perfil ou limpe a configuração.',
      );
    }

    return items;
  }

  bool get _hasStalePersonaSelection {
    if (_selectedPersonaSkillKey == null || _selectedPersonaSkillKey!.isEmpty) {
      return false;
    }
    return _findPersonaByKey(_selectedPersonaSkillKey) == null;
  }

  bool get _hasStaleOutputProfileSelection {
    if (_selectedOutputProfile == null || _selectedOutputProfile!.isEmpty) {
      return false;
    }
    return _findPersonaByOutputProfile(_selectedOutputProfile) == null;
  }

  void _syncPersonaSelection(String? personaSkillKey) {
    final normalizedKey = personaSkillKey?.trim();
    setState(() {
      if (normalizedKey == null || normalizedKey.isEmpty) {
        _selectedPersonaSkillKey = null;
        _selectedOutputProfile = null;
        return;
      }
      final persona = _findPersonaByKey(normalizedKey);
      _selectedPersonaSkillKey = normalizedKey;
      _selectedOutputProfile = persona?.outputProfile;
    });
    _updateDirtyState();
  }

  void _syncOutputProfileSelection(String? outputProfile) {
    final normalizedOutputProfile = outputProfile?.trim();
    setState(() {
      if (normalizedOutputProfile == null || normalizedOutputProfile.isEmpty) {
        _selectedPersonaSkillKey = null;
        _selectedOutputProfile = null;
        return;
      }
      final persona = _findPersonaByOutputProfile(normalizedOutputProfile);
      _selectedPersonaSkillKey = persona?.personaSkillKey;
      _selectedOutputProfile = normalizedOutputProfile;
    });
    _updateDirtyState();
  }

  Future<void> _save() async {
    final formState = _formKey.currentState;
    final descriptionHtml =
        await _descriptionEditorKey.currentState?.getHtml() ?? _descriptionHtml;
    final preambleHtml =
        await _instructionsPreambleEditorKey.currentState?.getHtml() ??
        _instructionsPreambleHtml;
    final finalNotesHtml =
        await _finalNotesEditorKey.currentState?.getHtml() ?? _finalNotesHtml;
    final validationItems = _buildValidationItems(
      descriptionHtml: descriptionHtml,
      preambleHtml: preambleHtml,
      finalNotesHtml: finalNotesHtml,
    );

    if (formState == null ||
        !formState.validate() ||
        validationItems.isNotEmpty) {
      setState(() {
        _hasSubmitted = true;
        _validationItems = validationItems;
        _feedback = const DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Revise o formulário',
          message:
              'Corrija os itens destacados e o resumo acima antes de salvar.',
        );
      });
      return;
    }

    setState(() => _saving = true);
    try {
      _draft
        ..surveyDisplayName = _displayNameController.text.trim()
        ..surveyName = _nameController.text.trim()
        ..surveyDescription = descriptionHtml.trim()
        ..creatorId = _creatorIdController.text.trim()
        ..finalNotes = finalNotesHtml.trim()
        ..modifiedAt = DateTime.now();

      _draft.instructions
        ..preamble = preambleHtml.trim()
        ..questionText = _instructionsQuestionController.text.trim()
        ..answers = _instructionAnswers
            .map((answer) => answer.trim())
            .where((answer) => answer.isNotEmpty)
            .toList();

      _draft.questions = _questions
          .map(
            (q) => QuestionDraft(
              id: q.id,
              questionText: q.questionText.trim(),
              label: q.label.trim(),
              answers: q.answers
                  .map((answer) => answer.trim())
                  .where((answer) => answer.isNotEmpty)
                  .toList(),
            ),
          )
          .toList();
      final selectedPrompt = _availablePrompts.where(
        (item) => item.promptKey == _selectedPromptKey,
      );
      _draft.prompt = selectedPrompt.isEmpty
          ? null
          : SurveyPromptReferenceDraft(
              promptKey: selectedPrompt.first.promptKey,
              name: selectedPrompt.first.name,
            );
      if (_personaSkillLoadError == null) {
        final selectedPersona =
            _findPersonaByKey(_selectedPersonaSkillKey) ??
            _findPersonaByOutputProfile(_selectedOutputProfile);
        _draft
          ..personaSkillKey = selectedPersona?.personaSkillKey
          ..outputProfile = selectedPersona?.outputProfile;
      } else {
        _draft
          ..personaSkillKey = _selectedPersonaSkillKey
          ..outputProfile = _selectedOutputProfile;
      }

      if (_draft.id == null || _draft.id!.isEmpty) {
        await _repo.createSurvey(_draft);
      } else {
        await _repo.updateSurvey(_draft);
      }

      await _clearLocalDraft();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      _showError('Falha ao salvar: $error');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _feedback = DsFeedbackMessage(
        severity: DsStatusType.error,
        title: 'Revise o formulário',
        message: message,
      );
    });
  }

  bool _isHtmlEmpty(String html) {
    final stripped = html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\\s+'), ' ')
        .trim();
    return stripped.isEmpty;
  }

  String _normalizeHtml(String html) {
    final trimmed = html.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    if (trimmed.contains('<')) {
      return trimmed;
    }
    return '<p>${trimmed.replaceAll('\n', '<br>')}</p>';
  }

  void _moveQuestion(int fromIndex, int toIndex) {
    if (toIndex < 0 || toIndex >= _questions.length) {
      return;
    }
    setState(() {
      final moved = _questions.removeAt(fromIndex);
      _questions.insert(toIndex, moved);
    });
    _updateDirtyState();
  }

  String? _validateRequiredField(String? value) {
    return DsFormValidators.validateRequired(value);
  }

  Future<void> _confirmCancel() async {
    if (!_isDirty) {
      Navigator.of(context).pop();
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DsDialog(
        severity: DsStatusType.warning,
        title: 'Descartar alterações?',
        content: const Text(
          'Você tem alterações não salvas. Deseja descartá-las?',
        ),
        actions: [
          DsTextButton(
            label: 'Continuar editando',
            onPressed: () => Navigator.pop(context, false),
          ),
          DsOutlinedButton(
            label: 'Descartar rascunho',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final navigator = Navigator.of(context);
    await _clearLocalDraft();
    navigator.pop();
  }

  String _formatLocalDraftTime(DateTime value) {
    final hours = value.hour.toString().padLeft(2, '0');
    final minutes = value.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  List<MapEntry<String, GlobalKey>> get _sectionAnchors => [
    MapEntry<String, GlobalKey>(_detailsSectionId, _detailsSectionKey),
    MapEntry<String, GlobalKey>(
      _instructionsSectionId,
      _instructionsSectionKey,
    ),
    MapEntry<String, GlobalKey>(_promptSectionId, _promptSectionKey),
    MapEntry<String, GlobalKey>(_personaSectionId, _personaSectionKey),
    MapEntry<String, GlobalKey>(_questionsSectionId, _questionsSectionKey),
  ];

  String _sectionLabel(String sectionId) {
    switch (sectionId) {
      case _detailsSectionId:
        return 'Detalhes';
      case _instructionsSectionId:
        return 'Instruções';
      case _promptSectionId:
        return 'Prompt de IA';
      case _personaSectionId:
        return 'Configuração de persona';
      case _questionsSectionId:
        return 'Perguntas';
      default:
        return 'Detalhes';
    }
  }

  void _handleSectionScroll() {
    final nextSectionId = _resolveCurrentSectionId();
    if (nextSectionId == _currentSectionId || !mounted) {
      return;
    }
    setState(() => _currentSectionId = nextSectionId);
  }

  String _resolveCurrentSectionId() {
    const activationOffset = 180.0;
    var resolved = _detailsSectionId;
    var foundAnchorAboveFold = false;

    for (final MapEntry<String, GlobalKey> entry in _sectionAnchors) {
      final sectionContext = entry.value.currentContext;
      if (sectionContext == null) {
        continue;
      }
      final renderObject = sectionContext.findRenderObject();
      if (renderObject is! RenderBox) {
        continue;
      }
      final top = renderObject.localToGlobal(Offset.zero).dy;
      if (top <= activationOffset) {
        resolved = entry.key;
        foundAnchorAboveFold = true;
        continue;
      }
      if (!foundAnchorAboveFold) {
        resolved = entry.key;
      }
      break;
    }

    return resolved;
  }

  void _jumpToSection(String sectionId) {
    unawaited(_scrollToSection(sectionId));
  }

  Future<void> _scrollToSection(String sectionId) async {
    final target = _sectionAnchors
        .where((MapEntry<String, GlobalKey> entry) => entry.key == sectionId)
        .map((MapEntry<String, GlobalKey> entry) => entry.value.currentContext)
        .firstWhere(
          (BuildContext? context) => context != null,
          orElse: () => null,
        );
    if (target == null) {
      return;
    }
    setState(() => _currentSectionId = sectionId);
    await Scrollable.ensureVisible(
      target,
      alignment: 0.08,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  List<DsBreadcrumbItem> _buildBreadcrumbs(bool isEditing) {
    return [
      DsBreadcrumbItem(
        label: 'Questionários',
        onPressed: _saving ? null : () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const TaskDashboardPage()),
        ),
      ),
      DsBreadcrumbItem(
        label: isEditing ? 'Editar questionário' : 'Criar questionário',
        isCurrent: true,
      ),
    ];
  }

  Widget? _buildDraftStatusFeedback() {
    if (_saving) {
      return const DsInlineMessage(
        feedback: DsFeedbackMessage(
          severity: DsStatusType.info,
          title: 'Salvando alterações',
          message: 'Publicando questionário e sincronizando dados.',
        ),
      );
    }
    if (_isDirty) {
      final message = _lastLocalDraftSavedAt == null
          ? 'Alterações ainda não publicadas. Rascunho local preservado automaticamente.'
          : 'Alterações ainda não publicadas. Último rascunho salvo às ${_formatLocalDraftTime(_lastLocalDraftSavedAt!)}.';
      return DsInlineMessage(
        feedback: DsFeedbackMessage(
          severity: DsStatusType.warning,
          title: 'Alterações não salvas',
          message: message,
        ),
      );
    }
    if (_restoredLocalDraft) {
      final suffix = _lastLocalDraftSavedAt == null
          ? ''
          : ' às ${_formatLocalDraftTime(_lastLocalDraftSavedAt!)}';
      return DsInlineMessage(
        feedback: DsFeedbackMessage(
          severity: DsStatusType.info,
          title: 'Rascunho restaurado',
          message: 'Rascunho local restaurado$suffix. Salve após revisar.',
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _draft.id != null && _draft.id!.isNotEmpty;
    final draftStatusFeedback = _buildDraftStatusFeedback();
    return DsScaffold(
      title: isEditing ? 'Editar questionário' : 'Criar questionário',
      subtitle: 'Configure conteúdo, instruções, prompts e perguntas.',
      breadcrumbs: _buildBreadcrumbs(isEditing),
      onBack: _saving ? null : _confirmCancel,
      backLabel: 'Voltar',
      scrollable: false,
      body: Form(
        key: _formKey,
        child: DsAdminFormShell(
          isSaving: _saving,
          hasUnsavedChanges: _isDirty,
          onCancel: _saving ? () {} : _confirmCancel,
          onSave: _saving ? () {} : _save,
          scrollController: _scrollController,
          stickyFooter: const SizedBox.shrink(), // Explicitly enable sticky footer
          sectionalNav: DsSectionalNav(
            items: _sectionAnchors
                .map(
                  (entry) => DsSectionalNavItem(
                    label: _sectionLabel(entry.key),
                    targetKey: entry.value,
                  ),
                )
                .toList(),
            activeItem: _sectionAnchors
                .where((entry) => entry.key == _currentSectionId)
                .map(
                  (entry) => DsSectionalNavItem(
                    label: _sectionLabel(entry.key),
                    targetKey: entry.value,
                  ),
                )
                .firstOrNull,
            onItemTap: (item) => _jumpToSection(
              _sectionAnchors.firstWhere((e) => e.value == item.targetKey).key,
            ),
          ),
          feedback: _feedback == null
              ? null
              : DsMessageBanner(
                  feedback: DsFeedbackMessage(
                    severity: _feedback!.severity,
                    title: _feedback!.title,
                    message: _feedback!.message,
                    dismissible: true,
                    onDismiss: () => setState(() => _feedback = null),
                  ),
                  margin: EdgeInsets.zero,
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_validationItems.isNotEmpty) ...[
                DsValidationSummary(
                  items: _validationItems,
                  description:
                      'Revise os itens abaixo e os campos destacados antes de salvar.',
                ),
                const SizedBox(height: 16),
              ],
              if (draftStatusFeedback != null) ...[
                draftStatusFeedback,
                const SizedBox(height: 16),
              ],
              DsSection(
                key: _detailsSectionKey,
                eyebrow: 'Questionário',
                title: 'Detalhes do questionário',
                subtitle:
                    'Organize os metadados principais e o conteúdo que contextualiza este formulário administrativo.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DsValidatedTextFormField(
                      controller: _displayNameController,
                      submitted: _hasSubmitted,
                      decoration: const InputDecoration(
                        labelText: 'Nome de exibição do questionário *',
                      ),
                      validator: _validateRequiredField,
                    ),
                    const SizedBox(height: 12),
                    DsValidatedTextFormField(
                      controller: _nameController,
                      submitted: _hasSubmitted,
                      decoration: const InputDecoration(
                        labelText: 'Nome do questionário *',
                      ),
                      validator: _validateRequiredField,
                    ),
                    const SizedBox(height: 12),
                    HtmlRichTextEditor(
                      key: _descriptionEditorKey,
                      label: 'Descrição do questionário *',
                      initialHtml: _descriptionHtml,
                      errorText: _hasSubmitted && _isHtmlEmpty(_descriptionHtml)
                          ? 'Descrição do questionário é obrigatória.'
                          : null,
                      onChanged: (value) {
                        _descriptionHtml = value;
                        _markDirty();
                        _syncValidationSummary();
                      },
                    ),
                    const SizedBox(height: 12),
                    DsValidatedTextFormField(
                      controller: _creatorIdController,
                      submitted: _hasSubmitted,
                      decoration: const InputDecoration(
                        labelText: 'ID do criador *',
                      ),
                      validator: _validateRequiredField,
                    ),
                    const SizedBox(height: 12),
                    HtmlRichTextEditor(
                      key: _finalNotesEditorKey,
                      label: 'Notas finais *',
                      initialHtml: _finalNotesHtml,
                      errorText: _hasSubmitted && _isHtmlEmpty(_finalNotesHtml)
                          ? 'Notas finais são obrigatórias.'
                          : null,
                      onChanged: (value) {
                        _finalNotesHtml = value;
                        _markDirty();
                        _syncValidationSummary();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DsSection(
                key: _instructionsSectionKey,
                eyebrow: 'Orientação',
                title: 'Instruções',
                subtitle:
                    'Defina o preâmbulo e as respostas esperadas antes de publicar o questionário.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HtmlRichTextEditor(
                      key: _instructionsPreambleEditorKey,
                      label: 'Preâmbulo *',
                      initialHtml: _instructionsPreambleHtml,
                      errorText:
                          _hasSubmitted &&
                              _isHtmlEmpty(_instructionsPreambleHtml)
                          ? 'Preâmbulo é obrigatório.'
                          : null,
                      onChanged: (value) {
                        _instructionsPreambleHtml = value;
                        _markDirty();
                        _syncValidationSummary();
                      },
                    ),
                    const SizedBox(height: 12),
                    DsValidatedTextFormField(
                      controller: _instructionsQuestionController,
                      submitted: _hasSubmitted,
                      decoration: const InputDecoration(
                        labelText: 'Texto da pergunta *',
                      ),
                      validator: _validateRequiredField,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Respostas das instruções',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _instructionAnswers.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Expanded(
                              child: DsValidatedTextFormField(
                                key: ValueKey(
                                  'instruction-answer-$index-${_instructionAnswers[index]}',
                                ),
                                initialValue: _instructionAnswers[index],
                                submitted: _hasSubmitted,
                                decoration: const InputDecoration(
                                  labelText: 'Resposta *',
                                ),
                                validator: _validateRequiredField,
                                onChanged: (value) {
                                  _markDirty();
                                  _instructionAnswers[index] = value;
                                  _syncValidationSummary();
                                },
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remover resposta',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: _instructionAnswers.length <= 1
                                  ? null
                                  : () {
                                      setState(() {
                                        _instructionAnswers.removeAt(index);
                                      });
                                      _updateDirtyState();
                                    },
                            ),
                          ],
                        );
                      },
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _instructionAnswers.add('');
                          });
                          _updateDirtyState();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar resposta de instrução'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DsSection(
                key: _promptSectionKey,
                eyebrow: 'Automação',
                title: 'Prompt de IA',
                subtitle:
                    'Associe um prompt reutilizável quando este questionário já tiver um fluxo de IA definido.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_loadingPrompts)
                      const LinearProgressIndicator()
                    else if (_promptLoadError != null)
                      DsPanel(
                        tone: DsPanelTone.high,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.errorContainer,
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Não foi possível carregar os prompts: $_promptLoadError',
                        ),
                      )
                    else ...[
                      if (_availablePrompts.isEmpty)
                        DsFocusFrame(
                          child: const Text(
                            'Nenhum prompt disponível. O questionário usará o fluxo legado até que prompts sejam cadastrados.',
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DropdownButtonFormField<String?>(
                          key: const ValueKey('survey-prompt-selector'),
                          initialValue: _selectedPromptKey,
                          decoration: const InputDecoration(
                            labelText: 'Prompt de IA (opcional)',
                            helperText:
                                'Selecione um prompt reutilizável ou deixe vazio para manter o fluxo legado.',
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Nenhum prompt'),
                            ),
                            ..._availablePrompts.map(
                              (prompt) => DropdownMenuItem<String?>(
                                value: prompt.promptKey,
                                child: Text(prompt.name),
                              ),
                            ),
                          ],
                          onChanged: _saving
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedPromptKey = value;
                                  });
                                  _updateDirtyState(
                                    syncValidationSummary: false,
                                  );
                                },
                        ),
                      ),
                      if (_selectedPromptKey == null ||
                          _selectedPromptKey!.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Nenhum prompt associado. O questionário poderá continuar usando o comportamento legado.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DsSection(
                key: _personaSectionKey,
                eyebrow: 'Narrativa',
                title: 'Configuração de persona',
                subtitle:
                    'Mantenha a persona e o perfil de saída alinhados ao comportamento padrão esperado para os relatórios.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_loadingPersonaSkills)
                      const LinearProgressIndicator()
                    else if (_personaSkillLoadError != null)
                      DsPanel(
                        tone: DsPanelTone.high,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.errorContainer,
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Não foi possível carregar as personas: $_personaSkillLoadError',
                        ),
                      )
                    else ...[
                      if (_availablePersonaSkills.isEmpty)
                        DsFocusFrame(
                          child: const Text(
                            'Nenhuma persona disponível. O questionário continuará usando os padrões legados até que personas sejam cadastradas.',
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DropdownButtonFormField<String?>(
                          key: const ValueKey('survey-persona-selector'),
                          initialValue: _selectedPersonaSkillKey,
                          decoration: const InputDecoration(
                            labelText: 'Persona padrão (opcional)',
                            helperText:
                                'Selecione a persona padrão para relatórios sem sobrescritas no runtime.',
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Nenhuma persona'),
                            ),
                            if (_hasStalePersonaSelection)
                              DropdownMenuItem<String?>(
                                value: _selectedPersonaSkillKey,
                                child: Text(
                                  'Persona removida (${_selectedPersonaSkillKey!})',
                                ),
                              ),
                            ..._availablePersonaSkills.map(
                              (persona) => DropdownMenuItem<String?>(
                                value: persona.personaSkillKey,
                                child: Text(persona.name),
                              ),
                            ),
                          ],
                          onChanged: _saving ? null : _syncPersonaSelection,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DropdownButtonFormField<String?>(
                          key: const ValueKey('survey-output-profile-selector'),
                          initialValue: _selectedOutputProfile,
                          decoration: const InputDecoration(
                            labelText: 'Perfil de saída padrão (opcional)',
                            helperText:
                                'Esse perfil acompanha a persona padrão e é usado antes do fallback legado.',
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Nenhum perfil'),
                            ),
                            if (_hasStaleOutputProfileSelection)
                              DropdownMenuItem<String?>(
                                value: _selectedOutputProfile,
                                child: Text(
                                  'Perfil removido (${_selectedOutputProfile!})',
                                ),
                              ),
                            ..._availableOutputProfiles().map(
                              (outputProfile) => DropdownMenuItem<String?>(
                                value: outputProfile,
                                child: Text(outputProfile),
                              ),
                            ),
                          ],
                          onChanged: _saving
                              ? null
                              : _syncOutputProfileSelection,
                        ),
                      ),
                      if (_hasStalePersonaSelection ||
                          _hasStaleOutputProfileSelection)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'A configuração salva referencia uma persona removida. Escolha uma nova persona ou limpe a configuração antes de salvar.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DsSection(
                key: _questionsSectionKey,
                eyebrow: 'Estrutura',
                title: 'Perguntas',
                subtitle:
                    'Monte a ordem final do questionário e revise os rótulos exibidos nas prévias e nos relatórios.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Perguntas cadastradas',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 180),
                          child: DsOutlinedButton(
                            label: 'Adicionar pergunta',
                            onPressed: () {
                              setState(() {
                                _questions.add(
                                  QuestionDraft(
                                    id: _nextQuestionId(),
                                    questionText: '',
                                    label: '',
                                    answers: [''],
                                  ),
                                );
                              });
                              _updateDirtyState();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_questions.isEmpty)
                      Text(
                        'Nenhuma pergunta adicionada ainda.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _questions.length,
                      itemBuilder: (context, questionIndex) {
                        final question = _questions[questionIndex];
                        return DsSection(
                          key: ValueKey('question-card-${question.id}'),
                          tone: DsPanelTone.high,
                          title: 'Pergunta ${questionIndex + 1}',
                          action: Wrap(
                            spacing: 4,
                            children: [
                              IconButton(
                                tooltip: 'Mover para cima',
                                icon: const Icon(Icons.arrow_upward),
                                onPressed: questionIndex == 0
                                    ? null
                                    : () => _moveQuestion(
                                        questionIndex,
                                        questionIndex - 1,
                                      ),
                              ),
                              IconButton(
                                tooltip: 'Mover para baixo',
                                icon: const Icon(Icons.arrow_downward),
                                onPressed:
                                    questionIndex == _questions.length - 1
                                    ? null
                                    : () => _moveQuestion(
                                        questionIndex,
                                        questionIndex + 1,
                                      ),
                              ),
                              IconButton(
                                tooltip: 'Remover pergunta',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  setState(() {
                                    _questions.removeAt(questionIndex);
                                  });
                                  _updateDirtyState();
                                },
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DsValidatedTextFormField(
                                key: ValueKey(
                                  'question-$questionIndex-${question.id}',
                                ),
                                initialValue: question.questionText,
                                submitted: _hasSubmitted,
                                decoration: const InputDecoration(
                                  labelText: 'Texto da pergunta *',
                                ),
                                validator: _validateRequiredField,
                                onChanged: (value) {
                                  _markDirty();
                                  question.questionText = value;
                                  _syncValidationSummary();
                                },
                              ),
                              const SizedBox(height: 12),
                              DsValidatedTextFormField(
                                key: ValueKey(
                                  'question-label-$questionIndex-${question.id}',
                                ),
                                initialValue: question.label,
                                submitted: _hasSubmitted,
                                decoration: const InputDecoration(
                                  labelText: 'Rótulo exibido no radar',
                                  helperText:
                                      'Opcional, usado no radar e nas prévias para pacientes.',
                                ),
                                onChanged: (value) {
                                  _markDirty();
                                  question.label = value;
                                },
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rótulo atual: ${question.label.trim().isNotEmpty ? question.label.trim() : 'Q${question.id}'}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Respostas',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: question.answers.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, answerIndex) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: DsValidatedTextFormField(
                                          key: ValueKey(
                                            'question-$questionIndex-answer-$answerIndex-${question.answers[answerIndex]}',
                                          ),
                                          initialValue:
                                              question.answers[answerIndex],
                                          submitted: _hasSubmitted,
                                          decoration: const InputDecoration(
                                            labelText: 'Resposta *',
                                          ),
                                          validator: _validateRequiredField,
                                          onChanged: (value) {
                                            _markDirty();
                                            question.answers[answerIndex] =
                                                value;
                                            _syncValidationSummary();
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Remover resposta',
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: question.answers.length <= 1
                                            ? null
                                            : () {
                                                setState(() {
                                                  question.answers.removeAt(
                                                    answerIndex,
                                                  );
                                                });
                                                _updateDirtyState();
                                              },
                                      ),
                                    ],
                                  );
                                },
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      question.answers.add('');
                                    });
                                    _updateDirtyState();
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Adicionar resposta'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
