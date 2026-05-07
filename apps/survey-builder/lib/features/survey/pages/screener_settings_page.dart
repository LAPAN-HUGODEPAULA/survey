import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:survey_builder/core/models/ai_settings_draft.dart';
import 'package:survey_builder/core/models/survey_draft.dart';
import 'package:survey_builder/core/repositories/ai_settings_repository.dart';
import 'package:survey_builder/core/repositories/screener_settings_repository.dart';
import 'package:survey_builder/core/repositories/survey_repository.dart';

class ScreenerSettingsPage extends StatefulWidget {
  const ScreenerSettingsPage({
    super.key,
    this.settingsRepository,
    this.aiSettingsRepository,
    this.surveyRepository,
    this.embedded = false,
  });

  final ScreenerSettingsRepository? settingsRepository;
  final AISettingsRepository? aiSettingsRepository;
  final SurveyRepository? surveyRepository;
  final bool embedded;

  @override
  State<ScreenerSettingsPage> createState() => _ScreenerSettingsPageState();
}

class _ScreenerSettingsPageState extends State<ScreenerSettingsPage> {
  late final ScreenerSettingsRepository _settingsRepository;
  late final AISettingsRepository _aiSettingsRepository;
  late final SurveyRepository _surveyRepository;
  late final TextEditingController _primaryModelController;
  late final TextEditingController _fallbackModelController;
  List<SurveyDraft> _surveys = <SurveyDraft>[];
  String? _selectedSurveyId;
  String? _activeSurveyName;
  String _aiPrimaryProvider = 'glm';
  String? _aiFallbackProvider = 'gemini';
  double _aiTemperature = 0.0;
  String _aiReasoningEffort = 'low';
  bool _aiEnableCaching = true;
  bool _loading = true;
  bool _saving = false;
  bool _savingAi = false;
  DsFeedbackMessage? _feedback;

  @override
  void initState() {
    super.initState();
    _settingsRepository = widget.settingsRepository ?? ScreenerSettingsRepository();
    _aiSettingsRepository = widget.aiSettingsRepository ?? AISettingsRepository();
    _surveyRepository = widget.surveyRepository ?? SurveyRepository();
    _primaryModelController = TextEditingController();
    _fallbackModelController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _settingsRepository.dispose();
    _aiSettingsRepository.dispose();
    _surveyRepository.dispose();
    _primaryModelController.dispose();
    _fallbackModelController.dispose();
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
      final aiSettings = await _aiSettingsRepository.fetchSettings();
      if (!mounted) {
        return;
      }
      setState(() {
        _surveys = surveys;
        _selectedSurveyId = settings.defaultQuestionnaireId;
        _activeSurveyName = settings.defaultQuestionnaireName;
        if (aiSettings != null) {
          _aiPrimaryProvider = aiSettings.primaryProvider;
          _aiFallbackProvider = aiSettings.fallbackProvider;
          _aiTemperature = aiSettings.temperature;
          _aiReasoningEffort = aiSettings.reasoningEffort;
          _aiEnableCaching = aiSettings.enableCaching;
          _primaryModelController.text = aiSettings.primaryModel;
          _fallbackModelController.text = aiSettings.fallbackModel ?? '';
        }
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

  Future<void> _saveAiSettings() async {
    if (_primaryModelController.text.trim().isEmpty) {
      setState(() {
        _feedback = const DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Modelo primário obrigatório',
          message: 'Defina o modelo primário global de IA antes de salvar.',
        );
      });
      return;
    }

    setState(() {
      _savingAi = true;
      _feedback = null;
    });
    try {
      final updated = await _aiSettingsRepository.updateSettings(
        GlobalAIConfigDraft(
          primaryProvider: _aiPrimaryProvider,
          primaryModel: _primaryModelController.text.trim(),
          fallbackProvider: _aiFallbackProvider,
          fallbackModel: _fallbackModelController.text.trim().isEmpty
              ? null
              : _fallbackModelController.text.trim(),
          temperature: _aiTemperature,
          reasoningEffort: _aiReasoningEffort,
          enableCaching: _aiEnableCaching,
        ),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _aiPrimaryProvider = updated.primaryProvider;
        _aiFallbackProvider = updated.fallbackProvider;
        _aiTemperature = updated.temperature;
        _aiReasoningEffort = updated.reasoningEffort;
        _aiEnableCaching = updated.enableCaching;
        _primaryModelController.text = updated.primaryModel;
        _fallbackModelController.text = updated.fallbackModel ?? '';
        _savingAi = false;
        _feedback = const DsFeedbackMessage(
          severity: DsStatusType.success,
          title: 'Configuração de IA salva',
          message: 'Configurações globais de IA atualizadas com sucesso.',
        );
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _savingAi = false;
        _feedback = DsFeedbackMessage(
          severity: DsStatusType.error,
          title: 'Falha ao salvar IA global',
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
              const SizedBox(height: 16),
              DsSection(
                eyebrow: 'Global AI',
                title: 'Configurações globais de IA',
                subtitle:
                    'Esses valores são herdados por access points sem override em aiConfig.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _aiPrimaryProvider,
                      decoration: const InputDecoration(
                        labelText: 'Provider primário *',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'glm', child: Text('glm')),
                        DropdownMenuItem(value: 'gemini', child: Text('gemini')),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() => _aiPrimaryProvider = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _primaryModelController,
                      decoration: const InputDecoration(
                        labelText: 'Modelo primário *',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      initialValue: _aiFallbackProvider,
                      decoration: const InputDecoration(
                        labelText: 'Provider fallback',
                      ),
                      items: const [
                        DropdownMenuItem<String?>(value: null, child: Text('Sem fallback')),
                        DropdownMenuItem(value: 'glm', child: Text('glm')),
                        DropdownMenuItem(value: 'gemini', child: Text('gemini')),
                      ],
                      onChanged: (value) {
                        setState(() => _aiFallbackProvider = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _fallbackModelController,
                      decoration: const InputDecoration(
                        labelText: 'Modelo fallback',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _aiReasoningEffort,
                      decoration: const InputDecoration(
                        labelText: 'Reasoning effort',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('low')),
                        DropdownMenuItem(value: 'medium', child: Text('medium')),
                        DropdownMenuItem(value: 'high', child: Text('high')),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() => _aiReasoningEffort = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    Text('Temperatura: ${_aiTemperature.toStringAsFixed(2)}'),
                    Slider(
                      value: _aiTemperature,
                      min: 0,
                      max: 1,
                      onChanged: (value) => setState(() => _aiTemperature = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _aiEnableCaching,
                      onChanged: (value) => setState(() => _aiEnableCaching = value),
                      title: const Text('Habilitar caching'),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: DsFilledButton(
                        label: _savingAi ? 'Salvando IA...' : 'Salvar IA global',
                        onPressed: _savingAi ? null : _saveAiSettings,
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
