import 'package:flutter/material.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:survey_builder/core/models/persona_skill_draft.dart';
import 'package:survey_builder/core/repositories/persona_skill_repository.dart';
import 'package:survey_builder/features/survey/pages/persona_skill_form_page.dart';
import 'package:survey_builder/features/survey/pages/task_dashboard_page.dart';

class PersonaSkillListPage extends StatefulWidget {
  const PersonaSkillListPage({super.key, this.repository});

  final PersonaSkillRepository? repository;

  @override
  State<PersonaSkillListPage> createState() => _PersonaSkillListPageState();
}

class _PersonaSkillListPageState extends State<PersonaSkillListPage> {
  late final PersonaSkillRepository _repository;
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;
  String? _error;
  DsFeedbackMessage? _feedback;
  List<PersonaSkillDraft> _skills = <PersonaSkillDraft>[];
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? PersonaSkillRepository();
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

  List<PersonaSkillDraft> get _filteredSkills {
    if (_filter.isEmpty) {
      return _skills;
    }
    return _skills.where((skill) {
      final name = skill.name.toLowerCase();
      final key = skill.personaSkillKey.toLowerCase();
      final profile = skill.outputProfile.toLowerCase();
      return name.contains(_filter) ||
          key.contains(_filter) ||
          profile.contains(_filter);
    }).toList();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final skills = await _repository.listPersonaSkills();
      setState(() => _skills = skills);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openForm({PersonaSkillDraft? draft}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PersonaSkillFormPage(
          initialDraft: draft?.copy(),
          existingSkills: _skills,
        ),
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
          title: 'Persona salva',
          message: 'Alterações salvas.',
        ),
      );
    }
  }

  Future<void> _deletePersonaSkill(PersonaSkillDraft draft) async {
    final confirmed = await showDsDeleteConfirmationDialog(
      context: context,
      title: 'Excluir persona?',
      content: 'Isso excluirá permanentemente "${draft.name}".',
    );
    if (!confirmed) {
      return;
    }

    try {
      await _repository.deletePersonaSkill(draft.personaSkillKey);
      if (!mounted) {
        return;
      }
      await _load();
      setState(() {
        _feedback = const DsFeedbackMessage(
          severity: DsStatusType.success,
          title: 'Persona excluída',
          message: 'Persona removida.',
        );
      });
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _feedback = DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Falha ao excluir persona',
          message: 'Falha ao excluir persona: $error',
        );
      });
    }
  }

  void _showExamples() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => DsDialog(
        title: 'Exemplos de personas',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Alguns exemplos de personas comuns:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildPersonaExample(
              context,
              name: 'Cardiologista',
              description: 'Foco em condições cardiovasculares e prevenção',
            ),
            _buildPersonaExample(
              context,
              name: 'Endocrinologista',
              description: 'Especialista em diabetes e doenças metabólicas',
            ),
            _buildPersonaExample(
              context,
              name: 'Médico Geral',
              description: 'Atendimento primário e saúde preventiva',
            ),
          ],
        ),
        actions: [
          DsTextButton(
            label: 'Fechar',
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonaExample(BuildContext context, {required String name, required String description}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.person,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: 'Personas',
      subtitle: 'Gerencie personas compartilhadas e perfis padrão.',
      breadcrumbs: [
        DsBreadcrumbItem(
          label: 'Dashboard',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const TaskDashboardPage()),
          ),
        ),
        DsBreadcrumbItem(
          label: 'Personas',
          isCurrent: true,
        ),
      ],
      onBack: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const TaskDashboardPage()),
      ),
      backLabel: 'Voltar ao dashboard',
      body: DsAdminCatalogShell<PersonaSkillDraft>(
        heading: 'Catálogo de personas',
        createLabel: 'Criar persona',
        isLoading: _loading,
        items: _filteredSkills,
        searchController: _searchController,
        searchPlaceholder: 'Filtrar personas por nome, chave ou perfil...',
        emptyMessage: _filter.isEmpty
            ? 'Nenhuma persona encontrada.'
            : 'Nenhuma persona corresponde ao filtro "$_filter".',
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
        itemBuilder: (BuildContext context, PersonaSkillDraft skill) {
          return DsAdminCatalogItem(
            title: skill.name,
            subtitle: '${skill.personaSkillKey} · ${skill.outputProfile}',
            onEdit: () => _openForm(draft: skill),
            onDelete: () => _deletePersonaSkill(skill),
          );
        },
      ),
    );
  }
}
