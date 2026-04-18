import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/models/agent_access_point_draft.dart';
import 'package:survey_builder/core/repositories/agent_access_point_repository.dart';
import 'package:survey_builder/features/survey/pages/agent_access_point_form_page.dart';

class AgentAccessPointListPage extends StatefulWidget {
  const AgentAccessPointListPage({super.key, this.repository});

  final AgentAccessPointRepository? repository;

  @override
  State<AgentAccessPointListPage> createState() =>
      _AgentAccessPointListPageState();
}

class _AgentAccessPointListPageState extends State<AgentAccessPointListPage> {
  late final AgentAccessPointRepository _repository;
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;
  String? _error;
  DsFeedbackMessage? _feedback;
  List<AgentAccessPointDraft> _accessPoints = <AgentAccessPointDraft>[];
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? AgentAccessPointRepository();
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

  List<AgentAccessPointDraft> get _filteredAccessPoints {
    if (_filter.isEmpty) {
      return _accessPoints;
    }
    return _accessPoints.where((accessPoint) {
      final haystacks = <String>[
        accessPoint.name,
        accessPoint.accessPointKey,
        accessPoint.sourceApp,
        accessPoint.flowKey,
        accessPoint.surveyId ?? '',
      ].map((value) => value.toLowerCase());
      return haystacks.any((value) => value.contains(_filter));
    }).toList();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final accessPoints = await _repository.listAccessPoints();
      setState(() => _accessPoints = accessPoints);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openForm({AgentAccessPointDraft? draft}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AgentAccessPointFormPage(initialDraft: draft?.copy()),
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
          title: 'Ponto de acesso salvo',
          message: 'Alterações salvas.',
        ),
      );
    }
  }

  Future<void> _deleteAccessPoint(AgentAccessPointDraft draft) async {
    final confirmed = await showDsDeleteConfirmationDialog(
      context: context,
      title: 'Excluir ponto de acesso?',
      content: 'Isso excluirá permanentemente "${draft.name}".',
    );
    if (!confirmed) {
      return;
    }
    try {
      await _repository.deleteAccessPoint(draft.accessPointKey);
      if (!mounted) {
        return;
      }
      await _load();
      setState(() {
        _feedback = const DsFeedbackMessage(
          severity: DsStatusType.success,
          title: 'Ponto de acesso excluído',
          message: 'Ponto de acesso removido.',
        );
      });
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _feedback = DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Falha ao excluir ponto de acesso',
          message: 'Falha ao excluir ponto de acesso: $error',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: 'Pontos de acesso',
      subtitle: 'Gerencie o roteamento de runtime por fluxo e superfície.',
      body: DsAdminCatalogShell<AgentAccessPointDraft>(
        heading: 'Catálogo de pontos de acesso',
        createLabel: 'Criar ponto de acesso',
        isLoading: _loading,
        items: _filteredAccessPoints,
        searchController: _searchController,
        searchPlaceholder: 'Filtrar por nome, chave, fluxo ou survey...',
        emptyMessage: _filter.isEmpty
            ? 'Nenhum ponto de acesso encontrado.'
            : 'Nenhum ponto de acesso corresponde ao filtro "$_filter".',
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
        itemBuilder: (BuildContext context, AgentAccessPointDraft accessPoint) {
          final surveyScope = accessPoint.surveyId == null
              ? 'global'
              : 'survey ${accessPoint.surveyId}';
          return DsAdminCatalogItem(
            title: accessPoint.name,
            subtitle:
                '${accessPoint.accessPointKey} · ${accessPoint.sourceApp}/${accessPoint.flowKey} · $surveyScope',
            onEdit: () => _openForm(draft: accessPoint),
            onDelete: () => _deleteAccessPoint(accessPoint),
          );
        },
      ),
    );
  }
}
