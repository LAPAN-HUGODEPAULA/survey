import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/models/survey_prompt_draft.dart';
import 'package:survey_builder/core/repositories/survey_prompt_repository.dart';
import 'package:survey_builder/features/survey/pages/survey_prompt_form_page.dart';

class SurveyPromptListPage extends StatefulWidget {
  const SurveyPromptListPage({
    super.key,
    this.repository,
    this.embedded = false,
  });

  final SurveyPromptRepository? repository;
  final bool embedded;

  @override
  State<SurveyPromptListPage> createState() => _SurveyPromptListPageState();
}

class _SurveyPromptListPageState extends State<SurveyPromptListPage> {
  late final SurveyPromptRepository _repository;
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;
  String? _error;
  DsFeedbackMessage? _feedback;
  List<SurveyPromptDraft> _prompts = <SurveyPromptDraft>[];
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? SurveyPromptRepository();
    _searchController.addListener(_handleSearchChanged);
    _load();
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    _repository.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    setState(() {
      _filter = _searchController.text.trim().toLowerCase();
    });
  }

  List<SurveyPromptDraft> get _filteredPrompts {
    if (_filter.isEmpty) {
      return _prompts;
    }
    return _prompts.where((prompt) {
      final name = prompt.name.toLowerCase();
      final key = prompt.promptKey.toLowerCase();
      return name.contains(_filter) || key.contains(_filter);
    }).toList();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prompts = await _repository.listPrompts();
      setState(() => _prompts = prompts);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openForm({SurveyPromptDraft? draft}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => SurveyPromptFormPage(initialDraft: draft?.copy()),
      ),
    );
    if (changed == true && mounted) {
      await _load();
      if (!mounted) {
        return;
      }
      showDsToast(
        context,
        feedback: const DsFeedbackMessage(
          severity: DsStatusType.success,
          title: 'Prompt salvo',
          message: 'Alterações salvas.',
        ),
      );
    }
  }

  Future<void> _deletePrompt(SurveyPromptDraft draft) async {
    final confirmed = await showDsDeleteConfirmationDialog(
      context: context,
      title: 'Excluir prompt?',
      content: 'Isso excluirá permanentemente "${draft.name}".',
    );
    if (!confirmed) {
      return;
    }

    try {
      await _repository.deletePrompt(draft.promptKey);
      if (!mounted) {
        return;
      }
      await _load();
      setState(() {
        _feedback = const DsFeedbackMessage(
          severity: DsStatusType.success,
          title: 'Prompt excluído',
          message: 'Prompt removido.',
        );
      });
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _feedback = DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Falha ao excluir prompt',
          message: 'Falha ao excluir prompt: $error',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = DsAdminCatalogShell<SurveyPromptDraft>(
      heading: 'Catálogo de prompts',
      createLabel: 'Criar prompt',
      isLoading: _loading,
      items: _filteredPrompts,
      searchController: _searchController,
      searchPlaceholder: 'Filtrar prompts por nome ou chave...',
      emptyMessage: _filter.isEmpty
          ? 'Nenhum prompt encontrado.'
          : 'Nenhum prompt corresponde ao filtro "$_filter".',
      error: _error,
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
      onRetry: _load,
      onRefresh: _load,
      onCreate: _openForm,
      itemBuilder: (BuildContext context, SurveyPromptDraft prompt) {
        return DsAdminCatalogItem(
          title: prompt.name,
          subtitle: prompt.promptKey,
          onEdit: () => _openForm(draft: prompt),
          onDelete: () => _deletePrompt(prompt),
        );
      },
    );

    if (widget.embedded) {
      return content;
    }

    return DsScaffold(
      title: 'Prompts reutilizáveis',
      subtitle: 'Gerencie prompts compartilhados dos fluxos de IA.',
      body: content,
    );
  }
}
