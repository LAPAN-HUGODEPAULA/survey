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
  static const String _detailsSectionId = 'details';
  static const String _instructionsSectionId = 'instructions';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _detailsSectionKey = GlobalKey();
  final GlobalKey _instructionsSectionKey = GlobalKey();

  late final SurveyPromptRepository _repository;
  late final bool _isEditing;
  late final TextEditingController _nameController;
  late final TextEditingController _keyController;
  late final TextEditingController _promptTextController;
  bool _saving = false;
  bool _isDirty = false;
  bool _hasSubmitted = false;
  DsFeedbackMessage? _feedback;
  String _currentSectionId = _detailsSectionId;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? SurveyPromptRepository();
    _isEditing = widget.initialDraft != null;
    final draft =
        widget.initialDraft ??
        SurveyPromptDraft(promptKey: '', name: '', promptText: '');
    _nameController = TextEditingController(text: draft.name)
      ..addListener(_handleFieldMutation);
    _keyController = TextEditingController(text: draft.promptKey)
      ..addListener(_handleFieldMutation);
    _promptTextController = TextEditingController(text: draft.promptText)
      ..addListener(_handleFieldMutation);

    _scrollController.addListener(_handleSectionScroll);
  }

  @override
  void dispose() {
    _nameController.removeListener(_handleFieldMutation);
    _keyController.removeListener(_handleFieldMutation);
    _promptTextController.removeListener(_handleFieldMutation);
    _nameController.dispose();
    _keyController.dispose();
    _promptTextController.dispose();
    _scrollController.removeListener(_handleSectionScroll);
    _scrollController.dispose();
    _repository.dispose();
    super.dispose();
  }

  void _handleFieldMutation() {
    if (!_isDirty) {
      setState(() => _isDirty = true);
    }
  }

  void _handleSectionScroll() {
    final activationOffset = 180.0;
    String nextSectionId = _detailsSectionId;

    final instructionsBox = _instructionsSectionKey.currentContext?.findRenderObject() as RenderBox?;

    if (instructionsBox != null) {
      final top = instructionsBox.localToGlobal(Offset.zero).dy;
      if (top <= activationOffset) {
        nextSectionId = _instructionsSectionId;
      }
    }

    if (nextSectionId != _currentSectionId && mounted) {
      setState(() => _currentSectionId = nextSectionId);
    }
  }

  void _jumpToSection(String sectionId) {
    final targetKey = sectionId == _detailsSectionId ? _detailsSectionKey : _instructionsSectionKey;
    final context = targetKey.currentContext;
    if (context != null) {
      setState(() => _currentSectionId = sectionId);
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  List<DsValidationSummaryItem> _buildValidationItems() {
    final items = <DsValidationSummaryItem>[];
    void addItem(String label, String? message, GlobalKey targetKey) {
      if (message != null && message.isNotEmpty) {
        items.add(DsValidationSummaryItem(
          label: label,
          message: message,
          onTap: () => Scrollable.ensureVisible(
            targetKey.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.1,
          ),
        ));
      }
    }

    addItem('Nome do prompt', DsKeyFieldSupport.validateRequired(_nameController.text), _detailsSectionKey);
    addItem('Chave do prompt', DsKeyFieldSupport.validateRequired(_keyController.text), _detailsSectionKey);
    addItem('Texto do prompt', DsKeyFieldSupport.validateRequired(_promptTextController.text), _instructionsSectionKey);

    return items;
  }

  Future<void> _save() async {
    setState(() => _hasSubmitted = true);
    final state = _formKey.currentState;
    final validationItems = _buildValidationItems();

    if (state == null || !state.validate() || validationItems.isNotEmpty) {
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
    final validationItems = _hasSubmitted ? _buildValidationItems() : <DsValidationSummaryItem>[];

    return DsScaffold(
      title: _isEditing ? 'Editar prompt' : 'Criar prompt',
      subtitle: 'Mantenha chaves estáveis e reutilize instruções.',
      breadcrumbs: [
        DsBreadcrumbItem(
          label: 'Prompts reutilizáveis',
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsBreadcrumbItem(
          label: _isEditing ? 'Editar prompt' : 'Criar prompt',
          isCurrent: true,
        ),
      ],
      onBack: () => Navigator.of(context).pop(),
      backLabel: 'Voltar para prompts',
      scrollable: false,
      body: Form(
        key: _formKey,
        child: DsAdminFormShell(
          isSaving: _saving,
          hasUnsavedChanges: _isDirty,
          onCancel: () => Navigator.of(context).pop(),
          onSave: _save,
          scrollController: _scrollController,
          stickyFooter: const SizedBox.shrink(),
          sectionalNav: DsSectionalNav(
            items: [
              DsSectionalNavItem(label: 'Detalhes', targetKey: _detailsSectionKey),
              DsSectionalNavItem(label: 'Instruções', targetKey: _instructionsSectionKey),
            ],
            activeItem: _currentSectionId == _detailsSectionId
                ? DsSectionalNavItem(label: 'Detalhes', targetKey: _detailsSectionKey)
                : DsSectionalNavItem(label: 'Instruções', targetKey: _instructionsSectionKey),
            onItemTap: (item) => _jumpToSection(item.targetKey == _detailsSectionKey ? _detailsSectionId : _instructionsSectionId),
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
              if (validationItems.isNotEmpty) ...[
                DsValidationSummary(
                  items: validationItems,
                  description: 'Revise os campos destacados antes de salvar.',
                ),
                const SizedBox(height: 16),
              ],
              DsSection(
                key: _detailsSectionKey,
                title: 'Detalhes do prompt',
                child: Column(
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
                  ],
                ),
              ),
              const SizedBox(height: 24),
              DsSection(
                key: _instructionsSectionKey,
                title: 'Texto do prompt',
                child: TextFormField(
                  controller: _promptTextController,
                  minLines: 15,
                  maxLines: 25,
                  decoration: const InputDecoration(
                    labelText: 'Texto do prompt *',
                    alignLabelWithHint: true,
                  ),
                  validator: DsKeyFieldSupport.validateRequired,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
