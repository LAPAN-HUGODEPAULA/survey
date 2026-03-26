import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/models/survey_draft.dart';
import 'package:survey_builder/core/models/survey_prompt_draft.dart';
import 'package:survey_builder/core/repositories/survey_prompt_repository.dart';
import 'package:survey_builder/core/repositories/survey_repository.dart';
import 'package:survey_builder/features/survey/widgets/html_rich_text_editor.dart';

class SurveyFormPage extends StatefulWidget {
  const SurveyFormPage({
    super.key,
    this.initialDraft,
    this.repository,
    this.promptRepository,
  });

  final SurveyDraft? initialDraft;
  final SurveyRepository? repository;
  final SurveyPromptRepository? promptRepository;

  @override
  State<SurveyFormPage> createState() => _SurveyFormPageState();
}

class _SurveyFormPageState extends State<SurveyFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final SurveyRepository _repo;
  late final SurveyPromptRepository _promptRepo;

  late SurveyDraft _draft;
  bool _saving = false;
  bool _isDirty = false;
  bool _loadingPrompts = true;
  String? _promptLoadError;

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
  String? _selectedPromptKey;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? SurveyRepository();
    _promptRepo = widget.promptRepository ?? SurveyPromptRepository();
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

    for (final controller in [
      _displayNameController,
      _nameController,
      _creatorIdController,
      _instructionsQuestionController,
    ]) {
      controller.addListener(_markDirty);
    }
    _loadPrompts();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _nameController.dispose();
    _creatorIdController.dispose();
    _instructionsQuestionController.dispose();
    _repo.dispose();
    _promptRepo.dispose();
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

      if (_draft.id == null || _draft.id!.isEmpty) {
        await _repo.createSurvey(_draft);
      } else {
        await _repo.updateSurvey(_draft);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
      appBar: AppBar(
        title: Text(isEditing ? 'Editar questionário' : 'Criar questionário'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    width: 140,
                    child: DsOutlinedButton(
                      label: 'Cancelar',
                      onPressed: _saving ? null : _confirmCancel,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 140,
                    child: DsFilledButton(
                      label: _saving ? 'Salvando...' : 'Salvar',
                      onPressed: _saving ? null : _save,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Não foi possível carregar os prompts: $_promptLoadError',
                  ),
                )
              else ...[
                if (_availablePrompts.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                  return Card(
                    key: ValueKey('question-card-${question.id}'),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                              Expanded(
                                child: TextFormField(
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
                          const SizedBox(height: 8),
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
                                      initialValue:
                                          question.answers[answerIndex],
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
