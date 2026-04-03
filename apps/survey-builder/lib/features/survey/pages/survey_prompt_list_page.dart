import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/models/survey_prompt_draft.dart';
import 'package:survey_builder/core/repositories/survey_prompt_repository.dart';
import 'package:survey_builder/features/survey/pages/survey_prompt_form_page.dart';

class SurveyPromptListPage extends StatefulWidget {
  const SurveyPromptListPage({super.key, this.repository});

  final SurveyPromptRepository? repository;

  @override
  State<SurveyPromptListPage> createState() => _SurveyPromptListPageState();
}

class _SurveyPromptListPageState extends State<SurveyPromptListPage> {
  late final SurveyPromptRepository _repository;
  bool _loading = true;
  String? _error;
  List<SurveyPromptDraft> _prompts = <SurveyPromptDraft>[];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? SurveyPromptRepository();
    _load();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
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
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao excluir prompt: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: 'Prompts reutilizaveis',
      subtitle: 'Gerencie os prompts compartilhados usados pelos fluxos de IA.',
      body: DsAdminCatalogShell<SurveyPromptDraft>(
        heading: 'Catálogo de prompts',
        createLabel: 'Criar prompt',
        isLoading: _loading,
        items: _prompts,
        emptyMessage: 'Nenhum prompt encontrado.',
        error: _error,
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
      ),
    );
  }
}
