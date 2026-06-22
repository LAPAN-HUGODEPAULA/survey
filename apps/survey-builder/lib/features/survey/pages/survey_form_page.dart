import 'dart:async';

import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/models/survey_draft.dart';
import 'package:survey_builder/core/repositories/persona_skill_repository.dart';
import 'package:survey_builder/core/repositories/survey_prompt_repository.dart';
import 'package:survey_builder/core/repositories/survey_repository.dart';
import 'package:survey_builder/features/survey/controllers/survey_form_controller.dart';
import 'package:survey_builder/features/survey/widgets/html_rich_text_editor.dart';
import 'package:survey_builder/features/survey/widgets/survey_form_sections.dart';

class SurveyFormPage extends StatefulWidget {
  const SurveyFormPage({
    super.key,
    this.initialDraft,
    this.repository,
    this.promptRepository,
    this.personaSkillRepository,
    this.onReturnToCatalog,
  });

  final SurveyDraft? initialDraft;
  final SurveyRepository? repository;
  final SurveyPromptRepository? promptRepository;
  final PersonaSkillRepository? personaSkillRepository;
  final VoidCallback? onReturnToCatalog;

  @override
  State<SurveyFormPage> createState() => _SurveyFormPageState();
}

class _SurveyFormPageState extends State<SurveyFormPage> {
  static const String _detailsSectionId = 'details';
  static const String _instructionsSectionId = 'instructions';
  static const String _promptSectionId = 'prompt';
  static const String _personaSectionId = 'persona';
  static const String _questionsSectionId = 'questions';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _detailsSectionKey = GlobalKey();
  final GlobalKey _instructionsSectionKey = GlobalKey();
  final GlobalKey _promptSectionKey = GlobalKey();
  final GlobalKey _personaSectionKey = GlobalKey();
  final GlobalKey _questionsSectionKey = GlobalKey();
  final _descriptionEditorKey = GlobalKey<HtmlRichTextEditorState>();
  final _instructionsPreambleEditorKey = GlobalKey<HtmlRichTextEditorState>();
  final _finalNotesEditorKey = GlobalKey<HtmlRichTextEditorState>();

  late final SurveyFormController _controller;
  String _currentSectionId = _detailsSectionId;

  @override
  void initState() {
    super.initState();
    _controller = SurveyFormController(
      initialDraft: widget.initialDraft,
      repository: widget.repository,
      promptRepository: widget.promptRepository,
      personaSkillRepository: widget.personaSkillRepository,
    )..addListener(_handleControllerChanged);
    _scrollController.addListener(_handleSectionScroll);
    unawaited(_controller.loadCatalogs());
    unawaited(_controller.restoreLocalDraft());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _handleSectionScroll();
      }
    });
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
      setState(() {
        // Rebuild when controller changes
      });
    }
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
    return switch (sectionId) {
      _detailsSectionId => 'Detalhes',
      _instructionsSectionId => 'Instruções',
      _promptSectionId => 'Prompt de IA',
      _personaSectionId => 'Configuração de persona',
      _questionsSectionId => 'Perguntas',
      _ => 'Detalhes',
    };
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

    for (final entry in _sectionAnchors) {
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
        .where((entry) => entry.key == sectionId)
        .map((entry) => entry.value.currentContext)
        .firstWhere((context) => context != null, orElse: () => null);
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

  Future<void> _save() async {
    final descriptionHtml =
        await _descriptionEditorKey.currentState?.getHtml() ??
        _controller.descriptionHtml;
    final preambleHtml =
        await _instructionsPreambleEditorKey.currentState?.getHtml() ??
        _controller.instructionsPreambleHtml;
    final finalNotesHtml =
        await _finalNotesEditorKey.currentState?.getHtml() ??
        _controller.finalNotesHtml;
    final saved = await _controller.save(
      formState: _formKey.currentState,
      description: descriptionHtml,
      preamble: preambleHtml,
      finalNotes: finalNotesHtml,
    );
    if (saved && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _confirmCancel() async {
    if (!_controller.isDirty) {
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
    await _controller.clearLocalDraft();
    navigator.pop();
  }

  List<DsBreadcrumbItem> _buildBreadcrumbs(bool isEditing) {
    return [
      DsBreadcrumbItem(
        label: 'Questionários',
        onPressed: _controller.saving ? null : _returnToCatalog,
      ),
      DsBreadcrumbItem(
        label: isEditing ? 'Editar questionário' : 'Criar questionário',
        isCurrent: true,
      ),
    ];
  }

  void _returnToCatalog() {
    if (widget.onReturnToCatalog != null) {
      widget.onReturnToCatalog!();
      return;
    }
    Navigator.of(context).maybePop();
  }

  Widget? _buildDraftStatusFeedback() {
    if (_controller.saving) {
      return const DsInlineMessage(
        feedback: DsFeedbackMessage(
          severity: DsStatusType.info,
          title: 'Salvando alterações',
          message: 'Publicando questionário e sincronizando dados.',
        ),
      );
    }
    if (_controller.isDirty) {
      final message = _controller.lastLocalDraftSavedAt == null
          ? 'Alterações ainda não publicadas. Rascunho local preservado automaticamente.'
          : 'Alterações ainda não publicadas. Último rascunho salvo às ${_controller.formatLocalDraftTime(_controller.lastLocalDraftSavedAt!)}.';
      return DsInlineMessage(
        feedback: DsFeedbackMessage(
          severity: DsStatusType.warning,
          title: 'Alterações não salvas',
          message: message,
        ),
      );
    }
    if (_controller.restoredLocalDraft) {
      final suffix = _controller.lastLocalDraftSavedAt == null
          ? ''
          : ' às ${_controller.formatLocalDraftTime(_controller.lastLocalDraftSavedAt!)}';
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
    final isEditing = _controller.isEditing;
    final draftStatusFeedback = _buildDraftStatusFeedback();
    return DsScaffold(
      title: isEditing ? 'Editar questionário' : 'Criar questionário',
      subtitle: 'Configure conteúdo, instruções, prompts e perguntas.',
      breadcrumbs: _buildBreadcrumbs(isEditing),
      onBack: _controller.saving ? null : _confirmCancel,
      backLabel: 'Voltar',
      maxBodyWidth: 1920,
      scrollable: false,
      body: Form(
        key: _formKey,
        child: DsAdminFormShell(
          isSaving: _controller.saving,
          hasUnsavedChanges: _controller.isDirty,
          onCancel: _controller.saving ? () { return; } : _confirmCancel,
          onSave: _controller.saving ? () { return; } : _save,
          scrollController: _scrollController,
          stickyFooter: const SizedBox.shrink(),
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
              if (_controller.validationItems.isNotEmpty) ...[
                DsValidationSummary(
                  items: _controller.validationItems,
                  description:
                      'Revise os itens abaixo e os campos destacados antes de salvar.',
                ),
                const SizedBox(height: 16),
              ],
              if (draftStatusFeedback != null) ...[
                draftStatusFeedback,
                const SizedBox(height: 16),
              ],
              SurveyDetailsSection(
                controller: _controller,
                sectionKey: _detailsSectionKey,
                descriptionEditorKey: _descriptionEditorKey,
              ),
              const SizedBox(height: 16),
              SurveyInstructionsSection(
                controller: _controller,
                sectionKey: _instructionsSectionKey,
                preambleEditorKey: _instructionsPreambleEditorKey,
                finalNotesEditorKey: _finalNotesEditorKey,
              ),
              const SizedBox(height: 16),
              SurveyAiConfigSection(
                controller: _controller,
                promptSectionKey: _promptSectionKey,
                personaSectionKey: _personaSectionKey,
              ),
              const SizedBox(height: 16),
              SurveyQuestionsSection(
                controller: _controller,
                sectionKey: _questionsSectionKey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
