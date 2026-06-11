import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/models/agent_access_point_draft.dart';
import 'package:survey_builder/core/repositories/agent_access_point_repository.dart';
import 'package:survey_builder/features/survey/controllers/agent_access_point_form_controller.dart';
import 'package:survey_builder/features/survey/widgets/agent_access_point_form_sections.dart';

class AgentAccessPointFormPage extends StatefulWidget {
  const AgentAccessPointFormPage({
    super.key,
    this.initialDraft,
    this.repository,
  });

  final AgentAccessPointDraft? initialDraft;
  final AgentAccessPointRepository? repository;

  @override
  State<AgentAccessPointFormPage> createState() =>
      _AgentAccessPointFormPageState();
}

class _AgentAccessPointFormPageState extends State<AgentAccessPointFormPage> {
  static const String _routingSectionId = 'routing';
  static const String _assignmentSectionId = 'assignment';
  static const String _aiSectionId = 'ai';
  static const String _orchestratorSectionId = 'orchestrator';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _routingSectionKey = GlobalKey();
  final GlobalKey _assignmentSectionKey = GlobalKey();
  final GlobalKey _aiSectionKey = GlobalKey();
  final GlobalKey _orchestratorSectionKey = GlobalKey();

  late final AgentAccessPointFormController _controller;
  String _currentSectionId = _routingSectionId;

  @override
  void initState() {
    super.initState();
    _controller = AgentAccessPointFormController(
      initialDraft: widget.initialDraft,
      repository: widget.repository,
    )..addListener(_handleControllerChanged);
    _scrollController.addListener(_handleSectionScroll);
    _controller.loadCatalogs();
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
    var nextSectionId = _routingSectionId;

    final orchestratorBox =
        _orchestratorSectionKey.currentContext?.findRenderObject()
            as RenderBox?;
    if (orchestratorBox != null &&
        orchestratorBox.localToGlobal(Offset.zero).dy <= activationOffset) {
      nextSectionId = _orchestratorSectionId;
    }

    if (nextSectionId == _routingSectionId) {
      final aiBox =
          _aiSectionKey.currentContext?.findRenderObject() as RenderBox?;
      if (aiBox != null &&
          aiBox.localToGlobal(Offset.zero).dy <= activationOffset) {
        nextSectionId = _aiSectionId;
      }
    }

    if (nextSectionId == _routingSectionId) {
      final assignmentBox =
          _assignmentSectionKey.currentContext?.findRenderObject()
              as RenderBox?;
      if (assignmentBox != null &&
          assignmentBox.localToGlobal(Offset.zero).dy <= activationOffset) {
        nextSectionId = _assignmentSectionId;
      }
    }

    if (nextSectionId != _currentSectionId && mounted) {
      setState(() => _currentSectionId = nextSectionId);
    }
  }

  void _jumpToSection(String sectionId) {
    final targetKey = switch (sectionId) {
      _routingSectionId => _routingSectionKey,
      _assignmentSectionId => _assignmentSectionKey,
      _aiSectionId => _aiSectionKey,
      _ => _orchestratorSectionKey,
    };
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
      routingSectionKey: _routingSectionKey,
      assignmentSectionKey: _assignmentSectionKey,
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
            routingSectionKey: _routingSectionKey,
            assignmentSectionKey: _assignmentSectionKey,
          )
        : <DsValidationSummaryItem>[];
    final routingItem = DsSectionalNavItem(
      label: 'Roteamento',
      targetKey: _routingSectionKey,
    );
    final assignmentItem = DsSectionalNavItem(
      label: 'Vinculações',
      targetKey: _assignmentSectionKey,
    );
    final aiItem = DsSectionalNavItem(
      label: 'Modelos e Provedores',
      targetKey: _aiSectionKey,
    );
    final orchestratorItem = DsSectionalNavItem(
      label: 'Prompts do Orchestrator',
      targetKey: _orchestratorSectionKey,
    );

    return DsScaffold(
      title: _controller.isEditing
          ? 'Editar ponto de acesso'
          : 'Criar ponto de acesso',
      subtitle: 'Mapeie um fluxo de runtime para prompt, persona e perfil.',
      breadcrumbs: [
        DsBreadcrumbItem(
          label: 'Pontos de acesso',
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsBreadcrumbItem(
          label: _controller.isEditing
              ? 'Editar ponto de acesso'
              : 'Criar ponto de acesso',
          isCurrent: true,
        ),
      ],
      onBack: () => Navigator.of(context).pop(),
      backLabel: 'Voltar para pontos de acesso',
      maxBodyWidth: 1920,
      body: _controller.loadingCatalogs
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: DsAdminFormShell(
                isSaving: _controller.saving,
                hasUnsavedChanges: _controller.isDirty,
                onCancel: () => Navigator.of(context).pop(),
                onSave: _save,
                scrollController: _scrollController,
                stickyFooter: const SizedBox.shrink(),
                sectionalNav: DsSectionalNav(
                  items: [
                    routingItem,
                    assignmentItem,
                    aiItem,
                    orchestratorItem,
                  ],
                  activeItem: switch (_currentSectionId) {
                    _routingSectionId => routingItem,
                    _assignmentSectionId => assignmentItem,
                    _aiSectionId => aiItem,
                    _ => orchestratorItem,
                  },
                  onItemTap: (item) => _jumpToSection(
                    item.targetKey == _routingSectionKey
                        ? _routingSectionId
                        : item.targetKey == _assignmentSectionKey
                        ? _assignmentSectionId
                        : item.targetKey == _aiSectionKey
                        ? _aiSectionId
                        : _orchestratorSectionId,
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
                        description:
                            'Revise os campos destacados antes de salvar.',
                      ),
                      const SizedBox(height: 16),
                    ],
                    AgentAccessPointRoutingSection(
                      controller: _controller,
                      sectionKey: _routingSectionKey,
                    ),
                    const SizedBox(height: 24),
                    AgentAccessPointAssignmentSection(
                      controller: _controller,
                      sectionKey: _assignmentSectionKey,
                    ),
                    const SizedBox(height: 24),
                    AgentAccessPointAiConfigSection(
                      controller: _controller,
                      sectionKey: _aiSectionKey,
                    ),
                    const SizedBox(height: 24),
                    AgentAccessPointOrchestratorSection(
                      controller: _controller,
                      sectionKey: _orchestratorSectionKey,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
