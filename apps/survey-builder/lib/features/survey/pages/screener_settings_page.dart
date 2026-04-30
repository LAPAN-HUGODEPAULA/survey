import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/models/survey_draft.dart';
import 'package:survey_builder/core/repositories/screener_settings_repository.dart';
import 'package:survey_builder/core/repositories/survey_repository.dart';

class ScreenerSettingsPage extends StatefulWidget {
  const ScreenerSettingsPage({
    super.key,
    this.settingsRepository,
    this.surveyRepository,
    this.embedded = false,
  });

  final ScreenerSettingsRepository? settingsRepository;
  final SurveyRepository? surveyRepository;
  final bool embedded;

  @override
  State<ScreenerSettingsPage> createState() => _ScreenerSettingsPageState();
}

class _ScreenerSettingsPageState extends State<ScreenerSettingsPage> {
  late final ScreenerSettingsRepository _settingsRepository;
  late final SurveyRepository _surveyRepository;
  List<SurveyDraft> _surveys = <SurveyDraft>[];
  String? _selectedSurveyId;
  String? _activeSurveyName;
  bool _loading = true;
  bool _saving = false;
  DsFeedbackMessage? _feedback;

  @override
  void initState() {
    super.initState();
    _settingsRepository = widget.settingsRepository ?? ScreenerSettingsRepository();
    _surveyRepository = widget.surveyRepository ?? SurveyRepository();
    _load();
  }

  @override
  void dispose() {
    _settingsRepository.dispose();
    _surveyRepository.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _feedback = null;
    });
    try {
      final surveys = await _surveyRepository.listSurveys();
      final settings = await _settingsRepository.fetchSettings();
      if (!mounted) {
        return;
      }
      setState(() {
        _surveys = surveys;
        _selectedSurveyId = settings.defaultQuestionnaireId;
        _activeSurveyName = settings.defaultQuestionnaireName;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _feedback = DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Falha ao carregar configurações',
          message: '$error',
        );
      });
    }
  }

  Future<void> _save() async {
    final selectedSurveyId = _selectedSurveyId;
    if (selectedSurveyId == null || selectedSurveyId.isEmpty) {
      setState(() {
        _feedback = const DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Selecione um questionário',
          message: 'Defina o questionário padrão antes de salvar.',
        );
      });
      return;
    }

    setState(() {
      _saving = true;
      _feedback = null;
    });
    try {
      final updated = await _settingsRepository.updateDefaultQuestionnaire(
        selectedSurveyId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _activeSurveyName = updated.defaultQuestionnaireName;
        _saving = false;
        _feedback = const DsFeedbackMessage(
          severity: DsStatusType.success,
          title: 'Configuração salva',
          message: 'Questionário padrão do screener atualizado com sucesso.',
        );
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
        _feedback = DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Falha ao salvar',
          message: '$error',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_feedback != null) ...[
                DsMessageBanner(
                  feedback: DsFeedbackMessage(
                    severity: _feedback!.severity,
                    title: _feedback!.title,
                    message: _feedback!.message,
                    dismissible: true,
                    onDismiss: () => setState(() => _feedback = null),
                  ),
                  margin: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
              ],
              DsSection(
                eyebrow: 'Screener',
                title: 'Questionário padrão do screener',
                subtitle:
                    'Defina qual questionário deve abrir automaticamente no survey-frontend.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSurveyId,
                      decoration: const InputDecoration(
                        labelText: 'Questionário padrão *',
                      ),
                      items: _surveys
                          .map(
                            (survey) => DropdownMenuItem<String>(
                              value: survey.id,
                              child: Text(
                                survey.surveyDisplayName.isNotEmpty
                                    ? survey.surveyDisplayName
                                    : survey.surveyName,
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        setState(() => _selectedSurveyId = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    DsInlineMessage(
                      feedback: DsFeedbackMessage(
                        severity: DsStatusType.info,
                        title: 'Sessão profissional ativa',
                        message:
                            'Questionário configurado: ${_activeSurveyName ?? "Não definido"}',
                      ),
                      margin: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: DsFilledButton(
                        label: _saving ? 'Salvando...' : 'Salvar configuração',
                        onPressed: _saving ? null : _save,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

    if (widget.embedded) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: content,
      );
    }

    return DsScaffold(
      title: 'Configurações do Screener',
      subtitle: 'Gerencie o questionário padrão usado no fluxo profissional.',
      body: content,
    );
  }
}
