library;

import 'package:flutter/material.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:survey_builder/core/models/survey_draft.dart';
import 'package:survey_builder/core/repositories/survey_repository.dart';

class SurveyFormPage extends StatefulWidget {
  const SurveyFormPage({super.key, this.initialDraft, this.repository});

  final SurveyDraft? initialDraft;
  final SurveyRepository? repository;

  @override
  State<SurveyFormPage> createState() => _SurveyFormPageState();
}

class _SurveyFormPageState extends State<SurveyFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final SurveyRepository _repo;

  late SurveyDraft _draft;
  bool _saving = false;
  bool _isDirty = false;

  late TextEditingController _displayNameController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _creatorIdController;
  late TextEditingController _finalNotesController;
  late TextEditingController _instructionsPreambleController;
  late TextEditingController _instructionsQuestionController;

  List<String> _instructionAnswers = [];
  List<QuestionDraft> _questions = [];

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? SurveyRepository();
    _draft = widget.initialDraft?.copy() ?? _emptyDraft();
    _questions = _draft.questions.map((q) => q.copy()).toList();
    _instructionAnswers = List<String>.from(_draft.instructions.answers);
    if (_instructionAnswers.isEmpty) {
      _instructionAnswers.add('');
    }

    _displayNameController = TextEditingController(text: _draft.surveyDisplayName);
    _nameController = TextEditingController(text: _draft.surveyName);
    _descriptionController = TextEditingController(text: _draft.surveyDescription);
    _creatorIdController = TextEditingController(text: _draft.creatorId);
    _finalNotesController = TextEditingController(text: _draft.finalNotes);
    _instructionsPreambleController =
        TextEditingController(text: _draft.instructions.preamble);
    _instructionsQuestionController =
        TextEditingController(text: _draft.instructions.questionText);

    for (final controller in [
      _displayNameController,
      _nameController,
      _descriptionController,
      _creatorIdController,
      _finalNotesController,
      _instructionsPreambleController,
      _instructionsQuestionController,
    ]) {
      controller.addListener(_markDirty);
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _creatorIdController.dispose();
    _finalNotesController.dispose();
    _instructionsPreambleController.dispose();
    _instructionsQuestionController.dispose();
    _repo.dispose();
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
      instructions: InstructionsDraft(preamble: '', questionText: '', answers: ['']),
      questions: [],
      finalNotes: '',
    );
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
    if (_questions.isEmpty) {
      _showError('A survey must contain at least one question.');
      return;
    }
    for (final question in _questions) {
      if (question.answers.where((a) => a.trim().isNotEmpty).isEmpty) {
        _showError('Each question must contain at least one answer.');
        return;
      }
    }

    setState(() => _saving = true);
    try {
      _draft
        ..surveyDisplayName = _displayNameController.text.trim()
        ..surveyName = _nameController.text.trim()
        ..surveyDescription = _descriptionController.text.trim()
        ..creatorId = _creatorIdController.text.trim()
        ..finalNotes = _finalNotesController.text.trim()
        ..modifiedAt = DateTime.now();

      _draft.instructions
        ..preamble = _instructionsPreambleController.text.trim()
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

      if (_draft.id == null || _draft.id!.isEmpty) {
        await _repo.createSurvey(_draft);
      } else {
        await _repo.updateSurvey(_draft);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      _showError('Failed to save: $error');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmCancel() async {
    if (!_isDirty) {
      Navigator.of(context).pop();
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DsDialog(
        title: 'Discard changes?',
        content: const Text('You have unsaved changes. Discard them?'),
        actions: [
          DsTextButton(
            label: 'Keep editing',
            onPressed: () => Navigator.pop(context, false),
          ),
          DsOutlinedButton(
            label: 'Discard',
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
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Survey' : 'Create Survey'),
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
                      label: 'Cancel',
                      onPressed: _saving ? null : _confirmCancel,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 140,
                    child: DsFilledButton(
                      label: _saving ? 'Saving...' : 'Save',
                      onPressed: _saving ? null : _save,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Survey Details', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Survey Display Name *'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Survey Name *'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Survey Description *'),
                maxLines: 2,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _creatorIdController,
                decoration: const InputDecoration(labelText: 'Creator ID *'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _finalNotesController,
                decoration: const InputDecoration(labelText: 'Final Notes *'),
                maxLines: 2,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 24),
              Text('Instructions', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _instructionsPreambleController,
                decoration: const InputDecoration(labelText: 'Preamble *'),
                maxLines: 2,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _instructionsQuestionController,
                decoration: const InputDecoration(labelText: 'Question Text *'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 12),
              Text('Instruction Answers', style: Theme.of(context).textTheme.titleSmall),
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
                          key: ValueKey('instruction-answer-$index-${_instructionAnswers[index]}'),
                          initialValue: _instructionAnswers[index],
                          decoration: const InputDecoration(labelText: 'Answer'),
                          onChanged: (value) {
                            _markDirty();
                            _instructionAnswers[index] = value;
                          },
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove answer',
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
                  label: const Text('Add Instruction Answer'),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text('Questions', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  SizedBox(
                    width: 160,
                    child: DsOutlinedButton(
                      label: 'Add Question',
                      onPressed: () {
                        setState(() {
                          _questions.add(
                            QuestionDraft(id: _nextQuestionId(), questionText: '', answers: ['']),
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
                  'No questions added yet.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                itemBuilder: (context, questionIndex) {
                  final question = _questions[questionIndex];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  key: ValueKey('question-$questionIndex-${question.id}'),
                                  initialValue: question.questionText,
                                  decoration: const InputDecoration(labelText: 'Question Text *'),
                                  validator: (value) => value == null || value.trim().isEmpty
                                      ? 'Required field'
                                      : null,
                                  onChanged: (value) {
                                    _markDirty();
                                    question.questionText = value;
                                  },
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remove question',
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
                          Text('Answers', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 8),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: question.answers.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, answerIndex) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      key: ValueKey(
                                          'question-$questionIndex-answer-$answerIndex-${question.answers[answerIndex]}'),
                                      initialValue: question.answers[answerIndex],
                                      decoration: const InputDecoration(labelText: 'Answer *'),
                                      validator: (value) => value == null || value.trim().isEmpty
                                          ? 'Required field'
                                          : null,
                                      onChanged: (value) {
                                        _markDirty();
                                        question.answers[answerIndex] = value;
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Remove answer',
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: question.answers.length <= 1
                                        ? null
                                        : () {
                                            setState(() {
                                              question.answers.removeAt(answerIndex);
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
                              label: const Text('Add Answer'),
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
