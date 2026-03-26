import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/models/survey_prompt_draft.dart';
import 'package:survey_builder/core/repositories/survey_prompt_repository.dart';

class SurveyPromptFormPage extends StatefulWidget {
  const SurveyPromptFormPage({
    super.key,
    this.initialDraft,
    this.repository,
  });

  final SurveyPromptDraft? initialDraft;
  final SurveyPromptRepository? repository;

  @override
  State<SurveyPromptFormPage> createState() => _SurveyPromptFormPageState();
}

class _SurveyPromptFormPageState extends State<SurveyPromptFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final SurveyPromptRepository _repository;
  late final bool _isEditing;

  late final TextEditingController _nameController;
  late final TextEditingController _keyController;
  late final TextEditingController _promptTextController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? SurveyPromptRepository();
    _isEditing = widget.initialDraft != null;
    final draft =
        widget.initialDraft ??
        SurveyPromptDraft(
          promptKey: '',
          name: '',
          promptText: '',
        );
    _nameController = TextEditingController(text: draft.name);
    _keyController = TextEditingController(text: draft.promptKey);
    _promptTextController = TextEditingController(text: draft.promptText);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _keyController.dispose();
    _promptTextController.dispose();
    _repository.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final state = _formKey.currentState;
    if (state == null || !state.validate()) {
      return;
    }

    setState(() => _saving = true);
    try {
      final draft = SurveyPromptDraft(
        promptKey: _keyController.text.trim().toLowerCase(),
        name: _nameController.text.trim(),
        promptText: _promptTextController.text.trim(),
      );
      if (_isEditing) {
        await _repository.updatePrompt(draft);
      } else {
        await _repository.createPrompt(draft);
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao salvar prompt: $error')));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar prompt' : 'Criar prompt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
                      onPressed: _saving ? null : () => Navigator.of(context).pop(),
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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do prompt *'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Campo obrigatório'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _keyController,
                readOnly: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Chave do prompt *',
                  helperText:
                      'Use letras minúsculas, números, ":" , "_" ou "-".',
                ),
                validator: (value) {
                  final normalized = value?.trim() ?? '';
                  if (normalized.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  if (!RegExp(r'^[a-z0-9:_-]+$').hasMatch(normalized)) {
                    return 'Formato inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _promptTextController,
                minLines: 10,
                maxLines: 18,
                decoration: const InputDecoration(
                  labelText: 'Texto do prompt *',
                  alignLabelWithHint: true,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Campo obrigatório'
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
