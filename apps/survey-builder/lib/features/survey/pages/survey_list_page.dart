import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/auth/builder_auth_controller.dart';
import 'package:survey_builder/core/models/survey_draft.dart';
import 'package:survey_builder/core/repositories/survey_repository.dart';
import 'package:survey_builder/core/services/file_download.dart';
import 'package:survey_builder/features/survey/pages/agent_access_point_list_page.dart';
import 'package:survey_builder/features/survey/pages/persona_skill_list_page.dart';
import 'package:survey_builder/features/survey/pages/survey_form_page.dart';
import 'package:survey_builder/features/survey/pages/survey_prompt_list_page.dart';

class SurveyListPage extends StatefulWidget {
  const SurveyListPage({super.key, this.repository, this.authController});

  final SurveyRepository? repository;
  final BuilderAuthController? authController;

  @override
  State<SurveyListPage> createState() => _SurveyListPageState();
}

class _SurveyListPageState extends State<SurveyListPage> {
  late final SurveyRepository _repo;
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;
  bool _exporting = false;
  String? _error;
  DsFeedbackMessage? _feedback;
  List<SurveyDraft> _surveys = [];
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? SurveyRepository();
    _searchController.addListener(_handleSearchChanged);
    _load();
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    _repo.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    setState(() {
      _filter = _searchController.text.trim().toLowerCase();
    });
  }

  List<SurveyDraft> get _filteredSurveys {
    if (_filter.isEmpty) {
      return _surveys;
    }
    return _surveys.where((survey) {
      final title = survey.surveyDisplayName.toLowerCase();
      final name = survey.surveyName.toLowerCase();
      final description = _plainSummary(survey.surveyDescription).toLowerCase();
      return title.contains(_filter) ||
          name.contains(_filter) ||
          description.contains(_filter);
    }).toList();
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
        setState(() {
          _feedback = DsFeedbackMessage(
            severity: DsStatusType.error,
            title: 'Não foi possível abrir o questionário',
            message: 'Falha ao carregar detalhes do questionário: $error',
          );
        });
        return;
      }
    }
    if (!mounted) return;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => SurveyFormPage(initialDraft: resolvedDraft),
      ),
    );
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    if (changed == true) {
      showDsToast(
        context,
        feedback: const DsFeedbackMessage(
          severity: DsStatusType.success,
          title: 'Questionário salvo',
          message: 'Alterações salvas.',
        ),
      );
    }
  }

  Future<void> _confirmDelete(SurveyDraft draft) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DsDialog(
        severity: DsStatusType.warning,
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
            label: 'Excluir questionário',
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
      if (mounted) {
        setState(() {
          _feedback = const DsFeedbackMessage(
            severity: DsStatusType.success,
            title: 'Questionário excluído',
            message: 'Questionário removido.',
          );
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _feedback = DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Falha ao excluir questionário',
          message: 'Falha ao excluir: $error',
        );
      });
    }
  }

  Future<void> _exportSurveys() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final payload = await _repo.exportSurveys();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      downloadTextFile('exportacao_questionarios_$timestamp.json', payload);
      if (mounted) {
        setState(() {
          _feedback = const DsFeedbackMessage(
            severity: DsStatusType.success,
            title: 'Exportação concluída',
            message: 'Arquivo de exportação pronto.',
          );
        });
      }
    } catch (error) {
      setState(() {
        _feedback = DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Falha ao exportar',
          message: 'Falha ao exportar: $error',
        );
      });
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
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

  String _questionLabelPreview(SurveyDraft survey) {
    if (survey.questions.isEmpty) {
      return 'sem perguntas';
    }
    final labels = survey.questions
        .map((question) {
          final trimmed = question.label.trim();
          return trimmed.isEmpty ? 'Q${question.id}' : trimmed;
        })
        .take(3)
        .toList(growable: false);
    return labels.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: 'Construtor de Questionários',
      subtitle: 'Gerencie questionários, prompts e personas.',
      showAmbientGreeting: true,
      userName: widget.authController?.profile?.fullName,
      useSafeArea: true,
      actions: [
        IconButton(
          tooltip: 'Encerrar sessão',
          onPressed: widget.authController == null
              ? null
              : () => widget.authController!.logout(),
          icon: const Icon(Icons.logout),
        ),
      ],
      body: DsAdminCatalogShell<SurveyDraft>(
        heading: 'Questionários',
        createLabel: 'Criar questionário',
        isLoading: _loading,
        error: _error,
        onRetry: _load,
        onRefresh: _load,
        onCreate: () => _openForm(draft: _emptyDraft()),
        searchController: _searchController,
        searchPlaceholder: 'Filtrar questionários por título ou descrição...',
        emptyMessage: _filter.isEmpty
            ? 'Nenhum questionário encontrado.'
            : 'Nenhum questionário corresponde ao filtro "$_filter".',
        items: _filteredSurveys,
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
        itemBuilder: (context, survey) {
          return ListTile(
            title: Text(survey.surveyDisplayName),
            subtitle: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _plainSummary(survey.surveyDescription),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rótulos: ${_questionLabelPreview(survey)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
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
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'manage-prompts',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SurveyPromptListPage(),
                ),
              );
            },
            icon: const Icon(Icons.text_fields),
            label: const Text('Prompts'),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'manage-personas',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PersonaSkillListPage(),
                ),
              );
            },
            icon: const Icon(Icons.face),
            label: const Text('Personas'),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'manage-access-points',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AgentAccessPointListPage(),
                ),
              );
            },
            icon: const Icon(Icons.hub),
            label: const Text('Acessos'),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'export-surveys',
            onPressed: _exporting ? null : _exportSurveys,
            icon: _exporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: Text(_exporting ? 'Exportando...' : 'Exportar'),
          ),
        ],
      ),
    );
  }
}
