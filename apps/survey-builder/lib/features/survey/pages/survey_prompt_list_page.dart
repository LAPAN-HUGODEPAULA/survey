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
  List<SurveyPromptDraft> _prompts = [];

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
        builder: (_) => SurveyPromptFormPage(
          initialDraft: draft?.copy(),
        ),
      ),
    );
    if (changed == true && mounted) {
      await _load();
    }
  }

  Future<void> _deletePrompt(SurveyPromptDraft draft) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DsDialog(
        title: 'Excluir prompt?',
        content: Text('Isso excluirá permanentemente "${draft.name}".'),
        actions: [
          DsTextButton(
            label: 'Cancelar',
            onPressed: () => Navigator.of(context).pop(false),
          ),
          DsFilledButton(
            label: 'Excluir',
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao excluir prompt: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      appBar: AppBar(
        title: const Text('Prompts reutilizáveis'),
      ),
      actions: [
        IconButton(
          tooltip: 'Atualizar',
          icon: const Icon(Icons.refresh),
          onPressed: _loading ? null : _load,
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    'Catálogo de prompts',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(width: 16),
                DsFilledButton(
                  label: 'Criar prompt',
                  onPressed: _openForm,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const DsLoading()
                  : _error != null
                  ? DsError(message: _error!, onRetry: _load)
                  : _prompts.isEmpty
                  ? const DsEmpty(message: 'Nenhum prompt encontrado.')
                  : ListView.separated(
                      itemCount: _prompts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final prompt = _prompts[index];
                        return Card(
                          child: ListTile(
                            title: Text(prompt.name),
                            subtitle: Text(prompt.promptKey),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  tooltip: 'Editar',
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _openForm(draft: prompt),
                                ),
                                IconButton(
                                  tooltip: 'Excluir',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _deletePrompt(prompt),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
