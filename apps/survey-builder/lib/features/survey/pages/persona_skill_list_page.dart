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
  List<PersonaSkillDraft> _skills = [];

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DsDialog(
        title: 'Excluir persona?',
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
                    'Catálogo de personas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(width: 16),
                DsFilledButton(label: 'Criar persona', onPressed: _openForm),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const DsLoading()
                  : _error != null
                  ? DsError(message: _error!, onRetry: _load)
                  : _skills.isEmpty
                  ? const DsEmpty(message: 'Nenhuma persona encontrada.')
                  : ListView.separated(
                      itemCount: _skills.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final skill = _skills[index];
                        return Card(
                          child: ListTile(
                            title: Text(skill.name),
                            subtitle: Text(
                              '${skill.personaSkillKey} · ${skill.outputProfile}',
                            ),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  tooltip: 'Editar',
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _openForm(draft: skill),
                                ),
                                IconButton(
                                  tooltip: 'Excluir',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _deletePersonaSkill(skill),
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
