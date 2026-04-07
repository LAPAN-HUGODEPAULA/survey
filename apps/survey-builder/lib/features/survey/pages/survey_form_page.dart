import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/models/persona_skill_draft.dart';
import 'package:survey_builder/core/models/survey_draft.dart';
import 'package:survey_builder/core/models/survey_prompt_draft.dart';
import 'package:survey_builder/core/repositories/persona_skill_repository.dart';
import 'package:survey_builder/core/repositories/survey_prompt_repository.dart';
import 'package:survey_builder/core/repositories/survey_repository.dart';
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
  final _formKey = GlobalKey<FormState>();
  late final SurveyRepository _repo;
  late final SurveyPromptRepository _promptRepo;
  late final PersonaSkillRepository _personaSkillRepo;

  late SurveyDraft _draft;
  bool _saving = false;
  bool _isDirty = false;
  bool _loadingPrompts = true;
  bool _loadingPersonaSkills = true;
  String? _promptLoadError;
  String? _personaSkillLoadError;
  DsFeedbackMessage? _feedback;

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
      controller.addListener(_markDirty);
    }
    _loadPrompts();
    _loadPersonaSkills();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _nameController.dispose();
    _creatorIdController.dispose();
    _instructionsQuestionController.dispose();
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

  void _markDirty() {
    if (!_isDirty) {
      setState(() => _isDirty = true);
    }
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
    if (normalizedKey == null || normalizedKey.isEmpty) {
      _selectedPersonaSkillKey = null;
      _selectedOutputProfile = null;
      _markDirty();
      return;
    }
    final persona = _findPersonaByKey(normalizedKey);
    _selectedPersonaSkillKey = normalizedKey;
    _selectedOutputProfile = persona?.outputProfile;
    _markDirty();
  }

  void _syncOutputProfileSelection(String? outputProfile) {
    final normalizedOutputProfile = outputProfile?.trim();
    if (normalizedOutputProfile == null || normalizedOutputProfile.isEmpty) {
      _selectedPersonaSkillKey = null;
      _selectedOutputProfile = null;
      _markDirty();
      return;
    }
    final persona = _findPersonaByOutputProfile(normalizedOutputProfile);
    _selectedPersonaSkillKey = persona?.personaSkillKey;
    _selectedOutputProfile = normalizedOutputProfile;
    _markDirty();
  }

  Future<void> _save() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }
    final descriptionHtml =
        await _descriptionEditorKey.currentState?.getHtml() ?? _descriptionHtml;
    final preambleHtml =
        await _instructionsPreambleEditorKey.currentState?.getHtml() ??
        _instructionsPreambleHtml;
    final finalNotesHtml =
        await _finalNotesEditorKey.currentState?.getHtml() ?? _finalNotesHtml;

    if (_isHtmlEmpty(descriptionHtml)) {
      _showError('Descrição do questionário é obrigatória.');
      return;
    }
    if (_isHtmlEmpty(preambleHtml)) {
      _showError('Preâmbulo é obrigatório.');
      return;
    }
    if (_isHtmlEmpty(finalNotesHtml)) {
      _showError('Notas finais são obrigatórias.');
      return;
    }

    if (_questions.isEmpty) {
      _showError('Um questionário deve conter pelo menos uma pergunta.');
      return;
    }
    for (final question in _questions) {
      if (question.answers.where((a) => a.trim().isNotEmpty).isEmpty) {
        _showError('Cada pergunta deve conter pelo menos uma resposta.');
        return;
      }
    }

    if (_personaSkillLoadError == null) {
      if (_hasStalePersonaSelection) {
        _showError(
          'A persona padrão salva não existe mais. Escolha outra persona ou limpe a configuração.',
        );
        return;
      }
      if (_hasStaleOutputProfileSelection) {
        _showError(
          'O perfil de saída padrão salvo não existe mais. Escolha outro perfil ou limpe a configuração.',
        );
        return;
      }
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
      _markDirty();
    });
  }

  Future<void> _confirmCancel() async {
    if (!_isDirty) {
      Navigator.of(context).pop();
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DsDialog(
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
            label: 'Descartar',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _draft.id != null && _draft.id!.isNotEmpty;
    return DsScaffold(
      title: isEditing ? 'Editar questionário' : 'Criar questionário',
      subtitle:
          'Configure conteúdo, instruções, prompts e perguntas usando o shell administrativo compartilhado.',
      scrollable: true,
      body: Form(
        key: _formKey,
        child: DsAdminFormShell(
          isSaving: _saving,
          onCancel: _saving ? () {} : _confirmCancel,
          onSave: _saving ? () {} : _save,
          feedback: _feedback == null
              ? null
              : DsFeedbackBanner(
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
              Text(
                'Detalhes do questionário',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome de exibição do questionário *',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Campo obrigatório'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do questionário *',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Campo obrigatório'
                    : null,
              ),
              const SizedBox(height: 12),
              HtmlRichTextEditor(
                key: _descriptionEditorKey,
                label: 'Descrição do questionário *',
                initialHtml: _descriptionHtml,
                onChanged: (value) {
                  _descriptionHtml = value;
                  _markDirty();
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _creatorIdController,
                decoration: const InputDecoration(labelText: 'ID do criador *'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Campo obrigatório'
                    : null,
              ),
              const SizedBox(height: 12),
              HtmlRichTextEditor(
                key: _finalNotesEditorKey,
                label: 'Notas finais *',
                initialHtml: _finalNotesHtml,
                onChanged: (value) {
                  _finalNotesHtml = value;
                  _markDirty();
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Instruções',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              HtmlRichTextEditor(
                key: _instructionsPreambleEditorKey,
                label: 'Preâmbulo *',
                initialHtml: _instructionsPreambleHtml,
                onChanged: (value) {
                  _instructionsPreambleHtml = value;
                  _markDirty();
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _instructionsQuestionController,
                decoration: const InputDecoration(
                  labelText: 'Texto da pergunta *',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Campo obrigatório'
                    : null,
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
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: ValueKey(
                            'instruction-answer-$index-${_instructionAnswers[index]}',
                          ),
                          initialValue: _instructionAnswers[index],
                          decoration: const InputDecoration(
                            labelText: 'Resposta',
                          ),
                          onChanged: (value) {
                            _markDirty();
                            _instructionAnswers[index] = value;
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
                                  _markDirty();
                                });
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
                      _markDirty();
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar resposta de instrução'),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Prompt de IA',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (_loadingPrompts)
                const LinearProgressIndicator()
              else if (_promptLoadError != null)
                DsPanel(
                  tone: DsPanelTone.high,
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
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
                              _markDirty();
                            });
                          },
                  ),
                ),
                if (_selectedPromptKey == null || _selectedPromptKey!.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Nenhum prompt associado. O questionário poderá continuar usando o comportamento legado.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              Text(
                'Configuração de persona',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (_loadingPersonaSkills)
                const LinearProgressIndicator()
              else if (_personaSkillLoadError != null)
                DsPanel(
                  tone: DsPanelTone.high,
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
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
                    onChanged: _saving
                        ? null
                        : (value) {
                            setState(() => _syncPersonaSelection(value));
                          },
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
                        : (value) {
                            setState(() => _syncOutputProfileSelection(value));
                          },
                  ),
                ),
                if (_hasStalePersonaSelection ||
                    _hasStaleOutputProfileSelection)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'A configuração salva referencia uma persona removida. Escolha uma nova persona ou limpe a configuração antes de salvar.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Perguntas',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 160,
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
                          _markDirty();
                        });
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
                          onPressed: questionIndex == _questions.length - 1
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
                              _markDirty();
                            });
                          },
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          key: ValueKey(
                            'question-$questionIndex-${question.id}',
                          ),
                          initialValue: question.questionText,
                          decoration: const InputDecoration(
                            labelText: 'Texto da pergunta *',
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Campo obrigatório'
                              : null,
                          onChanged: (value) {
                            _markDirty();
                            question.questionText = value;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: ValueKey(
                            'question-label-$questionIndex-${question.id}',
                          ),
                          initialValue: question.label,
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
                                  child: TextFormField(
                                    key: ValueKey(
                                      'question-$questionIndex-answer-$answerIndex-${question.answers[answerIndex]}',
                                    ),
                                    initialValue: question.answers[answerIndex],
                                    decoration: const InputDecoration(
                                      labelText: 'Resposta *',
                                    ),
                                    validator: (value) =>
                                        value == null || value.trim().isEmpty
                                        ? 'Campo obrigatório'
                                        : null,
                                    onChanged: (value) {
                                      _markDirty();
                                      question.answers[answerIndex] = value;
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
                                            _markDirty();
                                          });
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
                                _markDirty();
                              });
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
      ),
    );
  }
}
