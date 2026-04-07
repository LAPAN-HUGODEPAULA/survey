import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/models/survey_prompt_draft.dart';
import 'package:survey_builder/core/repositories/survey_prompt_repository.dart';

class SurveyPromptFormPage extends StatefulWidget {
  const SurveyPromptFormPage({super.key, this.initialDraft, this.repository});

  final SurveyPromptDraft? initialDraft;
  final SurveyPromptRepository? repository;

  @override
  State<SurveyPromptFormPage> createState() => _SurveyPromptFormPageState();
}

class _SurveyPromptFormPageState extends State<SurveyPromptFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final SurveyPromptRepository _repository;
  late final bool _isEditing;
  late final TextEditingController _nameController;
  late final TextEditingController _keyController;
  late final TextEditingController _promptTextController;
  bool _saving = false;
  DsFeedbackMessage? _feedback;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? SurveyPromptRepository();
    _isEditing = widget.initialDraft != null;
    final draft =
        widget.initialDraft ??
        SurveyPromptDraft(promptKey: '', name: '', promptText: '');
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
        promptKey: DsKeyFieldSupport.normalizeKeyField(_keyController.text),
        name: DsKeyFieldSupport.normalizeTextField(_nameController.text),
        promptText: DsKeyFieldSupport.normalizeTextField(
          _promptTextController.text,
        ),
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
      setState(() {
        _feedback = DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Falha ao salvar prompt',
          message: 'Falha ao salvar prompt: $error',
        );
      });
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: _isEditing ? 'Editar prompt' : 'Criar prompt',
      subtitle:
          'Mantenha chaves estáveis e reutilize instruções compartilhadas.',
      scrollable: true,
      body: Form(
        key: _formKey,
        child: DsAdminFormShell(
          isSaving: _saving,
          onCancel: () => Navigator.of(context).pop(),
          onSave: _save,
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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do prompt *',
                ),
                validator: DsKeyFieldSupport.validateRequired,
              ),
              const SizedBox(height: 12),
              DsNormalizedKeyField(
                controller: _keyController,
                readOnly: _isEditing,
                label: 'Chave do prompt *',
                helperText: 'Use letras minúsculas, números, ":" , "_" ou "-".',
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
                validator: DsKeyFieldSupport.validateRequired,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
