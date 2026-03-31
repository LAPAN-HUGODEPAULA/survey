import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/models/persona_skill_draft.dart';
import 'package:survey_builder/core/repositories/persona_skill_repository.dart';
import 'package:survey_builder/features/survey/pages/persona_skill_form_page.dart';

class PersonaSkillListPage extends StatefulWidget {
  const PersonaSkillListPage({super.key, this.repository});

  final PersonaSkillRepository? repository;

  @override
  State<PersonaSkillListPage> createState() => _PersonaSkillListPageState();
}

class _PersonaSkillListPageState extends State<PersonaSkillListPage> {
  late final PersonaSkillRepository _repository;
  bool _loading = true;
  String? _error;
  List<PersonaSkillDraft> _skills = <PersonaSkillDraft>[];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? PersonaSkillRepository();
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
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao excluir persona: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      appBar: AppBar(title: const Text('Personas de saída')),
      body: DsAdminCatalogShell<PersonaSkillDraft>(
        heading: 'Catálogo de personas',
        createLabel: 'Criar persona',
        isLoading: _loading,
        items: _skills,
        emptyMessage: 'Nenhuma persona encontrada.',
        error: _error,
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
