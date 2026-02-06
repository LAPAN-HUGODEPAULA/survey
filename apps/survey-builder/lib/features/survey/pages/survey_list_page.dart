library;

import 'package:flutter/material.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:survey_builder/core/models/survey_draft.dart';
import 'package:survey_builder/core/repositories/survey_repository.dart';
import 'package:survey_builder/features/survey/pages/survey_form_page.dart';

class SurveyListPage extends StatefulWidget {
  const SurveyListPage({super.key, this.repository});

  final SurveyRepository? repository;

  @override
  State<SurveyListPage> createState() => _SurveyListPageState();
}

class _SurveyListPageState extends State<SurveyListPage> {
  late final SurveyRepository _repo;
  bool _loading = true;
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
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SurveyFormPage(initialDraft: draft),
      ),
    );
    await _load();
  }

  Future<void> _confirmDelete(SurveyDraft draft) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DsDialog(
        title: 'Delete survey?',
        content: Text('This will permanently delete "${draft.surveyDisplayName}".'),
        actions: [
          DsTextButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
          ),
          DsFilledButton(
            label: 'Delete',
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $error')),
      );
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
      instructions: InstructionsDraft(preamble: '', questionText: '', answers: ['']),
      questions: [],
      finalNotes: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: 'Survey Builder',
      actions: [
        IconButton(
          tooltip: 'Refresh',
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
                    'Surveys',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(width: 16),
                DsFilledButton(
                  label: 'Create Survey',
                  onPressed: () => _openForm(draft: _emptyDraft()),
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
                          ? const DsEmpty(message: 'No surveys found.')
                          : ListView.separated(
                              itemCount: _surveys.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final survey = _surveys[index];
                                return Card(
                                  elevation: 1,
                                  child: ListTile(
                                    title: Text(survey.surveyDisplayName),
                                    subtitle: Text(survey.surveyDescription),
                                    trailing: Wrap(
                                      spacing: 8,
                                      children: [
                                        IconButton(
                                          tooltip: 'Edit',
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _openForm(draft: survey),
                                        ),
                                        IconButton(
                                          tooltip: 'Delete',
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
