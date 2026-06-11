import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/models/persona_skill_draft.dart';
import 'package:survey_builder/core/repositories/persona_skill_repository.dart';
import 'package:survey_builder/features/survey/controllers/persona_skill_form_controller.dart';
import 'package:survey_builder/features/survey/widgets/persona_skill_form_sections.dart';

class PersonaSkillFormPage extends StatefulWidget {
  const PersonaSkillFormPage({
    super.key,
    this.initialDraft,
    this.repository,
    this.existingSkills = const <PersonaSkillDraft>[],
  });

  final PersonaSkillDraft? initialDraft;
  final PersonaSkillRepository? repository;
  final List<PersonaSkillDraft> existingSkills;

  @override
  State<PersonaSkillFormPage> createState() => _PersonaSkillFormPageState();
}

class _PersonaSkillFormPageState extends State<PersonaSkillFormPage> {
  static const String _detailsSectionId = 'details';
  static const String _instructionsSectionId = 'instructions';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _detailsSectionKey = GlobalKey();
  final GlobalKey _instructionsSectionKey = GlobalKey();

  late final PersonaSkillFormController _controller;
  String _currentSectionId = _detailsSectionId;

  @override
  void initState() {
    super.initState();
    _controller = PersonaSkillFormController(
      initialDraft: widget.initialDraft,
      repository: widget.repository,
      existingSkills: widget.existingSkills,
    )..addListener(_handleControllerChanged);
    _scrollController.addListener(_handleSectionScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _controller.dispose();
    _scrollController.removeListener(_handleSectionScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleSectionScroll() {
    final activationOffset = 180.0;
    String nextSectionId = _detailsSectionId;
    final instructionsBox =
        _instructionsSectionKey.currentContext?.findRenderObject()
            as RenderBox?;

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
    final targetKey = sectionId == _detailsSectionId
        ? _detailsSectionKey
        : _instructionsSectionKey;
    final context = targetKey.currentContext;
    if (context == null) {
      return;
    }
    setState(() => _currentSectionId = sectionId);
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }

  Future<void> _save() async {
    final validationItems = _controller.buildValidationItems(
      detailsSectionKey: _detailsSectionKey,
      instructionsSectionKey: _instructionsSectionKey,
    );
    final saved = await _controller.save(
      formState: _formKey.currentState,
      validationItems: validationItems,
    );
    if (saved && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final validationItems = _controller.hasSubmitted
        ? _controller.buildValidationItems(
            detailsSectionKey: _detailsSectionKey,
            instructionsSectionKey: _instructionsSectionKey,
          )
        : <DsValidationSummaryItem>[];
    final detailsItem = DsSectionalNavItem(
      label: 'Detalhes',
      targetKey: _detailsSectionKey,
    );
    final instructionsItem = DsSectionalNavItem(
      label: 'Instruções',
      targetKey: _instructionsSectionKey,
    );

    return DsScaffold(
      title: _controller.isEditing ? 'Editar persona' : 'Criar persona',
      subtitle: 'Configure personas e perfis de saída reutilizáveis.',
      breadcrumbs: [
        DsBreadcrumbItem(
          label: 'Personas de saída',
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsBreadcrumbItem(
          label: _controller.isEditing ? 'Editar persona' : 'Criar persona',
          isCurrent: true,
        ),
      ],
      onBack: () => Navigator.of(context).pop(),
      backLabel: 'Voltar para personas',
      maxBodyWidth: 1920,
      scrollable: false,
      body: Form(
        key: _formKey,
        child: DsAdminFormShell(
          isSaving: _controller.saving,
          hasUnsavedChanges: _controller.isDirty,
          onCancel: () => Navigator.of(context).pop(),
          onSave: _save,
          scrollController: _scrollController,
          stickyFooter: const SizedBox.shrink(),
          sectionalNav: DsSectionalNav(
            items: [detailsItem, instructionsItem],
            activeItem: _currentSectionId == _detailsSectionId
                ? detailsItem
                : instructionsItem,
            onItemTap: (item) => _jumpToSection(
              item.targetKey == _detailsSectionKey
                  ? _detailsSectionId
                  : _instructionsSectionId,
            ),
          ),
          feedback: _controller.feedback == null
              ? null
              : DsMessageBanner(
                  feedback: DsFeedbackMessage(
                    severity: _controller.feedback!.severity,
                    title: _controller.feedback!.title,
                    message: _controller.feedback!.message,
                    dismissible: true,
                    onDismiss: _controller.clearFeedback,
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
              PersonaSkillDetailsSection(
                controller: _controller,
                sectionKey: _detailsSectionKey,
              ),
              const SizedBox(height: 24),
              PersonaSkillInstructionsSection(
                controller: _controller,
                sectionKey: _instructionsSectionKey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
