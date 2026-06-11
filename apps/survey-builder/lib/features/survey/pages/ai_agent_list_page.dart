import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/models/ai_agent_draft.dart';
import 'package:survey_builder/core/repositories/ai_agent_repository.dart';
import 'package:survey_builder/features/survey/pages/ai_agent_form_page.dart';

class AIAgentListPage extends StatefulWidget {
  const AIAgentListPage({super.key, this.repository, this.embedded = false});

  final AIAgentRepository? repository;
  final bool embedded;

  @override
  State<AIAgentListPage> createState() => _AIAgentListPageState();
}

class _AIAgentListPageState extends State<AIAgentListPage> {
  late final AIAgentRepository _repository;
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;
  String? _error;
  DsFeedbackMessage? _feedback;
  List<AIAgentDraft> _agents = <AIAgentDraft>[];
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? AIAgentRepository();
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
    setState(() => _filter = _searchController.text.trim().toLowerCase());
  }

  List<AIAgentDraft> get _filteredAgents {
    if (_filter.isEmpty) {
      return _agents;
    }
    return _agents.where((agent) {
      final haystacks = <String>[
        agent.name,
        agent.agentKey,
        agent.providerType,
        agent.defaultModel,
        agent.baseUrl ?? '',
        agent.apiKeyEnvVar ?? '',
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
      final agents = await _repository.listAgents();
      setState(() => _agents = agents);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openForm({AIAgentDraft? draft}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AIAgentFormPage(initialDraft: draft?.copy()),
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
          title: 'Agente de IA salvo',
          message: 'Alterações salvas.',
        ),
      );
    }
  }

  Future<void> _deleteAgent(AIAgentDraft draft) async {
    final confirmed = await showDsDeleteConfirmationDialog(
      context: context,
      title: 'Excluir agente de IA?',
      content: 'Isso excluirá permanentemente "${draft.name}".',
    );
    if (!confirmed) {
      return;
    }
    try {
      await _repository.deleteAgent(draft.agentKey);
      if (!mounted) {
        return;
      }
      await _load();
      setState(() {
        _feedback = const DsFeedbackMessage(
          severity: DsStatusType.success,
          title: 'Agente de IA excluído',
          message: 'Agente removido.',
        );
      });
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _feedback = DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Falha ao excluir agente de IA',
          message: 'Falha ao excluir agente de IA: $error',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = DsAdminCatalogShell<AIAgentDraft>(
      heading: 'Catálogo de agentes de IA',
      createLabel: 'Criar agente',
      isLoading: _loading,
      items: _filteredAgents,
      searchController: _searchController,
      searchPlaceholder: 'Filtrar por nome, chave, provedor ou modelo...',
      emptyMessage: _filter.isEmpty
          ? 'Nenhum agente de IA encontrado.'
          : 'Nenhum agente de IA corresponde ao filtro "$_filter".',
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
      itemBuilder: (BuildContext context, AIAgentDraft agent) {
        final status = agent.enabled ? 'habilitado' : 'desabilitado';
        final baseUrl = agent.baseUrl == null || agent.baseUrl!.isEmpty
            ? 'sem base URL'
            : agent.baseUrl!;
        return DsAdminCatalogItem(
          title: agent.name,
          subtitle:
              '${agent.agentKey} · ${agent.providerType} · ${agent.defaultModel} · $status · $baseUrl',
          onEdit: () => _openForm(draft: agent),
          onDelete: () => _deleteAgent(agent),
        );
      },
    );

    if (widget.embedded) {
      return content;
    }

    return DsScaffold(
      title: 'Agentes de IA',
      subtitle: 'Gerencie endpoints e modelos disponíveis para access points.',
      body: content,
    );
  }
}
