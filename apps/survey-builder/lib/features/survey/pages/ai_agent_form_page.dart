import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/models/ai_agent_draft.dart';
import 'package:survey_builder/core/repositories/ai_agent_repository.dart';
import 'package:survey_builder/features/survey/controllers/ai_agent_form_controller.dart';
import 'package:survey_builder/features/survey/widgets/ai_agent_form_sections.dart';

class AIAgentFormPage extends StatefulWidget {
  const AIAgentFormPage({super.key, this.initialDraft, this.repository});

  final AIAgentDraft? initialDraft;
  final AIAgentRepository? repository;

  @override
  State<AIAgentFormPage> createState() => _AIAgentFormPageState();
}

class _AIAgentFormPageState extends State<AIAgentFormPage> {
  static const String _detailsSectionId = 'details';
  static const String _capabilitiesSectionId = 'capabilities';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _detailsSectionKey = GlobalKey();
  final GlobalKey _capabilitiesSectionKey = GlobalKey();

  late final AIAgentFormController _controller;
  String _currentSectionId = _detailsSectionId;

  @override
  void initState() {
    super.initState();
    _controller = AIAgentFormController(
      initialDraft: widget.initialDraft,
      repository: widget.repository,
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
    final capabilitiesBox =
        _capabilitiesSectionKey.currentContext?.findRenderObject()
            as RenderBox?;
    final nextSectionId =
        capabilitiesBox != null &&
            capabilitiesBox.localToGlobal(Offset.zero).dy <= 180
        ? _capabilitiesSectionId
        : _detailsSectionId;
    if (nextSectionId != _currentSectionId && mounted) {
      setState(() => _currentSectionId = nextSectionId);
    }
  }

  void _jumpToSection(String sectionId) {
    final targetKey = sectionId == _detailsSectionId
        ? _detailsSectionKey
        : _capabilitiesSectionKey;
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
          )
        : <DsValidationSummaryItem>[];
    final detailsItem = DsSectionalNavItem(
      label: 'Detalhes',
      targetKey: _detailsSectionKey,
    );
    final capabilitiesItem = DsSectionalNavItem(
      label: 'Capacidades',
      targetKey: _capabilitiesSectionKey,
    );

    return DsScaffold(
      title: _controller.isEditing
          ? 'Editar agente de IA'
          : 'Criar agente de IA',
      subtitle:
          'Configure endpoints e modelos reutilizados pelos access points.',
      breadcrumbs: [
        DsBreadcrumbItem(
          label: 'Agentes de IA',
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsBreadcrumbItem(
          label: _controller.isEditing ? 'Editar agente' : 'Criar agente',
          isCurrent: true,
        ),
      ],
      onBack: () => Navigator.of(context).pop(),
      backLabel: 'Voltar para agentes',
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
            items: [detailsItem, capabilitiesItem],
            activeItem: _currentSectionId == _detailsSectionId
                ? detailsItem
                : capabilitiesItem,
            onItemTap: (item) => _jumpToSection(
              item.targetKey == _detailsSectionKey
                  ? _detailsSectionId
                  : _capabilitiesSectionId,
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
              AIAgentDetailsSection(
                controller: _controller,
                sectionKey: _detailsSectionKey,
              ),
              const SizedBox(height: 24),
              AIAgentCapabilitiesSection(
                controller: _controller,
                sectionKey: _capabilitiesSectionKey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
