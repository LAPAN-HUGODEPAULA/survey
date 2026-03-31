import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/models/survey_draft.dart';
import 'package:survey_builder/core/repositories/survey_repository.dart';
import 'package:survey_builder/core/services/file_download.dart';
import 'package:survey_builder/features/survey/pages/persona_skill_list_page.dart';
import 'package:survey_builder/features/survey/pages/survey_form_page.dart';
import 'package:survey_builder/features/survey/pages/survey_prompt_list_page.dart';

class SurveyListPage extends StatefulWidget {
  const SurveyListPage({super.key, this.repository});

  final SurveyRepository? repository;

  @override
  State<SurveyListPage> createState() => _SurveyListPageState();
}

class _SurveyListPageState extends State<SurveyListPage> {
  late final SurveyRepository _repo;
  bool _loading = true;
  bool _exporting = false;
  String? _error;
  List<SurveyDraft> _surveys = [];

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? SurveyRepository();
    _load();
  }

  @override
  void dispose() {
    _repo.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.listSurveys();
      setState(() {
        _surveys = data;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openForm({SurveyDraft? draft}) async {
    SurveyDraft? resolvedDraft = draft;
    if (draft?.id != null && draft!.id!.isNotEmpty) {
      try {
        resolvedDraft = await _repo.fetchSurvey(draft.id!);
      } catch (error) {
        if (!mounted) return;
        _showSnack('Falha ao carregar detalhes do questionário: $error');
        return;
      }
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SurveyFormPage(initialDraft: resolvedDraft),
      ),
    );
    if (!mounted) return;
    await _load();
  }

  Future<void> _confirmDelete(SurveyDraft draft) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DsDialog(
        title: 'Excluir questionário?',
        content: Text(
          'Isso excluirá permanentemente "${draft.surveyDisplayName}".',
        ),
        actions: [
          DsTextButton(
            label: 'Cancelar',
            onPressed: () => Navigator.pop(context, false),
          ),
          DsFilledButton(
            label: 'Excluir',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (draft.id == null) return;
    try {
      await _repo.deleteSurvey(draft.id!);
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao excluir: $error')));
    }
  }

  Future<void> _exportSurveys() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final payload = await _repo.exportSurveys();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      downloadTextFile('exportacao_questionarios_$timestamp.json', payload);
    } catch (error) {
      _showSnack('Falha ao exportar: $error');
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  SurveyDraft _emptyDraft() {
    final now = DateTime.now();
    return SurveyDraft(
      surveyDisplayName: '',
      surveyName: '',
      surveyDescription: '',
      creatorId: '',
      createdAt: now,
      modifiedAt: now,
      instructions: InstructionsDraft(
        preamble: '',
        questionText: '',
        answers: [''],
      ),
      questions: [],
      finalNotes: '',
      prompt: null,
    );
  }

  String _plainSummary(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: 'Construtor de Questionários',
      useSafeArea: true,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Questionários',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    DsFilledButton(
                      label: 'Criar questionário',
                      onPressed: () => _openForm(draft: _emptyDraft()),
                    ),
                    DsOutlinedButton(
                      label: 'Gerenciar prompts',
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SurveyPromptListPage(),
                          ),
                        );
                      },
                    ),
                    DsOutlinedButton(
                      label: 'Gerenciar personas',
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const PersonaSkillListPage(),
                          ),
                        );
                      },
                    ),
                    DsOutlinedButton(
                      label: _exporting
                          ? 'Exportando...'
                          : 'Exportar questionários',
                      onPressed: _exporting ? null : _exportSurveys,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const DsLoading()
                  : _error != null
                  ? DsError(message: _error!, onRetry: _load)
                  : _surveys.isEmpty
                  ? const DsEmpty(message: 'Nenhum questionário encontrado.')
                  : ListView.separated(
                      itemCount: _surveys.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final survey = _surveys[index];
                        return Card(
                          elevation: 1,
                          child: ListTile(
                            title: Text(survey.surveyDisplayName),
                            subtitle: Text(
                              _plainSummary(survey.surveyDescription),
                            ),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  tooltip: 'Editar',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _openForm(draft: survey),
                                ),
                                IconButton(
                                  tooltip: 'Excluir',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _confirmDelete(survey),
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
